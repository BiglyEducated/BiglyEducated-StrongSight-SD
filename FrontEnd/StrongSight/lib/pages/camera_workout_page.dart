// lib/pages/camera_workout_page.dart
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:camera/camera.dart';

import '../services/pose_detector_service.dart';
import '../services/camera_service.dart';
import '../services/camera_utils.dart';
import '../services/rep_sound_service.dart';

import 'widgets/pose_overlay_painter.dart';
import 'widgets/workout_stats_overlay.dart';
import 'workout_feedback_summary_page.dart';

class CameraWorkoutPage extends StatefulWidget {
  final String exerciseName;

  const CameraWorkoutPage({super.key, required this.exerciseName});

  @override
  State<CameraWorkoutPage> createState() => _CameraWorkoutPageState();
}

class _CameraWorkoutPageState extends State<CameraWorkoutPage> {
  final CameraService _cameraService = CameraService();
  final PoseDetectorService _poseDetector = PoseDetectorService();
  final RepSoundService _soundService = RepSoundService();

  bool _isDetecting = false;
  bool _isProcessing = false;

  int _repCount = 0;
  String _feedback = 'Position yourself in frame';
  String _currentPhase = 'standing';
  bool _hasFormError = false;
  String? _errorMessage;

  List<Pose> _detectedPoses = [];
  int _frameSkipCounter = 0;
  static const int _frameSkipRate = 3;

  // Mute toggle (UI only for now - no persistence yet)
  bool _isMuted = false;

  // Sound edge detection (prevents spam)
  int _lastRepCountForSound = 0;
  bool _lastRedForSound = false;
  String _lastRedMsgForSound = '';

  // Session-level form tracking for end-of-workout summary
  final Map<String, int> _formIssueCounts = {};
  String? _activeFormIssueKey;

  @override
  void initState() {
    super.initState();
    print('CameraWorkoutPage: initState called');

    // Preload audio (configured via audio_session inside RepSoundService)
    _soundService.preload();

    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    print('CameraWorkoutPage: Starting camera initialization...');
    try {
      print('CameraWorkoutPage: Initializing camera service...');
      await _cameraService.initialize();

      print('CameraWorkoutPage: Initializing pose detector...');
      await _poseDetector.initialize();

      print('CameraWorkoutPage: Setting exercise: ${widget.exerciseName}');
      _poseDetector.setExercise(widget.exerciseName);

      if (!mounted) {
        print('CameraWorkoutPage: Widget not mounted, returning');
        return;
      }

      print('CameraWorkoutPage: Updating UI state');
      setState(() {
        _errorMessage = null;
      });

      // Start processing with small delay
      print('CameraWorkoutPage: Waiting 500ms before starting stream...');
      await Future.delayed(const Duration(milliseconds: 500));

      print('CameraWorkoutPage: Starting image stream...');
      _cameraService.startImageStream(_processCameraImage);
      print('CameraWorkoutPage: Initialization complete!');
    } catch (e, stackTrace) {
      print('CameraWorkoutPage ERROR: $e');
      print('Stack trace: $stackTrace');
      if (mounted) {
        setState(() {
          _errorMessage = 'Camera failed: $e';
          _feedback = 'Camera initialization failed';
        });
      }
    }
  }

  Future<void> _switchCamera() async {
    try {
      await _cameraService.stopImageStream();
      await _cameraService.switchCamera();

      if (!mounted) return;
      setState(() {});

      await Future.delayed(const Duration(milliseconds: 500));
      _cameraService.startImageStream(_processCameraImage);
    } catch (e) {
      print('Error switching camera: $e');
    }
  }

  bool _isRedFeedback(String feedback, bool hasFormError) {
    return hasFormError ||
        feedback.contains('⚠️') ||
        feedback.contains('CAVE') ||
        feedback.contains('LEAN') ||
        feedback.contains('UNEVEN') ||
        feedback.contains('FLARE') ||
        feedback.contains('WRIST') ||
        feedback.contains('TILT');
  }

  void _maybePlaySounds({
    required int newRepCount,
    required String newFeedback,
    required bool newHasFormError,
  }) {
    if (_isMuted) return;

    // GOOD rep sound: only when count increases
    if (newRepCount > _lastRepCountForSound) {
      _soundService.playGood();
      _lastRepCountForSound = newRepCount;
    }

    // BAD sound: only when feedback transitions to red
    final bool isRed = _isRedFeedback(newFeedback, newHasFormError);
    if (!_lastRedForSound && isRed) {
      // avoid repeating the exact same red warning message back-to-back
      if (newFeedback != _lastRedMsgForSound) {
        _soundService.playBad();
        _lastRedMsgForSound = newFeedback;
      }
    }
    _lastRedForSound = isRed;
  }

  String? _extractFormIssueKey(String feedback, bool hasFormError) {
    if (!hasFormError) return null;

    final normalized = feedback.toUpperCase();
    if (normalized.contains('KNEE CAVE')) return 'Knee cave';
    if (normalized.contains('FORWARD LEAN')) return 'Forward lean';
    if (normalized.contains('UNEVEN')) return 'Uneven movement';
    if (normalized.contains('ELBOW FLARE')) return 'Elbow flare';
    if (normalized.contains('WRIST STACK')) return 'Wrist stacking';
    if (normalized.contains('BAR TILT')) return 'Bar tilt / uneven press';
    if (normalized.contains('LOWER THE WEIGHT MORE CONTROLLED')) {
      return 'Eccentric too fast';
    }
    if (normalized.contains('AVOID BOUNCING OUT OF THE BOTTOM')) {
      return 'Bounced out of bottom';
    }
    return 'General form breakdown';
  }

  void _trackFormIssues({
    required String feedback,
    required bool hasFormError,
  }) {
    final issueKey = _extractFormIssueKey(feedback, hasFormError);

    if (issueKey == null) {
      _activeFormIssueKey = null;
      return;
    }

    // Count only when a warning first appears or changes category.
    if (_activeFormIssueKey != issueKey) {
      _formIssueCounts.update(issueKey, (value) => value + 1, ifAbsent: () => 1);
    }

    _activeFormIssueKey = issueKey;
  }

  Future<void> _finishWorkout() async {
    await _cameraService.stopImageStream();
    if (!mounted) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WorkoutFeedbackSummaryPage(
          exerciseName: widget.exerciseName,
          repCount: _repCount,
          formIssueCounts: Map<String, int>.from(_formIssueCounts),
          averageEccentricSeconds: _poseDetector.averageEccentricDurationSeconds,
          averageConcentricSeconds: _poseDetector.averageConcentricDurationSeconds,
        ),
      ),
    );

    if (!mounted) return;
    Navigator.pop(context, _repCount);
  }

  Future<void> _processCameraImage(CameraImage image) async {
    // Frame skipping for performance
    _frameSkipCounter++;
    if (_frameSkipCounter % _frameSkipRate != 0) return;
    if (_isDetecting || _isProcessing) return;

    _isDetecting = true;
    _isProcessing = true;

    try {
      final controller = _cameraService.controller;
      if (controller == null) return;

      final rotation = getImageRotation(controller);
      final poses = await _poseDetector.detectPoses(image, rotation);

      if (!mounted) return;

      if (poses.isNotEmpty) {
        final analysis = _poseDetector.analyzeCurrentExerciseForm(poses.first);

        if (analysis.isValid) {
          final int newRepCount = analysis.repCount;
          final String newFeedback = analysis.feedback;
          final String newPhase = analysis.phase;
          final bool newHasFormError = analysis.hasFormError;

          // Play sounds BEFORE setState (avoids any rebuild timing weirdness)
          _maybePlaySounds(
            newRepCount: newRepCount,
            newFeedback: newFeedback,
            newHasFormError: newHasFormError,
          );
          _trackFormIssues(
            feedback: newFeedback,
            hasFormError: newHasFormError,
          );

          setState(() {
            _repCount = newRepCount;
            _feedback = newFeedback;
            _currentPhase = newPhase;
            _hasFormError = newHasFormError;
            _detectedPoses = poses;
          });
        } else {
          setState(() {
            _feedback = analysis.feedback;
            _detectedPoses = [];
          });
        }
      } else {
        setState(() {
          _detectedPoses = [];
          _feedback = 'Position yourself in frame';
        });
      }
    } catch (e) {
      print('Error processing image: $e');
      if (mounted) {
        setState(() {
          _feedback = 'Processing error - try repositioning';
        });
      }
    } finally {
      _isDetecting = false;
      await Future.delayed(const Duration(milliseconds: 50));
      _isProcessing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          widget.exerciseName,
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (_cameraService.cameras.length > 1)
            IconButton(
              icon: const Icon(Icons.flip_camera_ios, color: Colors.white),
              onPressed: _cameraService.isInitialized ? _switchCamera : null,
            ),

          // Mute toggle button (kept as requested)
          IconButton(
            tooltip: _isMuted ? 'Unmute' : 'Mute',
            icon: Icon(
              _isMuted ? Icons.volume_off : Icons.volume_up,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _isMuted = !_isMuted;
              });
            },
          ),
        ],
      ),
      body: _errorMessage != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 60,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _errorMessage!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _errorMessage = null;
                        });
                        _initializeCamera();
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          : !_cameraService.isInitialized
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: Color(0xFF039E39)),
                      SizedBox(height: 16),
                      Text(
                        'Initializing camera...',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                )
              : Stack(
                  fit: StackFit.expand,
                  children: [
                    // Camera Preview
                    Center(
                      child: _cameraService.controller == null
                          ? const Text(
                              'Camera controller is null',
                              style: TextStyle(color: Colors.white),
                            )
                          : CameraPreview(_cameraService.controller!),
                    ),

                    // Pose Overlay
                    if (_detectedPoses.isNotEmpty && _cameraService.controller != null)
                      CustomPaint(
                        painter: PoseOverlayPainter(
                          poses: _detectedPoses,
                          imageSize: Size(
                            _cameraService.controller!.value.previewSize!.height,
                            _cameraService.controller!.value.previewSize!.width,
                          ),
                          rotation: getImageRotation(_cameraService.controller!),
                          isBackCamera: _cameraService.isBackCamera,
                          screenSize: screenSize,
                        ),
                        size: Size.infinite,
                      ),

                    // Stats Overlay
                    Positioned(
                      top: 20,
                      left: 20,
                      right: 20,
                      child: WorkoutStatsOverlay(
                        repCount: _repCount,
                        feedback: _feedback,
                        phase: _currentPhase,
                        hasError: _hasFormError,
                      ),
                    ),

                    // Finish Button
                    Positioned(
                      bottom: 40,
                      left: 20,
                      right: 20,
                      child: FinishWorkoutButton(
                        onPressed: _finishWorkout,
                      ),
                    ),
                  ],
                ),
    );
  }

  @override
  void dispose() {
    print('CameraWorkoutPage: dispose called');
    _cameraService.dispose();
    _poseDetector.dispose();
    _soundService.dispose();
    super.dispose();
  }
}

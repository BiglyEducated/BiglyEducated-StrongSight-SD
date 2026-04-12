// lib/pages/camera_workout_page.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';

import '../services/pose_detector_service.dart';
import '../services/camera_service.dart';
import '../services/camera_utils.dart';
import '../services/rep_sound_service.dart';
import '../providers/theme_provider.dart';

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
  bool _countdownActive = true;
  int _countdownValue = 5;

  int _repCount = 0;
  String _feedback = 'Position yourself in frame';
  String _currentPhase = 'standing';
  bool _hasFormError = false;
  String? _errorMessage;

  List<Pose> _detectedPoses = [];
  int _frameSkipCounter = 0;
  static const int _frameSkipRate = 3;
  static const int _setupDurationSeconds = 10;
  Timer? _setupTimer;
  int _setupCountdownSeconds = _setupDurationSeconds;

  // Mute toggle (UI only for now - no persistence yet)
  bool _isMuted = false;
  bool _formCheckEnabled = true;
  bool _showBar = true;

  // Sound edge detection (prevents spam)
  int _lastRepCountForSound = 0;
  bool _lastRedForSound = false;
  String _lastRedMsgForSound = '';

  // Head shake to stop tracking
  int _shakeCount = 0;
  bool _shakeMovingRight = false;
  bool _shakeMovingLeft = false;
  double? _shakeBaselineNoseX;
  DateTime? _firstShakeTime;
  static const int _shakesRequired = 3;
  static const double _shakeThreshold = 0.12; // nose must move 20% of nose-to-shoulder dist sideways
  static const double _shakeRecoveryThreshold = 0.05;
  static const Duration _shakeWindowDuration = Duration(seconds: 4);

  // Session-level form tracking for end-of-workout summary
  final Map<String, int> _formIssueCounts = {};
  String? _activeFormIssueKey;

  // Per-rep form error tracking for degradation analysis
  final List<int> _formErrorsPerRep = [];
  int _currentRepErrorCount = 0;
  int _lastRepCountForDegradation = 0;

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

      print('CameraWorkoutPage: Starting countdown...');
      await _startCountdown();

      print('CameraWorkoutPage: Starting image stream...');
      _cameraService.startImageStream(_processCameraImage);
      _startSetupCountdown();
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

  Future<void> _startCountdown() async {
    for (int i = 5; i >= 1; i--) {
      if (!mounted) return;
      setState(() {
        _countdownValue = i;
        _countdownActive = true;
      });
      await Future.delayed(const Duration(seconds: 1));
    }
    if (!mounted) return;
    setState(() {
      _countdownActive = false;
    });
  }

  Future<void> _switchCamera() async {
    try {
      await _cameraService.stopImageStream();
      await _cameraService.switchCamera();

      if (!mounted) return;
      setState(() {});

      await Future.delayed(const Duration(milliseconds: 500));
      _cameraService.startImageStream(_processCameraImage);
      _startSetupCountdown();
    } catch (e) {
      print('Error switching camera: $e');
    }
  }

  void _startSetupCountdown() {
    _setupTimer?.cancel();

    if (!mounted) return;
    setState(() {
      _setupCountdownSeconds = _setupDurationSeconds;
      _feedback = 'Set up your position';
      _detectedPoses = [];
    });

    _setupTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_setupCountdownSeconds <= 1) {
        timer.cancel();
        setState(() {
          _setupCountdownSeconds = 0;
          _feedback = 'Position yourself in frame';
        });
      } else {
        setState(() {
          _setupCountdownSeconds--;
        });
      }
    });
  }

  void _checkShakeGesture(Pose pose) {
    final nose = pose.landmarks[PoseLandmarkType.nose];
    final leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final rightShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
    if (nose == null || leftShoulder == null || rightShoulder == null) return;
    if (nose.likelihood < 0.6 || leftShoulder.likelihood < 0.6) return;

    // Shoulder width scales with distance — perfect horizontal reference
    final shoulderWidth = (leftShoulder.x - rightShoulder.x).abs();
    if (shoulderWidth <= 0) return;

    // Normalize nose X position relative to shoulder midpoint
    final shoulderMidX = (leftShoulder.x + rightShoulder.x) / 2;
    final normalizedNoseX = (nose.x - shoulderMidX) / shoulderWidth;

    // Initialize baseline at center
    _shakeBaselineNoseX ??= normalizedNoseX;

    final offset = normalizedNoseX - _shakeBaselineNoseX!;

    // Reset window if too long between shakes
    if (_firstShakeTime != null &&
        DateTime.now().difference(_firstShakeTime!) > _shakeWindowDuration) {
      _shakeCount = 0;
      _shakeMovingRight = false;
      _shakeMovingLeft = false;
      _firstShakeTime = null;
    }

    if (!_shakeMovingRight && !_shakeMovingLeft) {
      if (offset > _shakeThreshold) {
        _shakeMovingRight = true;
      } else if (offset < -_shakeThreshold) {
        _shakeMovingLeft = true;
      } else {
        // Head still — slowly update baseline
        _shakeBaselineNoseX = normalizedNoseX * 0.1 + _shakeBaselineNoseX! * 0.9;
      }
    } else if (_shakeMovingRight) {
      if (offset < -_shakeThreshold) {
        _shakeMovingRight = false;
        _shakeMovingLeft = true;
        _shakeCount++;
        _firstShakeTime ??= DateTime.now();
        if (_shakeCount >= _shakesRequired) {
          _shakeCount = 0;
          _firstShakeTime = null;
          _finishWorkout();
          return;
        }
        setState(() {});
      }
    } else if (_shakeMovingLeft) {
      if (offset > _shakeThreshold) {
        _shakeMovingLeft = false;
        _shakeMovingRight = true;
        _shakeCount++;
        _firstShakeTime ??= DateTime.now();
        if (_shakeCount >= _shakesRequired) {
          _shakeCount = 0;
          _firstShakeTime = null;
          _finishWorkout();
          return;
        }
        setState(() {});
      }
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
        feedback.contains('TILT') ||
        feedback.contains('HINGE') ||
        feedback.contains('PULL MORE') ||
        feedback.contains('ROUNDING') ||
        feedback.contains('PRESS');
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
    if (normalized.contains('HINGE MORE')) return 'Torso not hinged enough';
    if (normalized.contains('BACK LEAN')) return 'Excessive back lean';
    if (normalized.contains('BACK ROUNDING')) return 'Back rounding';
    if (normalized.contains('HEAD DOWN')) return 'Head dropping';
    if (normalized.contains('LEG DRIVE')) return 'Leg drive';
    if (normalized.contains('UNEVEN HIPS')) return 'Uneven hips';
    if (normalized.contains('BAR TOO HIGH')) return 'Bar too high';
    if (normalized.contains('BAR TILTING')) return 'Bar tilting on back';
    if (normalized.contains('UNEVEN PRESS')) return 'Uneven press';
    if (normalized.contains('BAR TILT')) return 'Bar tilt';
    if (normalized.contains('UNEVEN')) return 'Uneven movement';
    if (normalized.contains('ELBOW FLARE')) return 'Elbow flare';
    if (normalized.contains('WRIST STACK')) return 'Poor wrist stacking';
    if (normalized.contains('UNEVEN BAR')) return 'Uneven bar';
    if (normalized.contains('BAR TILT')) return 'Bar tilt / uneven press';
    if (normalized.contains('PULL MORE')) return 'Incomplete row pull';
    if (normalized.contains('TOO FAST') || normalized.contains('LOWER WITH CONTROL')) {
      return 'Eccentric too fast';
    }
    if (normalized.contains('BOUNCING') || normalized.contains('AVOID BOUNCING')) {
      return 'Bounced out of bottom';
    }
    return 'General form breakdown';
  }

  void _trackFormIssues({
    required String feedback,
    required bool hasFormError,
    required int currentRepCount,
  }) {
    // When a new rep completes, reset activeFormIssueKey so issues
    // that persist across reps get counted fresh each rep
    if (currentRepCount > _lastRepCountForDegradation) {
      _formErrorsPerRep.add(_currentRepErrorCount);
      _currentRepErrorCount = 0;
      _lastRepCountForDegradation = currentRepCount;
      _activeFormIssueKey = null; // reset so same issue counts again next rep
    }

    final issueKey = _extractFormIssueKey(feedback, hasFormError);

    if (issueKey == null) {
      _activeFormIssueKey = null;
      return;
    }

    // Count only when a warning first appears or changes category
    if (_activeFormIssueKey != issueKey) {
      _formIssueCounts.update(issueKey, (value) => value + 1, ifAbsent: () => 1);
      _currentRepErrorCount++;
    }

    _activeFormIssueKey = issueKey;
  }

  Future<void> _finishWorkout() async {
    await _cameraService.stopImageStream();
    if (!mounted) return;

    // Snapshot the last rep's error count before navigating
    if (_repCount > _lastRepCountForDegradation) {
      _formErrorsPerRep.add(_currentRepErrorCount);
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WorkoutFeedbackSummaryPage(
          exerciseName: widget.exerciseName,
          repCount: _repCount,
          formIssueCounts: Map<String, int>.from(_formIssueCounts),
          averageEccentricSeconds: _poseDetector.averageEccentricDurationSeconds,
          averageConcentricSeconds: _poseDetector.averageConcentricDurationSeconds,
          eccentricDurationsPerRep: List<double>.from(_poseDetector.eccentricDurationsPerRep),
          formErrorsPerRep: List<int>.from(_formErrorsPerRep),
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
        _checkShakeGesture(poses.first);
        final analysis = _poseDetector.analyzeCurrentExerciseForm(poses.first);

        if (analysis.isValid) {
          final int newRepCount = analysis.repCount;
          final String newFeedback = analysis.feedback;
          final String newPhase = analysis.phase;
          // Skip form errors if form check is disabled
          final bool newHasFormError = _formCheckEnabled && analysis.hasFormError;

          // Play sounds BEFORE setState (avoids any rebuild timing weirdness)
          _maybePlaySounds(
            newRepCount: newRepCount,
            newFeedback: newFeedback,
            newHasFormError: newHasFormError,
          );
          _trackFormIssues(
            feedback: newFeedback,
            hasFormError: newHasFormError,
            currentRepCount: newRepCount,
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
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    const darkModeGreen = Color(0xFF039E39);
    const lightModeGreen = Color(0xFF094941);
    final accentColor = isDark ? darkModeGreen : lightModeGreen;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Column(
          children: [
            Text(
              widget.exerciseName,
              style: const TextStyle(color: Colors.white),
            ),
            const Text(
              'build: 2026-04-05 v8',
              style: TextStyle(color: Colors.white54, fontSize: 11),
            ),
          ],
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (_cameraService.cameras.length > 1)
            IconButton(
              icon: const Icon(Icons.flip_camera_ios, color: Colors.white),
              onPressed: _cameraService.isInitialized ? _switchCamera : null,
            ),

          // Bar toggle
          IconButton(
            tooltip: _showBar ? 'Hide bar' : 'Show bar',
            icon: Icon(
              Icons.horizontal_rule,
              color: _showBar ? Colors.orangeAccent : Colors.grey,
            ),
            onPressed: () {
              setState(() {
                _showBar = !_showBar;
              });
            },
          ),

          // Form check toggle
          IconButton(
            tooltip: _formCheckEnabled ? 'Disable form checks' : 'Enable form checks',
            icon: Icon(
              _formCheckEnabled ? Icons.fact_check : Icons.fact_check_outlined,
              color: _formCheckEnabled ? Colors.greenAccent : Colors.grey,
            ),
            onPressed: () {
              setState(() {
                _formCheckEnabled = !_formCheckEnabled;
              });
            },
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
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          : !_cameraService.isInitialized
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: accentColor),
                      const SizedBox(height: 16),
                      const Text(
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
                          exerciseName: widget.exerciseName,
                          showBar: _showBar,
                        ),
                        size: Size.infinite,
                      ),

                    // Countdown Overlay
                    if (_countdownActive)
                      Center(
                        child: Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.75),
                            shape: BoxShape.circle,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '$_countdownValue',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 72,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Text(
                                'Get ready',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // Stats Overlay
                    if (!_countdownActive)
                      Positioned(
                        top: 12,
                        left: 16,
                        right: 16,
                        child: SafeArea(
                          bottom: false,
                          child: WorkoutStatsOverlay(
                            repCount: _repCount,
                            feedback: _feedback,
                            phase: _currentPhase,
                            hasError: _hasFormError,
                          ),
                        ),
                      ),

                    // Nod counter indicator
                    if (_shakeCount > 0)
                      Positioned(
                        bottom: 110,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Shake to stop: $_shakeCount/$_shakesRequired',
                              style: const TextStyle(color: Colors.white, fontSize: 14),
                            ),
                          ),
                        ),
                      ),

                    // Finish Button
                    Positioned(
                      bottom: 40,
                      left: 20,
                      right: 20,
                      child: FinishWorkoutButton(
                        onPressed: _finishWorkout,
                        isDarkMode: isDark,
                      ),
                    ),
                  ],
                ),
    );
  }

  @override
  void dispose() {
    print('CameraWorkoutPage: dispose called');
    _setupTimer?.cancel();
    _cameraService.dispose();
    _poseDetector.dispose();
    _soundService.dispose();
    super.dispose();
  }
}

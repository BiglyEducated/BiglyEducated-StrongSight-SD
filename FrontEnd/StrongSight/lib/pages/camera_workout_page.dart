import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import '../services/pose_detector_service.dart';
import '../services/camera_utils.dart';
import 'dart:io' show Platform;

class CameraWorkoutPage extends StatefulWidget {
  final String exerciseName;

  const CameraWorkoutPage({super.key, required this.exerciseName});

  @override
  State<CameraWorkoutPage> createState() => _CameraWorkoutPageState();
}

class _CameraWorkoutPageState extends State<CameraWorkoutPage> {
  CameraController? _cameraController;
  final PoseDetectorService _poseDetector = PoseDetectorService();
  
  bool _isDetecting = false;
  bool _isCameraInitialized = false;
  bool _isProcessing = false;
  int _repCount = 0;
  String _feedback = 'Position yourself in frame';
  String _currentPhase = 'standing';
  
  List<Pose> _detectedPoses = [];
  int _frameSkipCounter = 0;
  static const int _frameSkipRate = 3;
  
  // Camera selection
  List<CameraDescription> _availableCameras = [];
  int _currentCameraIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      _availableCameras = await availableCameras();
      
      // Start with back camera (index 0 is usually back camera)
      _currentCameraIndex = _availableCameras.indexWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back
      );
      
      // If no back camera found, use first available
      if (_currentCameraIndex == -1) {
        _currentCameraIndex = 0;
      }

      await _setupCamera(_availableCameras[_currentCameraIndex]);
    } catch (e) {
      print('Error initializing camera: $e');
      if (mounted) {
        setState(() {
          _feedback = 'Camera initialization failed';
        });
      }
    }
  }

  Future<void> _setupCamera(CameraDescription camera) async {
    // Dispose of previous controller if exists
    await _cameraController?.dispose();

    _cameraController = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: Platform.isIOS 
          ? ImageFormatGroup.bgra8888
          : ImageFormatGroup.nv21,
    );

    await _cameraController!.initialize();
    
    if (!mounted) return;

    // Initialize pose detector if not already initialized
    if (!_poseDetector.isInitialized) {
      await _poseDetector.initialize();
    }

    setState(() {
      _isCameraInitialized = true;
    });

    // Start processing frames with a small delay
    await Future.delayed(const Duration(milliseconds: 500));
    _cameraController!.startImageStream(_processCameraImage);
  }

  Future<void> _switchCamera() async {
    if (_availableCameras.length < 2) return;

    // Stop current stream
    await _cameraController?.stopImageStream();
    
    setState(() {
      _isCameraInitialized = false;
    });

    // Switch to next camera
    _currentCameraIndex = (_currentCameraIndex + 1) % _availableCameras.length;
    
    await _setupCamera(_availableCameras[_currentCameraIndex]);
  }

  Future<void> _processCameraImage(CameraImage image) async {
    // Skip frames to reduce processing load
    _frameSkipCounter++;
    if (_frameSkipCounter % _frameSkipRate != 0) {
      return;
    }

    if (_isDetecting || _isProcessing) return;
    
    _isDetecting = true;
    _isProcessing = true;

    try {
      // Get the correct rotation
      final rotation = getImageRotation(_cameraController!);
      
      // Detect poses
      final poses = await _poseDetector.detectPoses(image, rotation);
      
      if (!mounted) return;
      
      if (poses.isNotEmpty) {
        final pose = poses.first;
        
        // Analyze form based on exercise type
        if (widget.exerciseName == 'Squat') {
          final analysis = _poseDetector.analyzeSquatForm(pose);
          
          if (analysis['isValid']) {
            // Detect rep completion
            if (_currentPhase == 'standing' && analysis['phase'] == 'parallel') {
              if (mounted) {
                setState(() {
                  _currentPhase = 'parallel';
                });
              }
            } else if (_currentPhase == 'parallel' && analysis['phase'] == 'standing') {
              if (mounted) {
                setState(() {
                  _repCount++;
                  _currentPhase = 'standing';
                });
              }
            }
            
            if (mounted) {
              setState(() {
                _feedback = analysis['feedback'];
                _detectedPoses = poses;
              });
            }
          }
        }
      } else {
        // No poses detected
        if (mounted) {
          setState(() {
            _detectedPoses = [];
            _feedback = 'Position yourself in frame';
          });
        }
      }
    } catch (e) {
      print('Error processing image: $e');
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
          // Camera switch button
          if (_availableCameras.length > 1)
            IconButton(
              icon: const Icon(Icons.flip_camera_ios, color: Colors.white),
              onPressed: _isCameraInitialized ? _switchCamera : null,
            ),
        ],
      ),
      body: !_isCameraInitialized
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
                // Camera Preview - FULL SCREEN
                Center(
                  child: CameraPreview(_cameraController!),
                ),
                
                // Pose Overlay - matches camera preview exactly
                if (_detectedPoses.isNotEmpty && _cameraController != null)
                  CustomPaint(
                    painter: PosePainter(
                      poses: _detectedPoses,
                      imageSize: Size(
                        _cameraController!.value.previewSize!.width,
                        _cameraController!.value.previewSize!.height,
                      ),
                      rotation: getImageRotation(_cameraController!),
                      isBackCamera: _cameraController!.description.lensDirection == CameraLensDirection.back,
                      screenSize: screenSize,
                    ),
                    size: Size.infinite,
                  ),
                
                // Stats Overlay
                Positioned(
                  top: 20,
                  left: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Reps: $_repCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _feedback,
                          style: const TextStyle(
                            color: Colors.greenAccent,
                            fontSize: 18,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Finish Button
                Positioned(
                  bottom: 40,
                  left: 20,
                  right: 20,
                  child: ElevatedButton(
                    onPressed: () async {
                      await _cameraController?.stopImageStream();
                      if (mounted) {
                        Navigator.pop(context, _repCount);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF039E39),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Finish Workout',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _poseDetector.dispose();
    super.dispose();
  }
}

// Custom painter to draw pose landmarks
class PosePainter extends CustomPainter {
  final List<Pose> poses;
  final Size imageSize;
  final InputImageRotation rotation;
  final bool isBackCamera;
  final Size screenSize;

  PosePainter({
    required this.poses,
    required this.imageSize,
    required this.rotation,
    required this.isBackCamera,
    required this.screenSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.greenAccent
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke;

    final pointPaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 8.0
      ..style = PaintingStyle.fill;

    for (final pose in poses) {
      // Draw connections
      _drawLine(canvas, paint, pose, PoseLandmarkType.leftShoulder, PoseLandmarkType.rightShoulder);
      _drawLine(canvas, paint, pose, PoseLandmarkType.leftShoulder, PoseLandmarkType.leftHip);
      _drawLine(canvas, paint, pose, PoseLandmarkType.rightShoulder, PoseLandmarkType.rightHip);
      _drawLine(canvas, paint, pose, PoseLandmarkType.leftHip, PoseLandmarkType.rightHip);
      
      // Arms
      _drawLine(canvas, paint, pose, PoseLandmarkType.leftShoulder, PoseLandmarkType.leftElbow);
      _drawLine(canvas, paint, pose, PoseLandmarkType.leftElbow, PoseLandmarkType.leftWrist);
      _drawLine(canvas, paint, pose, PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow);
      _drawLine(canvas, paint, pose, PoseLandmarkType.rightElbow, PoseLandmarkType.rightWrist);
      
      // Legs
      _drawLine(canvas, paint, pose, PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee);
      _drawLine(canvas, paint, pose, PoseLandmarkType.leftKnee, PoseLandmarkType.leftAnkle);
      _drawLine(canvas, paint, pose, PoseLandmarkType.rightHip, PoseLandmarkType.rightKnee);
      _drawLine(canvas, paint, pose, PoseLandmarkType.rightKnee, PoseLandmarkType.rightAnkle);
      
      // Draw points
      for (final landmark in pose.landmarks.values) {
        final point = _translatePoint(landmark.x, landmark.y);
        if (point != null) {
          canvas.drawCircle(point, 4, pointPaint);
        }
      }
    }
  }

  void _drawLine(Canvas canvas, Paint paint, Pose pose, PoseLandmarkType start, PoseLandmarkType end) {
    final startLandmark = pose.landmarks[start];
    final endLandmark = pose.landmarks[end];
    
    if (startLandmark != null && endLandmark != null) {
      final startPoint = _translatePoint(startLandmark.x, startLandmark.y);
      final endPoint = _translatePoint(endLandmark.x, endLandmark.y);
      
      if (startPoint != null && endPoint != null) {
        canvas.drawLine(startPoint, endPoint, paint);
      }
    }
  }

  Offset? _translatePoint(double x, double y) {
    // Calculate the actual display size of the camera preview
    // The camera preview maintains aspect ratio and may be letterboxed
    
    double imageAspectRatio = imageSize.width / imageSize.height;
    double screenAspectRatio = screenSize.width / screenSize.height;
    
    double scaleX, scaleY, offsetX, offsetY;
    
    if (imageAspectRatio > screenAspectRatio) {
      // Image is wider - letterbox on top/bottom
      scaleX = screenSize.width / imageSize.width;
      scaleY = scaleX;
      offsetX = 0;
      offsetY = (screenSize.height - (imageSize.height * scaleY)) / 2;
    } else {
      // Image is taller - letterbox on left/right
      scaleY = screenSize.height / imageSize.height;
      scaleX = scaleY;
      offsetX = (screenSize.width - (imageSize.width * scaleX)) / 2;
      offsetY = 0;
    }
    
    // Apply scaling and offset
    double translatedX = (x * scaleX) + offsetX;
    double translatedY = (y * scaleY) + offsetY;
    
    // Mirror for front camera
    if (!isBackCamera) {
      translatedX = screenSize.width - translatedX;
    }
    
    return Offset(translatedX, translatedY);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

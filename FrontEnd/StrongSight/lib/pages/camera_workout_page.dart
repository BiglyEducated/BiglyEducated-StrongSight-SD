import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import '../services/pose_detector_service.dart';
import 'dart:math';

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
  int _repCount = 0;
  String _feedback = 'Position yourself in frame';
  String _currentPhase = 'standing';
  
  List<Pose> _detectedPoses = [];

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.nv21,
      );

      await _cameraController!.initialize();
      await _poseDetector.initialize();

      setState(() {
        _isCameraInitialized = true;
      });

      // Start processing frames
      _cameraController!.startImageStream(_processCameraImage);
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  Future<void> _processCameraImage(CameraImage image) async {
    if (_isDetecting) return;
    
    _isDetecting = true;

    try {
      final rotation = InputImageRotation.rotation0deg;
      final poses = await _poseDetector.detectPoses(image, rotation);
      
      if (poses.isNotEmpty) {
        final pose = poses.first;
        
        // Analyze form based on exercise type
        if (widget.exerciseName == 'Squat') {
          final analysis = _poseDetector.analyzeSquatForm(pose);
          
          if (analysis['isValid']) {
            // Detect rep completion
            if (_currentPhase == 'standing' && analysis['phase'] == 'parallel') {
              setState(() {
                _currentPhase = 'parallel';
              });
            } else if (_currentPhase == 'parallel' && analysis['phase'] == 'standing') {
              setState(() {
                _repCount++;
                _currentPhase = 'standing';
              });
            }
            
            setState(() {
              _feedback = analysis['feedback'];
              _detectedPoses = poses;
            });
          }
        }
      }
    } catch (e) {
      print('Error processing image: $e');
    } finally {
      _isDetecting = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          widget.exerciseName,
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: !_isCameraInitialized
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                // Camera Preview
                Center(
                  child: CameraPreview(_cameraController!),
                ),
                
                // Pose Overlay
                if (_detectedPoses.isNotEmpty)
                  CustomPaint(
                    painter: PosePainter(
                      poses: _detectedPoses,
                      cameraSize: _cameraController!.value.previewSize!,
                      rotation: InputImageRotation.rotation90deg,
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
                    onPressed: () {
                      Navigator.pop(context, _repCount);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF039E39),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Finish Workout',
                      style: TextStyle(fontSize: 18),
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
  final Size cameraSize;
  final InputImageRotation rotation; // Add this parameter

  PosePainter({
    required this.poses, 
    required this.cameraSize,
    required this.rotation, // Add this
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
      _drawLine(canvas, paint, pose, PoseLandmarkType.leftShoulder, PoseLandmarkType.rightShoulder, size);
      _drawLine(canvas, paint, pose, PoseLandmarkType.leftShoulder, PoseLandmarkType.leftHip, size);
      _drawLine(canvas, paint, pose, PoseLandmarkType.rightShoulder, PoseLandmarkType.rightHip, size);
      _drawLine(canvas, paint, pose, PoseLandmarkType.leftHip, PoseLandmarkType.rightHip, size);
      
      // Legs
      _drawLine(canvas, paint, pose, PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee, size);
      _drawLine(canvas, paint, pose, PoseLandmarkType.leftKnee, PoseLandmarkType.leftAnkle, size);
      _drawLine(canvas, paint, pose, PoseLandmarkType.rightHip, PoseLandmarkType.rightKnee, size);
      _drawLine(canvas, paint, pose, PoseLandmarkType.rightKnee, PoseLandmarkType.rightAnkle, size);
      
      // Draw points
      for (final landmark in pose.landmarks.values) {
        final point = _translatePoint(landmark.x, landmark.y, size);
        canvas.drawCircle(point, 4, pointPaint);
      }
    }
  }

  void _drawLine(Canvas canvas, Paint paint, Pose pose, PoseLandmarkType start, PoseLandmarkType end, Size size) {
    final startLandmark = pose.landmarks[start];
    final endLandmark = pose.landmarks[end];
    
    if (startLandmark != null && endLandmark != null) {
      final startPoint = _translatePoint(startLandmark.x, startLandmark.y, size);
      final endPoint = _translatePoint(endLandmark.x, endLandmark.y, size);
      canvas.drawLine(startPoint, endPoint, paint);
    }
  }

  Offset _translatePoint(double x, double y, Size size) {
    // Account for rotation
    switch (rotation) {
      case InputImageRotation.rotation0deg:
        return Offset(
          x * size.width / cameraSize.width,
          y * size.height / cameraSize.height,
        );
      case InputImageRotation.rotation90deg:
        return Offset(
          size.width - (y * size.width / cameraSize.height),
          x * size.height / cameraSize.width,
        );
      case InputImageRotation.rotation180deg:
        return Offset(
          size.width - (x * size.width / cameraSize.width),
          size.height - (y * size.height / cameraSize.height),
        );
      case InputImageRotation.rotation270deg:
        return Offset(
          y * size.width / cameraSize.height,
          size.height - (x * size.height / cameraSize.width),
        );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
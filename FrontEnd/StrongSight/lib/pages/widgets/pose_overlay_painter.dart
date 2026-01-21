import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

/// Custom painter for drawing pose skeleton overlay
class PoseOverlayPainter extends CustomPainter {
  final List<Pose> poses;
  final Size imageSize;
  final InputImageRotation rotation;
  final bool isBackCamera;
  final Size screenSize;

  PoseOverlayPainter({
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

    final legPaint = Paint()
      ..color = Colors.cyanAccent
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke;

    final pointPaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 8.0
      ..style = PaintingStyle.fill;

    for (final pose in poses) {
      // Draw torso
      _drawLine(canvas, paint, pose, PoseLandmarkType.leftShoulder, PoseLandmarkType.rightShoulder);
      _drawLine(canvas, paint, pose, PoseLandmarkType.leftShoulder, PoseLandmarkType.leftHip);
      _drawLine(canvas, paint, pose, PoseLandmarkType.rightShoulder, PoseLandmarkType.rightHip);
      _drawLine(canvas, paint, pose, PoseLandmarkType.leftHip, PoseLandmarkType.rightHip);
      
      // Draw arms
      _drawLine(canvas, paint, pose, PoseLandmarkType.leftShoulder, PoseLandmarkType.leftElbow);
      _drawLine(canvas, paint, pose, PoseLandmarkType.leftElbow, PoseLandmarkType.leftWrist);
      _drawLine(canvas, paint, pose, PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow);
      _drawLine(canvas, paint, pose, PoseLandmarkType.rightElbow, PoseLandmarkType.rightWrist);
      
      // Draw legs (highlighted for squat tracking)
      _drawLine(canvas, legPaint, pose, PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee);
      _drawLine(canvas, legPaint, pose, PoseLandmarkType.leftKnee, PoseLandmarkType.leftAnkle);
      _drawLine(canvas, legPaint, pose, PoseLandmarkType.rightHip, PoseLandmarkType.rightKnee);
      _drawLine(canvas, legPaint, pose, PoseLandmarkType.rightKnee, PoseLandmarkType.rightAnkle);
      
      // Draw joint points
      for (final landmark in pose.landmarks.values) {
        final point = _translatePoint(landmark.x, landmark.y);
        if (point != null) {
          canvas.drawCircle(point, 4, pointPaint);
        }
      }
    }
  }

  void _drawLine(
    Canvas canvas,
    Paint paint,
    Pose pose,
    PoseLandmarkType start,
    PoseLandmarkType end,
  ) {
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
    // Calculate aspect ratios
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

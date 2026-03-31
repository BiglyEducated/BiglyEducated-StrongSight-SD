import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

/// Custom painter for drawing pose skeleton overlay
class PoseOverlayPainter extends CustomPainter {
  final List<Pose> poses;
  final Size imageSize;
  final InputImageRotation rotation;
  final bool isBackCamera;

  PoseOverlayPainter({
    required this.poses,
    required this.imageSize,
    required this.rotation,
    required this.isBackCamera,
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
      _drawLine(
        canvas,
        paint,
        pose,
        PoseLandmarkType.leftShoulder,
        PoseLandmarkType.rightShoulder,
        size,
      );
      _drawLine(
        canvas,
        paint,
        pose,
        PoseLandmarkType.leftShoulder,
        PoseLandmarkType.leftHip,
        size,
      );
      _drawLine(
        canvas,
        paint,
        pose,
        PoseLandmarkType.rightShoulder,
        PoseLandmarkType.rightHip,
        size,
      );
      _drawLine(
        canvas,
        paint,
        pose,
        PoseLandmarkType.leftHip,
        PoseLandmarkType.rightHip,
        size,
      );
      
      // Draw arms
      _drawLine(
        canvas,
        paint,
        pose,
        PoseLandmarkType.leftShoulder,
        PoseLandmarkType.leftElbow,
        size,
      );
      _drawLine(
        canvas,
        paint,
        pose,
        PoseLandmarkType.leftElbow,
        PoseLandmarkType.leftWrist,
        size,
      );
      _drawLine(
        canvas,
        paint,
        pose,
        PoseLandmarkType.rightShoulder,
        PoseLandmarkType.rightElbow,
        size,
      );
      _drawLine(
        canvas,
        paint,
        pose,
        PoseLandmarkType.rightElbow,
        PoseLandmarkType.rightWrist,
        size,
      );
      
      // Draw legs (highlighted for squat tracking)
      _drawLine(
        canvas,
        legPaint,
        pose,
        PoseLandmarkType.leftHip,
        PoseLandmarkType.leftKnee,
        size,
      );
      _drawLine(
        canvas,
        legPaint,
        pose,
        PoseLandmarkType.leftKnee,
        PoseLandmarkType.leftAnkle,
        size,
      );
      _drawLine(
        canvas,
        legPaint,
        pose,
        PoseLandmarkType.rightHip,
        PoseLandmarkType.rightKnee,
        size,
      );
      _drawLine(
        canvas,
        legPaint,
        pose,
        PoseLandmarkType.rightKnee,
        PoseLandmarkType.rightAnkle,
        size,
      );
      
      // Draw joint points
      for (final landmark in pose.landmarks.values) {
        final point = _translatePoint(landmark.x, landmark.y, size);
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
    Size canvasSize,
  ) {
    final startLandmark = pose.landmarks[start];
    final endLandmark = pose.landmarks[end];
    
    if (startLandmark != null && endLandmark != null) {
      final startPoint = _translatePoint(startLandmark.x, startLandmark.y, canvasSize);
      final endPoint = _translatePoint(endLandmark.x, endLandmark.y, canvasSize);
      
      if (startPoint != null && endPoint != null) {
        canvas.drawLine(startPoint, endPoint, paint);
      }
    }
  }

  Offset? _translatePoint(double x, double y, Size canvasSize) {
    // Calculate aspect ratios
    double imageAspectRatio = imageSize.width / imageSize.height;
    double screenAspectRatio = canvasSize.width / canvasSize.height;
    
    double scaleX, scaleY, offsetX, offsetY;
    
    if (imageAspectRatio > screenAspectRatio) {
      // Image is wider - letterbox on top/bottom
      scaleX = canvasSize.width / imageSize.width;
      scaleY = scaleX;
      offsetX = 0;
      offsetY = (canvasSize.height - (imageSize.height * scaleY)) / 2;
    } else {
      // Image is taller - letterbox on left/right
      scaleY = canvasSize.height / imageSize.height;
      scaleX = scaleY;
      offsetX = (canvasSize.width - (imageSize.width * scaleX)) / 2;
      offsetY = 0;
    }
    
    // Apply scaling and offset
    double translatedX = (x * scaleX) + offsetX;
    double translatedY = (y * scaleY) + offsetY;
    
    // DON'T mirror for front camera - ML Kit already provides mirrored coordinates
    // The camera preview is mirrored, and ML Kit matches that
    // So we just use the coordinates as-is
    
    return Offset(translatedX, translatedY);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

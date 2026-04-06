import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

/// Custom painter for drawing pose skeleton overlay
class PoseOverlayPainter extends CustomPainter {
  static const double _verticalShiftPx = -60.0;

  final List<Pose> poses;
  final Size imageSize;
  final InputImageRotation rotation;
  final bool isBackCamera;
  final String exerciseName;
  final bool showBar;

  PoseOverlayPainter({
    required this.poses,
    required this.imageSize,
    required this.rotation,
    required this.isBackCamera,
    this.exerciseName = '',
    this.showBar = true,
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

      // Draw simulated barbell between wrists
      if (showBar) _drawBar(canvas, pose, size);
    }
  }

  void _drawBar(Canvas canvas, Pose pose, Size size) {
    final leftWrist = pose.landmarks[PoseLandmarkType.leftWrist];
    final rightWrist = pose.landmarks[PoseLandmarkType.rightWrist];
    if (leftWrist == null || rightWrist == null) return;
    if (leftWrist.likelihood < 0.5 || rightWrist.likelihood < 0.5) return;

    final leftPt = _translatePoint(leftWrist.x, leftWrist.y, size);
    final rightPt = _translatePoint(rightWrist.x, rightWrist.y, size);
    if (leftPt == null || rightPt == null) return;

    // Extend bar slightly beyond each wrist
    final direction = (rightPt - leftPt);
    final length = direction.distance;
    if (length == 0) return;
    final unit = direction / length;
    final extension = 24.0;
    final barStart = leftPt - unit * extension;
    final barEnd = rightPt + unit * extension;

    // Bar shaft
    final barPaint = Paint()
      ..color = Colors.grey[300]!
      ..strokeWidth = 6.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(barStart, barEnd, barPaint);

    // Collar rings at each end
    final collarPaint = Paint()
      ..color = Colors.grey[500]!
      ..strokeWidth = 10.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.butt;
    final collarOffset = extension * 0.5;
    canvas.drawLine(
      barStart + unit * collarOffset - Offset(-unit.dy, unit.dx) * 4,
      barStart + unit * collarOffset + Offset(-unit.dy, unit.dx) * 4,
      collarPaint,
    );
    canvas.drawLine(
      barEnd - unit * collarOffset - Offset(-unit.dy, unit.dx) * 4,
      barEnd - unit * collarOffset + Offset(-unit.dy, unit.dx) * 4,
      collarPaint,
    );
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
    double translatedY = (y * scaleY) + offsetY + _verticalShiftPx;
    
    // DON'T mirror for front camera - ML Kit already provides mirrored coordinates
    // The camera preview is mirrored, and ML Kit matches that
    // So we just use the coordinates as-is
    
    return Offset(translatedX, translatedY);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

import 'dart:math';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

/// Handles all angle calculations for pose analysis
class AngleCalculator {
  /// Calculate angle between three points using vectors
  /// 
  /// Formula: angle = arctan2(B - V) - arctan2(A - V)
  /// Where V is the vertex (central joint), A and B are outer points
  /// 
  /// Example for squat: A=Hip, V=Knee, B=Ankle
  /// [cite: 1253, 1266]
  static double calculateAngle(
    PoseLandmark pointA,
    PoseLandmark vertex,
    PoseLandmark pointB,
  ) {
    double angle = (atan2(pointB.y - vertex.y, pointB.x - vertex.x) - 
                    atan2(pointA.y - vertex.y, pointA.x - vertex.x)) * (180 / pi);
    
    // Normalize to 0-180 degrees
    return angle.abs() > 180 ? 360 - angle.abs() : angle.abs();
  }

  /// Calculate angle with null safety checks
  static double? calculateAngleSafe(
    PoseLandmark? pointA,
    PoseLandmark? vertex,
    PoseLandmark? pointB,
  ) {
    if (pointA == null || vertex == null || pointB == null) {
      return null;
    }
    return calculateAngle(pointA, vertex, pointB);
  }

  /// Calculate angle and check confidence threshold
  static double? calculateAngleWithConfidence(
    PoseLandmark? pointA,
    PoseLandmark? vertex,
    PoseLandmark? pointB, {
    double confidenceThreshold = 0.7,
  }) {
    if (pointA == null || vertex == null || pointB == null) {
      return null;
    }
    
    // Check if all landmarks meet confidence threshold
    if (vertex.likelihood < confidenceThreshold ||
        pointA.likelihood < confidenceThreshold ||
        pointB.likelihood < confidenceThreshold) {
      return null;
    }
    
    return calculateAngle(pointA, vertex, pointB);
  }

  /// Calculate distance between two landmarks
  static double calculateDistance(PoseLandmark a, PoseLandmark b) {
    double dx = a.x - b.x;
    double dy = a.y - b.y;
    return sqrt(dx * dx + dy * dy);
  }

  /// Calculate horizontal distance (x-axis only)
  static double calculateHorizontalDistance(PoseLandmark a, PoseLandmark b) {
    return (a.x - b.x).abs();
  }

  /// Calculate vertical distance (y-axis only)
  static double calculateVerticalDistance(PoseLandmark a, PoseLandmark b) {
    return (a.y - b.y).abs();
  }
}

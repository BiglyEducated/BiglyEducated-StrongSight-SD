import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import '../models/exercise_config.dart';
import 'angle_calculator.dart';

/// Handles form validation and error detection for exercises
class FormChecker {
  // Knee cave detection state
  int _kneeCaveFrameCount = 0;
  static const int _kneeCaveThresholdFrames = 3;
  static const double _kneeCaveRatio = 0.75;
  static const double _minConfidence = 0.6;

  /// Reset form checker state (call when starting new exercise)
  void reset() {
    _kneeCaveFrameCount = 0;
  }

  /// Check for knee cave during squat
  /// 
  /// Compares knee distance to ankle distance
  /// Ratio < 0.75 indicates knees collapsing inward
  /// Must persist for 3 frames to avoid false positives
  FormCheckResult checkKneeCave(
    Pose pose,
    ExerciseState currentState,
  ) {
    final leftKnee = pose.landmarks[PoseLandmarkType.leftKnee];
    final rightKnee = pose.landmarks[PoseLandmarkType.rightKnee];
    final leftAnkle = pose.landmarks[PoseLandmarkType.leftAnkle];
    final rightAnkle = pose.landmarks[PoseLandmarkType.rightAnkle];

    // Validate landmarks exist and have good confidence
    if (leftKnee == null || rightKnee == null || 
        leftAnkle == null || rightAnkle == null ||
        leftKnee.likelihood < _minConfidence || 
        rightKnee.likelihood < _minConfidence) {
      _kneeCaveFrameCount = 0;
      return FormCheckResult(
        hasError: false,
        errorMessage: null,
      );
    }

    // Only check during descent and bottom phases
    bool isRelevantPhase = currentState == ExerciseState.descent || 
                           currentState == ExerciseState.bottom;

    if (!isRelevantPhase) {
      _kneeCaveFrameCount = 0;
      return FormCheckResult(
        hasError: false,
        errorMessage: null,
      );
    }

    // Calculate knee and ankle distances
    double kneeDist = AngleCalculator.calculateHorizontalDistance(leftKnee, rightKnee);
    double ankleDist = AngleCalculator.calculateHorizontalDistance(leftAnkle, rightAnkle);

    if (ankleDist == 0) {
      _kneeCaveFrameCount = 0;
      return FormCheckResult(
        hasError: false,
        errorMessage: null,
      );
    }

    // Calculate ratio and check threshold
    double ratio = kneeDist / ankleDist;

    if (ratio < _kneeCaveRatio) {
      _kneeCaveFrameCount++;
    } else {
      _kneeCaveFrameCount = 0;
    }

    // Only flag error if it persists
    if (_kneeCaveFrameCount >= _kneeCaveThresholdFrames) {
      return FormCheckResult(
        hasError: true,
        errorMessage: "⚠️ KNEE CAVE - Push knees out!",
        errorType: FormErrorType.kneeCave,
        severity: FormErrorSeverity.warning,
      );
    }

    return FormCheckResult(
      hasError: false,
      errorMessage: null,
    );
  }

  /// Check symmetry between left and right sides
  /// [cite: 1313, 1314, 1317]
  FormCheckResult checkSymmetry(Pose pose) {
    final leftKnee = pose.landmarks[PoseLandmarkType.leftKnee];
    final rightKnee = pose.landmarks[PoseLandmarkType.rightKnee];

    if (leftKnee == null || rightKnee == null) {
      return FormCheckResult(hasError: false);
    }

    // Flag if one side lags behind by > 15 degrees
    double horizontalDiff = AngleCalculator.calculateHorizontalDistance(leftKnee, rightKnee);
    
    if (horizontalDiff > 15) {
      return FormCheckResult(
        hasError: true,
        errorMessage: "⚠️ Uneven movement - balance both sides",
        errorType: FormErrorType.asymmetry,
        severity: FormErrorSeverity.warning,
      );
    }

    return FormCheckResult(hasError: false);
  }

  /// Check if tracking confidence is sufficient
  FormCheckResult checkTrackingConfidence(
    PoseLandmark? vertex,
    PoseLandmark? pointA,
    PoseLandmark? pointB, {
    double threshold = 0.7,
  }) {
    if (vertex == null || pointA == null || pointB == null) {
      return FormCheckResult(
        hasError: true,
        errorMessage: "Low tracking confidence - adjust position",
        errorType: FormErrorType.lowConfidence,
        severity: FormErrorSeverity.info,
      );
    }

    if (vertex.likelihood < threshold) {
      return FormCheckResult(
        hasError: true,
        errorMessage: "Low tracking confidence - adjust position",
        errorType: FormErrorType.lowConfidence,
        severity: FormErrorSeverity.info,
      );
    }

    return FormCheckResult(hasError: false);
  }
}

/// Result of a form check
class FormCheckResult {
  final bool hasError;
  final String? errorMessage;
  final FormErrorType? errorType;
  final FormErrorSeverity? severity;

  FormCheckResult({
    required this.hasError,
    this.errorMessage,
    this.errorType,
    this.severity,
  });
}

/// Types of form errors
enum FormErrorType {
  kneeCave,
  asymmetry,
  lowConfidence,
  shallowDepth,
  excessiveSpeed,
}

/// Severity levels for form errors
enum FormErrorSeverity {
  info,     // Just information, not critical
  warning,  // Should correct but not dangerous
  danger,   // Could cause injury
}

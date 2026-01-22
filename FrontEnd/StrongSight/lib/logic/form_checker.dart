import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import '../models/exercise_config.dart';
import 'angle_calculator.dart';

/// Handles form validation and error detection for exercises
class FormChecker {
  // Knee cave detection state
  int _kneeCaveFrameCount = 0;
  static const int _kneeCaveThresholdFrames = 3;
  static const double _kneeCaveRatio = 0.75;
  
  // Symmetry detection state
  int _asymmetryFrameCount = 0;
  static const int _asymmetryThresholdFrames = 5; // Increased from 3 to 5 (less sensitive)
  static const double _asymmetryAngleDiff = 20.0; // Increased from 15.0 to 20.0 (less sensitive)
  
  // Forward lean detection
  int _forwardLeanFrameCount = 0;
  static const int _forwardLeanThresholdFrames = 3; // Decreased from 4 to 3 (more sensitive)
  static const double _forwardLeanRatio = 0.75; // Increased from 0.7 to 0.75 (more sensitive)
  
  // ERROR PERSISTENCE - Keep showing error for longer
  String? _lastErrorMessage;
  FormErrorType? _lastErrorType;
  int _errorDisplayFrames = 0;
  static const int _errorPersistFrames = 15; // Show error for ~1.5 seconds (15 frames)
  
  static const double _minConfidence = 0.6;

  /// Reset form checker state (call when starting new exercise)
  void reset() {
    _kneeCaveFrameCount = 0;
    _asymmetryFrameCount = 0;
    _forwardLeanFrameCount = 0;
    _lastErrorMessage = null;
    _lastErrorType = null;
    _errorDisplayFrames = 0;
  }

  /// Check for knee cave during squat
  FormCheckResult checkKneeCave(
    Pose pose,
    ExerciseState currentState,
  ) {
    final leftKnee = pose.landmarks[PoseLandmarkType.leftKnee];
    final rightKnee = pose.landmarks[PoseLandmarkType.rightKnee];
    final leftAnkle = pose.landmarks[PoseLandmarkType.leftAnkle];
    final rightAnkle = pose.landmarks[PoseLandmarkType.rightAnkle];

    if (leftKnee == null || rightKnee == null || 
        leftAnkle == null || rightAnkle == null ||
        leftKnee.likelihood < _minConfidence || 
        rightKnee.likelihood < _minConfidence) {
      _kneeCaveFrameCount = 0;
      return FormCheckResult(hasError: false);
    }

    bool isRelevantPhase = currentState == ExerciseState.descent || 
                           currentState == ExerciseState.bottom;

    if (!isRelevantPhase) {
      _kneeCaveFrameCount = 0;
      return FormCheckResult(hasError: false);
    }

    double kneeDist = AngleCalculator.calculateHorizontalDistance(leftKnee, rightKnee);
    double ankleDist = AngleCalculator.calculateHorizontalDistance(leftAnkle, rightAnkle);

    if (ankleDist == 0) {
      _kneeCaveFrameCount = 0;
      return FormCheckResult(hasError: false);
    }

    double ratio = kneeDist / ankleDist;

    if (ratio < _kneeCaveRatio) {
      _kneeCaveFrameCount++;
    } else {
      _kneeCaveFrameCount = 0;
    }

    if (_kneeCaveFrameCount >= _kneeCaveThresholdFrames) {
      return FormCheckResult(
        hasError: true,
        errorMessage: "⚠️ KNEE CAVE - Push knees out!",
        errorType: FormErrorType.kneeCave,
        severity: FormErrorSeverity.warning,
      );
    }

    return FormCheckResult(hasError: false);
  }

  /// Check for forward lean during squat (MORE SENSITIVE NOW)
  /// 
  /// From the front, we can detect if torso is leaning too far forward
  /// by comparing the vertical distance from shoulder to hip vs hip to knee
  FormCheckResult checkForwardLean(
    Pose pose,
    ExerciseState currentState,
  ) {
    final leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final rightShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
    final leftHip = pose.landmarks[PoseLandmarkType.leftHip];
    final rightHip = pose.landmarks[PoseLandmarkType.rightHip];
    final leftKnee = pose.landmarks[PoseLandmarkType.leftKnee];
    final rightKnee = pose.landmarks[PoseLandmarkType.rightKnee];

    if (leftShoulder == null || rightShoulder == null ||
        leftHip == null || rightHip == null ||
        leftKnee == null || rightKnee == null ||
        leftShoulder.likelihood < _minConfidence ||
        leftHip.likelihood < _minConfidence) {
      _forwardLeanFrameCount = 0;
      return FormCheckResult(hasError: false);
    }

    bool isRelevantPhase = currentState == ExerciseState.descent || 
                           currentState == ExerciseState.bottom;

    if (!isRelevantPhase) {
      _forwardLeanFrameCount = 0;
      return FormCheckResult(hasError: false);
    }

    double avgShoulderY = (leftShoulder.y + rightShoulder.y) / 2;
    double avgHipY = (leftHip.y + rightHip.y) / 2;
    double avgKneeY = (leftKnee.y + rightKnee.y) / 2;

    double shoulderToHipDist = (avgHipY - avgShoulderY).abs();
    double hipToKneeDist = (avgKneeY - avgHipY).abs();

    if (hipToKneeDist == 0) {
      _forwardLeanFrameCount = 0;
      return FormCheckResult(hasError: false);
    }

    double ratio = shoulderToHipDist / hipToKneeDist;

    // More sensitive threshold - catches forward lean earlier
    if (ratio < _forwardLeanRatio) {
      _forwardLeanFrameCount++;
      
      if (_forwardLeanFrameCount >= _forwardLeanThresholdFrames) {
        return FormCheckResult(
          hasError: true,
          errorMessage: "⚠️ FORWARD LEAN - Stay upright!",
          errorType: FormErrorType.forwardLean,
          severity: FormErrorSeverity.warning,
        );
      }
    } else {
      _forwardLeanFrameCount = 0;
    }

    return FormCheckResult(hasError: false);
  }

  /// Check symmetry between left and right sides (LESS SENSITIVE NOW)
  /// 
  /// Compares knee angles on both sides
  /// Only flags MAJOR differences (20+ degrees)
  FormCheckResult checkSymmetry(
    Pose pose,
    ExerciseState currentState,
  ) {
    final leftHip = pose.landmarks[PoseLandmarkType.leftHip];
    final leftKnee = pose.landmarks[PoseLandmarkType.leftKnee];
    final leftAnkle = pose.landmarks[PoseLandmarkType.leftAnkle];
    
    final rightHip = pose.landmarks[PoseLandmarkType.rightHip];
    final rightKnee = pose.landmarks[PoseLandmarkType.rightKnee];
    final rightAnkle = pose.landmarks[PoseLandmarkType.rightAnkle];

    if (leftHip == null || leftKnee == null || leftAnkle == null ||
        rightHip == null || rightKnee == null || rightAnkle == null ||
        leftKnee.likelihood < _minConfidence || 
        rightKnee.likelihood < _minConfidence) {
      _asymmetryFrameCount = 0;
      return FormCheckResult(hasError: false);
    }

    bool isRelevantPhase = currentState == ExerciseState.descent || 
                           currentState == ExerciseState.bottom;

    if (!isRelevantPhase) {
      _asymmetryFrameCount = 0;
      return FormCheckResult(hasError: false);
    }

    double leftKneeAngle = AngleCalculator.calculateAngle(leftHip, leftKnee, leftAnkle);
    double rightKneeAngle = AngleCalculator.calculateAngle(rightHip, rightKnee, rightAnkle);

    double angleDifference = (leftKneeAngle - rightKneeAngle).abs();

    // Less sensitive - only flag major asymmetry
    if (angleDifference > _asymmetryAngleDiff) {
      _asymmetryFrameCount++;
      
      if (_asymmetryFrameCount >= _asymmetryThresholdFrames) {
        return FormCheckResult(
          hasError: true,
          errorMessage: "⚠️ UNEVEN - Balance both sides!",
          errorType: FormErrorType.asymmetry,
          severity: FormErrorSeverity.warning,
        );
      }
    } else {
      _asymmetryFrameCount = 0;
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

  /// Run all form checks and return highest priority error with persistence
  FormCheckResult checkAllSquatForm(
    Pose pose,
    ExerciseState currentState,
  ) {
    // Check all form errors
    final kneeCaveResult = checkKneeCave(pose, currentState);
    final forwardLeanResult = checkForwardLean(pose, currentState);
    final symmetryResult = checkSymmetry(pose, currentState);

    // Find current error (if any)
    FormCheckResult? currentError;
    
    if (kneeCaveResult.hasError) {
      currentError = kneeCaveResult;
    } else if (forwardLeanResult.hasError) {
      currentError = forwardLeanResult;
    } else if (symmetryResult.hasError) {
      currentError = symmetryResult;
    }

    // ERROR PERSISTENCE LOGIC
    if (currentError != null && currentError.hasError) {
      // New error detected - set it and reset timer
      _lastErrorMessage = currentError.errorMessage;
      _lastErrorType = currentError.errorType;
      _errorDisplayFrames = _errorPersistFrames;
      
      return currentError;
    } 
    // No current error, but we have a persisting error to show
    else if (_errorDisplayFrames > 0) {
      _errorDisplayFrames--;
      
      // Keep showing the last error
      return FormCheckResult(
        hasError: true,
        errorMessage: _lastErrorMessage,
        errorType: _lastErrorType,
        severity: FormErrorSeverity.warning,
      );
    }
    // No errors at all
    else {
      _lastErrorMessage = null;
      _lastErrorType = null;
      return FormCheckResult(hasError: false);
    }
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
  forwardLean,
}

/// Severity levels for form errors
enum FormErrorSeverity {
  info,
  warning,
  danger,
}

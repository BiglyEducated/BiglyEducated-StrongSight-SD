import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import '../models/exercise_config.dart';
import 'angle_calculator.dart';

/// Handles form validation and error detection for exercises
class FormChecker {
  // SQUAT form checks
  int _kneeCaveFrameCount = 0;
  static const int _kneeCaveThresholdFrames = 3;
  static const double _kneeCaveRatio = 0.75;
  
  int _asymmetryFrameCount = 0;
  static const int _asymmetryThresholdFrames = 5;
  static const double _asymmetryAngleDiff = 20.0;
  
  int _forwardLeanFrameCount = 0;
  static const int _forwardLeanThresholdFrames = 3;
  static const double _forwardLeanRatio = 0.75;
  
  // BENCH PRESS form checks
  int _elbowFlareFrameCount = 0;
  static const int _elbowFlareThresholdFrames = 3;
  static const double _elbowFlareMaxAngle = 80.0;
  
  int _benchAsymmetryFrameCount = 0;
  static const int _benchAsymmetryThresholdFrames = 3;
  static const double _benchAsymmetryAngleDiff = 15.0;
  
  // DEADLIFT form checks
  int _backRoundingFrameCount = 0;
  static const int _backRoundingThresholdFrames = 4;
  static const double _backRoundingAngleMin = 160.0; // Spine should stay relatively straight
  
  int _deadliftAsymmetryFrameCount = 0;
  static const int _deadliftAsymmetryThresholdFrames = 4;
  static const double _deadliftAsymmetryAngleDiff = 15.0;
  
  // ERROR PERSISTENCE
  String? _lastErrorMessage;
  FormErrorType? _lastErrorType;
  int _errorDisplayFrames = 0;
  static const int _errorPersistFrames = 15;
  
  static const double _minConfidence = 0.6;

  /// Reset form checker state (call when starting new exercise)
  void reset() {
    _kneeCaveFrameCount = 0;
    _asymmetryFrameCount = 0;
    _forwardLeanFrameCount = 0;
    _elbowFlareFrameCount = 0;
    _benchAsymmetryFrameCount = 0;
    _backRoundingFrameCount = 0;
    _deadliftAsymmetryFrameCount = 0;
    _lastErrorMessage = null;
    _lastErrorType = null;
    _errorDisplayFrames = 0;
  }

  // ========== SQUAT FORM CHECKS ==========

  FormCheckResult checkKneeCave(Pose pose, ExerciseState currentState) {
    final leftKnee = pose.landmarks[PoseLandmarkType.leftKnee];
    final rightKnee = pose.landmarks[PoseLandmarkType.rightKnee];
    final leftAnkle = pose.landmarks[PoseLandmarkType.leftAnkle];
    final rightAnkle = pose.landmarks[PoseLandmarkType.rightAnkle];

    if (leftKnee == null || rightKnee == null || leftAnkle == null || rightAnkle == null ||
        leftKnee.likelihood < _minConfidence || rightKnee.likelihood < _minConfidence) {
      _kneeCaveFrameCount = 0;
      return FormCheckResult(hasError: false);
    }

    bool isRelevantPhase = currentState == ExerciseState.descent || currentState == ExerciseState.bottom;
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

  FormCheckResult checkForwardLean(Pose pose, ExerciseState currentState) {
    final leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final rightShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
    final leftHip = pose.landmarks[PoseLandmarkType.leftHip];
    final rightHip = pose.landmarks[PoseLandmarkType.rightHip];
    final leftKnee = pose.landmarks[PoseLandmarkType.leftKnee];
    final rightKnee = pose.landmarks[PoseLandmarkType.rightKnee];

    if (leftShoulder == null || rightShoulder == null || leftHip == null || rightHip == null ||
        leftKnee == null || rightKnee == null || leftShoulder.likelihood < _minConfidence ||
        leftHip.likelihood < _minConfidence) {
      _forwardLeanFrameCount = 0;
      return FormCheckResult(hasError: false);
    }

    bool isRelevantPhase = currentState == ExerciseState.descent || currentState == ExerciseState.bottom;
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

  FormCheckResult checkSquatSymmetry(Pose pose, ExerciseState currentState) {
    final leftHip = pose.landmarks[PoseLandmarkType.leftHip];
    final leftKnee = pose.landmarks[PoseLandmarkType.leftKnee];
    final leftAnkle = pose.landmarks[PoseLandmarkType.leftAnkle];
    final rightHip = pose.landmarks[PoseLandmarkType.rightHip];
    final rightKnee = pose.landmarks[PoseLandmarkType.rightKnee];
    final rightAnkle = pose.landmarks[PoseLandmarkType.rightAnkle];

    if (leftHip == null || leftKnee == null || leftAnkle == null ||
        rightHip == null || rightKnee == null || rightAnkle == null ||
        leftKnee.likelihood < _minConfidence || rightKnee.likelihood < _minConfidence) {
      _asymmetryFrameCount = 0;
      return FormCheckResult(hasError: false);
    }

    bool isRelevantPhase = currentState == ExerciseState.descent || currentState == ExerciseState.bottom;
    if (!isRelevantPhase) {
      _asymmetryFrameCount = 0;
      return FormCheckResult(hasError: false);
    }

    double leftKneeAngle = AngleCalculator.calculateAngle(leftHip, leftKnee, leftAnkle);
    double rightKneeAngle = AngleCalculator.calculateAngle(rightHip, rightKnee, rightAnkle);
    double angleDifference = (leftKneeAngle - rightKneeAngle).abs();

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

  // ========== BENCH PRESS FORM CHECKS ==========

  FormCheckResult checkElbowFlare(Pose pose, ExerciseState currentState) {
    final leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final leftElbow = pose.landmarks[PoseLandmarkType.leftElbow];
    final leftHip = pose.landmarks[PoseLandmarkType.leftHip];

    if (leftShoulder == null || leftElbow == null || leftHip == null ||
        leftShoulder.likelihood < _minConfidence || leftElbow.likelihood < _minConfidence) {
      _elbowFlareFrameCount = 0;
      return FormCheckResult(hasError: false);
    }

    bool isRelevantPhase = currentState == ExerciseState.descent || currentState == ExerciseState.bottom;
    if (!isRelevantPhase) {
      _elbowFlareFrameCount = 0;
      return FormCheckResult(hasError: false);
    }

    double elbowAngle = _calculateElbowFlareAngle(leftShoulder, leftElbow, leftHip);

    if (elbowAngle > _elbowFlareMaxAngle) {
      _elbowFlareFrameCount++;
      if (_elbowFlareFrameCount >= _elbowFlareThresholdFrames) {
        return FormCheckResult(
          hasError: true,
          errorMessage: "⚠️ ELBOW FLARE - Tuck elbows in!",
          errorType: FormErrorType.elbowFlare,
          severity: FormErrorSeverity.warning,
        );
      }
    } else {
      _elbowFlareFrameCount = 0;
    }
    return FormCheckResult(hasError: false);
  }

  FormCheckResult checkBenchSymmetry(Pose pose, ExerciseState currentState) {
    final leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final leftElbow = pose.landmarks[PoseLandmarkType.leftElbow];
    final leftWrist = pose.landmarks[PoseLandmarkType.leftWrist];
    final rightShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
    final rightElbow = pose.landmarks[PoseLandmarkType.rightElbow];
    final rightWrist = pose.landmarks[PoseLandmarkType.rightWrist];

    if (leftShoulder == null || leftElbow == null || leftWrist == null ||
        rightShoulder == null || rightElbow == null || rightWrist == null ||
        leftElbow.likelihood < _minConfidence || rightElbow.likelihood < _minConfidence) {
      _benchAsymmetryFrameCount = 0;
      return FormCheckResult(hasError: false);
    }

    bool isRelevantPhase = currentState == ExerciseState.descent || currentState == ExerciseState.bottom;
    if (!isRelevantPhase) {
      _benchAsymmetryFrameCount = 0;
      return FormCheckResult(hasError: false);
    }

    double leftElbowAngle = AngleCalculator.calculateAngle(leftShoulder, leftElbow, leftWrist);
    double rightElbowAngle = AngleCalculator.calculateAngle(rightShoulder, rightElbow, rightWrist);
    double angleDifference = (leftElbowAngle - rightElbowAngle).abs();

    if (angleDifference > _benchAsymmetryAngleDiff) {
      _benchAsymmetryFrameCount++;
      if (_benchAsymmetryFrameCount >= _benchAsymmetryThresholdFrames) {
        return FormCheckResult(
          hasError: true,
          errorMessage: "⚠️ UNEVEN ARMS - Balance the bar!",
          errorType: FormErrorType.asymmetry,
          severity: FormErrorSeverity.warning,
        );
      }
    } else {
      _benchAsymmetryFrameCount = 0;
    }
    return FormCheckResult(hasError: false);
  }

  double _calculateElbowFlareAngle(PoseLandmark shoulder, PoseLandmark elbow, PoseLandmark hip) {
    double elbowDx = elbow.x - shoulder.x;
    double elbowDy = elbow.y - shoulder.y;
    double torsoDx = hip.x - shoulder.x;
    double torsoDy = hip.y - shoulder.y;
    
    double dotProduct = elbowDx * torsoDx + elbowDy * torsoDy;
    double elbowMag = AngleCalculator.calculateDistance(shoulder, elbow);
    double torsoMag = AngleCalculator.calculateDistance(shoulder, hip);
    
    if (elbowMag == 0 || torsoMag == 0) return 0;
    
    double cosAngle = dotProduct / (elbowMag * torsoMag);
    cosAngle = cosAngle.clamp(-1.0, 1.0);
    
    return (180 / 3.14159) * (1.5708 - (cosAngle).abs().clamp(0, 1));
  }

  // ========== DEADLIFT FORM CHECKS ==========

  /// Check for back rounding during deadlift
  /// 
  /// From the side, detect if the spine is rounding (back angle too small)
  /// Spine should maintain relatively straight position
  FormCheckResult checkBackRounding(Pose pose, ExerciseState currentState) {
    final leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final leftHip = pose.landmarks[PoseLandmarkType.leftHip];
    final leftKnee = pose.landmarks[PoseLandmarkType.leftKnee];

    if (leftShoulder == null || leftHip == null || leftKnee == null ||
        leftShoulder.likelihood < _minConfidence || leftHip.likelihood < _minConfidence) {
      _backRoundingFrameCount = 0;
      return FormCheckResult(hasError: false);
    }

    // Check during descent and bottom (most dangerous for rounding)
    bool isRelevantPhase = currentState == ExerciseState.descent || currentState == ExerciseState.bottom;
    if (!isRelevantPhase) {
      _backRoundingFrameCount = 0;
      return FormCheckResult(hasError: false);
    }

    // Calculate shoulder-hip-knee angle (spine angle)
    double spineAngle = AngleCalculator.calculateAngle(leftShoulder, leftHip, leftKnee);

    // If spine angle is too small, back is rounding
    if (spineAngle < _backRoundingAngleMin) {
      _backRoundingFrameCount++;
      if (_backRoundingFrameCount >= _backRoundingThresholdFrames) {
        return FormCheckResult(
          hasError: true,
          errorMessage: "⚠️ BACK ROUNDING - Keep spine neutral!",
          errorType: FormErrorType.backRounding,
          severity: FormErrorSeverity.danger,
        );
      }
    } else {
      _backRoundingFrameCount = 0;
    }
    return FormCheckResult(hasError: false);
  }

  /// Check hip symmetry for deadlift (left vs right side)
  /// 
  /// From the front, check if hips are level (not tilted)
  FormCheckResult checkDeadliftSymmetry(Pose pose, ExerciseState currentState) {
    final leftHip = pose.landmarks[PoseLandmarkType.leftHip];
    final leftKnee = pose.landmarks[PoseLandmarkType.leftKnee];
    final leftAnkle = pose.landmarks[PoseLandmarkType.leftAnkle];
    final rightHip = pose.landmarks[PoseLandmarkType.rightHip];
    final rightKnee = pose.landmarks[PoseLandmarkType.rightKnee];
    final rightAnkle = pose.landmarks[PoseLandmarkType.rightAnkle];

    if (leftHip == null || leftKnee == null || leftAnkle == null ||
        rightHip == null || rightKnee == null || rightAnkle == null ||
        leftHip.likelihood < _minConfidence || rightHip.likelihood < _minConfidence) {
      _deadliftAsymmetryFrameCount = 0;
      return FormCheckResult(hasError: false);
    }

    bool isRelevantPhase = currentState == ExerciseState.descent || 
                           currentState == ExerciseState.bottom ||
                           currentState == ExerciseState.ascending;
    if (!isRelevantPhase) {
      _deadliftAsymmetryFrameCount = 0;
      return FormCheckResult(hasError: false);
    }

    // Compare left and right hip angles
    double leftHipAngle = AngleCalculator.calculateAngle(leftHip, leftKnee, leftAnkle);
    double rightHipAngle = AngleCalculator.calculateAngle(rightHip, rightKnee, rightAnkle);
    double angleDifference = (leftHipAngle - rightHipAngle).abs();

    if (angleDifference > _deadliftAsymmetryAngleDiff) {
      _deadliftAsymmetryFrameCount++;
      if (_deadliftAsymmetryFrameCount >= _deadliftAsymmetryThresholdFrames) {
        return FormCheckResult(
          hasError: true,
          errorMessage: "⚠️ UNEVEN HIPS - Keep hips level!",
          errorType: FormErrorType.asymmetry,
          severity: FormErrorSeverity.warning,
        );
      }
    } else {
      _deadliftAsymmetryFrameCount = 0;
    }
    return FormCheckResult(hasError: false);
  }

  // ========== COMBINED FORM CHECKS ==========

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

  FormCheckResult checkAllSquatForm(Pose pose, ExerciseState currentState) {
    final kneeCaveResult = checkKneeCave(pose, currentState);
    final forwardLeanResult = checkForwardLean(pose, currentState);
    final symmetryResult = checkSquatSymmetry(pose, currentState);

    return _persistError(_prioritizeError([kneeCaveResult, forwardLeanResult, symmetryResult]));
  }

  FormCheckResult checkAllBenchForm(Pose pose, ExerciseState currentState) {
    final elbowFlareResult = checkElbowFlare(pose, currentState);
    final symmetryResult = checkBenchSymmetry(pose, currentState);

    return _persistError(_prioritizeError([elbowFlareResult, symmetryResult]));
  }

  /// Run all DEADLIFT form checks
  FormCheckResult checkAllDeadliftForm(Pose pose, ExerciseState currentState) {
    final backRoundingResult = checkBackRounding(pose, currentState);
    final symmetryResult = checkDeadliftSymmetry(pose, currentState);

    // Prioritize: back rounding is most dangerous, then symmetry
    return _persistError(_prioritizeError([backRoundingResult, symmetryResult]));
  }

  FormCheckResult _prioritizeError(List<FormCheckResult> results) {
    for (final result in results) {
      if (result.hasError) return result;
    }
    return FormCheckResult(hasError: false);
  }

  FormCheckResult _persistError(FormCheckResult currentError) {
    if (currentError.hasError) {
      _lastErrorMessage = currentError.errorMessage;
      _lastErrorType = currentError.errorType;
      _errorDisplayFrames = _errorPersistFrames;
      return currentError;
    } else if (_errorDisplayFrames > 0) {
      _errorDisplayFrames--;
      return FormCheckResult(
        hasError: true,
        errorMessage: _lastErrorMessage,
        errorType: _lastErrorType,
        severity: FormErrorSeverity.warning,
      );
    } else {
      _lastErrorMessage = null;
      _lastErrorType = null;
      return FormCheckResult(hasError: false);
    }
  }
}

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

enum FormErrorType {
  kneeCave,
  asymmetry,
  lowConfidence,
  shallowDepth,
  excessiveSpeed,
  forwardLean,
  elbowFlare,
  backRounding,
}

enum FormErrorSeverity {
  info,
  warning,
  danger,
}

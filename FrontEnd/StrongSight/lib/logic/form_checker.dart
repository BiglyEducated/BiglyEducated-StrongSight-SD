import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import '../models/exercise_config.dart';
import 'angle_calculator.dart';

class FormChecker {
  // Squat checks
  int _kneeCaveFrameCount = 0;
  static const int _kneeCaveThresholdFrames = 3;
  static const double _kneeCaveRatio = 0.75;

  double? _baselineKneeAnkleRatio;
  ExerciseState _previousState = ExerciseState.standing;

  int _asymmetryFrameCount = 0;
  static const int _asymmetryThresholdFrames = 5;
  static const double _asymmetryAngleDiff = 20.0;

  int _forwardLeanFrameCount = 0;
  static const int _forwardLeanThresholdFrames = 3;
  static const double _forwardLeanRatio = 0.75;

  // Bench press checks
  int _elbowFlareFrameCount = 0;
  static const int _elbowFlareThresholdFrames = 3;
  static const double _elbowFlareRatio = 1.35;

  int _wristStackFrameCount = 0;
  static const int _wristStackThresholdFrames = 3;
  static const double _wristStackTolerance = 0.25;

  int _barTiltFrameCount = 0;
  static const int _barTiltThresholdFrames = 3;
  static const double _barTiltRatio = 0.15;

  // Deadlift checks
  int _backRoundingFrameCount = 0;
  static const int _backRoundingThresholdFrames = 4;
  static const double _backRoundingAngleMin = 160.0;

  int _deadliftAsymmetryFrameCount = 0;
  static const int _deadliftAsymmetryThresholdFrames = 4;
  static const double _deadliftAsymmetryAngleDiff = 15.0;

  // Error persistence
  String? _lastErrorMessage;
  FormErrorType? _lastErrorType;
  int _errorDisplayFrames = 0;
  static const int _errorPersistFrames = 15;

  // Per-joint confidence thresholds
  static const double _confidenceHigh = 0.75;
  static const double _confidenceMed = 0.65;
  static const double _confidenceLow = 0.55;

  // Shared minimum confidence used for bench wrist/elbow checks
  static const double _minConfidence = _confidenceLow;

  void reset() {
    _kneeCaveFrameCount = 0;
    _baselineKneeAnkleRatio = null;
    _previousState = ExerciseState.standing;
    _asymmetryFrameCount = 0;
    _forwardLeanFrameCount = 0;
    _elbowFlareFrameCount = 0;
    _wristStackFrameCount = 0;
    _barTiltFrameCount = 0;
    _backRoundingFrameCount = 0;
    _deadliftAsymmetryFrameCount = 0;
    _lastErrorMessage = null;
    _lastErrorType = null;
    _errorDisplayFrames = 0;
  }

  // SQUAT CHECKS

  FormCheckResult checkKneeCave(Pose pose, ExerciseState currentState) {
    final leftKnee = pose.landmarks[PoseLandmarkType.leftKnee];
    final rightKnee = pose.landmarks[PoseLandmarkType.rightKnee];
    final leftAnkle = pose.landmarks[PoseLandmarkType.leftAnkle];
    final rightAnkle = pose.landmarks[PoseLandmarkType.rightAnkle];

    if (leftKnee == null || rightKnee == null || leftAnkle == null || rightAnkle == null ||
        leftKnee.likelihood < _confidenceMed || rightKnee.likelihood < _confidenceMed ||
        leftAnkle.likelihood < _confidenceLow || rightAnkle.likelihood < _confidenceLow) {
      _kneeCaveFrameCount = 0;
      return FormCheckResult(hasError: false);
    }

    bool isRelevantPhase = currentState == ExerciseState.descent ||
                           currentState == ExerciseState.bottom ||
                           currentState == ExerciseState.ascending;
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

    if (_previousState == ExerciseState.standing && currentState == ExerciseState.descent) {
      _baselineKneeAnkleRatio = ratio;
    }
    _previousState = currentState;

    final threshold = _baselineKneeAnkleRatio != null
        ? _baselineKneeAnkleRatio! * 0.85
        : _kneeCaveRatio;

    if (ratio < threshold) {
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
        leftKnee == null || rightKnee == null ||
        leftShoulder.likelihood < _confidenceHigh || leftHip.likelihood < _confidenceHigh) {
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
        leftKnee.likelihood < _confidenceMed || rightKnee.likelihood < _confidenceMed ||
        leftHip.likelihood < _confidenceHigh || rightHip.likelihood < _confidenceHigh) {
      _asymmetryFrameCount = 0;
      return FormCheckResult(hasError: false);
    }

    bool isRelevantPhase = currentState == ExerciseState.descent ||
                           currentState == ExerciseState.bottom ||
                           currentState == ExerciseState.ascending;
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

  // BENCH PRESS CHECKS

  /// Check for excessive elbow flare using elbow-width vs shoulder-width ratio.
  FormCheckResult checkElbowFlare(Pose pose, ExerciseState currentState) {
    final leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final rightShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
    final leftElbow = pose.landmarks[PoseLandmarkType.leftElbow];
    final rightElbow = pose.landmarks[PoseLandmarkType.rightElbow];

    if (leftShoulder == null || rightShoulder == null ||
        leftElbow == null || rightElbow == null ||
        leftElbow.likelihood < _minConfidence ||
        rightElbow.likelihood < _minConfidence) {
      _elbowFlareFrameCount = 0;
      return FormCheckResult(hasError: false);
    }

    final isRelevantPhase = currentState == ExerciseState.descent ||
        currentState == ExerciseState.bottom;
    if (!isRelevantPhase) {
      _elbowFlareFrameCount = 0;
      return FormCheckResult(hasError: false);
    }

    final shoulderWidth =
        AngleCalculator.calculateHorizontalDistance(leftShoulder, rightShoulder);
    final elbowWidth =
        AngleCalculator.calculateHorizontalDistance(leftElbow, rightElbow);

    if (shoulderWidth <= 0) {
      _elbowFlareFrameCount = 0;
      return FormCheckResult(hasError: false);
    }

    final ratio = elbowWidth / shoulderWidth;
    if (ratio > _elbowFlareRatio) {
      _elbowFlareFrameCount++;
    } else {
      _elbowFlareFrameCount = 0;
    }

    if (_elbowFlareFrameCount >= _elbowFlareThresholdFrames) {
      return FormCheckResult(
        hasError: true,
        errorMessage: "⚠️ ELBOW FLARE - Tuck elbows slightly!",
        errorType: FormErrorType.elbowFlare,
        severity: FormErrorSeverity.warning,
      );
    }
    return FormCheckResult(hasError: false);
  }

  /// Check wrist-over-elbow stacking during press/descent.
  FormCheckResult checkWristStack(Pose pose, ExerciseState currentState) {
    final leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final rightShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
    final leftElbow = pose.landmarks[PoseLandmarkType.leftElbow];
    final rightElbow = pose.landmarks[PoseLandmarkType.rightElbow];
    final leftWrist = pose.landmarks[PoseLandmarkType.leftWrist];
    final rightWrist = pose.landmarks[PoseLandmarkType.rightWrist];

    if (leftShoulder == null || rightShoulder == null ||
        leftElbow == null || rightElbow == null ||
        leftWrist == null || rightWrist == null ||
        leftWrist.likelihood < _minConfidence ||
        rightWrist.likelihood < _minConfidence) {
      _wristStackFrameCount = 0;
      return FormCheckResult(hasError: false);
    }

    final isRelevantPhase = currentState == ExerciseState.descent ||
        currentState == ExerciseState.ascending;
    if (!isRelevantPhase) {
      _wristStackFrameCount = 0;
      return FormCheckResult(hasError: false);
    }

    final shoulderWidth =
        AngleCalculator.calculateHorizontalDistance(leftShoulder, rightShoulder);
    if (shoulderWidth <= 0) {
      _wristStackFrameCount = 0;
      return FormCheckResult(hasError: false);
    }

    final leftOffset = (leftWrist.x - leftElbow.x).abs();
    final rightOffset = (rightWrist.x - rightElbow.x).abs();
    final avgOffset = (leftOffset + rightOffset) / 2;

    if (avgOffset > shoulderWidth * _wristStackTolerance) {
      _wristStackFrameCount++;
    } else {
      _wristStackFrameCount = 0;
    }

    if (_wristStackFrameCount >= _wristStackThresholdFrames) {
      return FormCheckResult(
        hasError: true,
        errorMessage: "⚠️ WRIST STACK - Keep wrists over elbows!",
        errorType: FormErrorType.wristStack,
        severity: FormErrorSeverity.warning,
      );
    }
    return FormCheckResult(hasError: false);
  }

  /// Check bar path tilt via wrist height mismatch.
  FormCheckResult checkBarTilt(Pose pose, ExerciseState currentState) {
    final leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final rightShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
    final leftWrist = pose.landmarks[PoseLandmarkType.leftWrist];
    final rightWrist = pose.landmarks[PoseLandmarkType.rightWrist];

    if (leftShoulder == null || rightShoulder == null ||
        leftWrist == null || rightWrist == null ||
        leftWrist.likelihood < _minConfidence ||
        rightWrist.likelihood < _minConfidence) {
      _barTiltFrameCount = 0;
      return FormCheckResult(hasError: false);
    }

    final isRelevantPhase = currentState == ExerciseState.ascending ||
        currentState == ExerciseState.bottom;
    if (!isRelevantPhase) {
      _barTiltFrameCount = 0;
      return FormCheckResult(hasError: false);
    }

    final shoulderWidth =
        AngleCalculator.calculateHorizontalDistance(leftShoulder, rightShoulder);
    if (shoulderWidth <= 0) {
      _barTiltFrameCount = 0;
      return FormCheckResult(hasError: false);
    }

    final wristHeightDelta = (leftWrist.y - rightWrist.y).abs();
    final normalizedTilt = wristHeightDelta / shoulderWidth;

    if (normalizedTilt > _barTiltRatio) {
      _barTiltFrameCount++;
    } else {
      _barTiltFrameCount = 0;
    }

    if (_barTiltFrameCount >= _barTiltThresholdFrames) {
      return FormCheckResult(
        hasError: true,
        errorMessage: "⚠️ BAR TILT - Press evenly on both sides!",
        errorType: FormErrorType.barTilt,
        severity: FormErrorSeverity.warning,
      );
    }
    return FormCheckResult(hasError: false);
  }

  // DEADLIFT CHECKS

  FormCheckResult checkBackRounding(Pose pose, ExerciseState currentState) {
    final leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final leftHip = pose.landmarks[PoseLandmarkType.leftHip];
    final leftKnee = pose.landmarks[PoseLandmarkType.leftKnee];

    if (leftShoulder == null || leftHip == null || leftKnee == null ||
        leftShoulder.likelihood < _confidenceHigh || leftHip.likelihood < _confidenceHigh ||
        leftKnee.likelihood < _confidenceMed) {
      _backRoundingFrameCount = 0;
      return FormCheckResult(hasError: false);
    }

    bool isRelevantPhase = currentState == ExerciseState.descent ||
                           currentState == ExerciseState.bottom ||
                           currentState == ExerciseState.ascending ||
                           currentState == ExerciseState.standing;
    if (!isRelevantPhase) {
      _backRoundingFrameCount = 0;
      return FormCheckResult(hasError: false);
    }

    double spineAngle = AngleCalculator.calculateAngle(leftShoulder, leftHip, leftKnee);

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

  FormCheckResult checkDeadliftSymmetry(Pose pose, ExerciseState currentState) {
    final leftHip = pose.landmarks[PoseLandmarkType.leftHip];
    final leftKnee = pose.landmarks[PoseLandmarkType.leftKnee];
    final leftAnkle = pose.landmarks[PoseLandmarkType.leftAnkle];
    final rightHip = pose.landmarks[PoseLandmarkType.rightHip];
    final rightKnee = pose.landmarks[PoseLandmarkType.rightKnee];
    final rightAnkle = pose.landmarks[PoseLandmarkType.rightAnkle];

    if (leftHip == null || leftKnee == null || leftAnkle == null ||
        rightHip == null || rightKnee == null || rightAnkle == null ||
        leftHip.likelihood < _confidenceHigh || rightHip.likelihood < _confidenceHigh ||
        leftKnee.likelihood < _confidenceMed || rightKnee.likelihood < _confidenceMed) {
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

  // COMBINED CHECKS

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
    final wristStackResult = checkWristStack(pose, currentState);
    final barTiltResult = checkBarTilt(pose, currentState);

    return _persistError(_prioritizeError([elbowFlareResult, wristStackResult, barTiltResult]));
  }

  FormCheckResult checkAllDeadliftForm(Pose pose, ExerciseState currentState) {
    final backRoundingResult = checkBackRounding(pose, currentState);
    final symmetryResult = checkDeadliftSymmetry(pose, currentState);

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
  wristStack,
  barTilt,
  backRounding,
}

enum FormErrorSeverity {
  info,
  warning,
  danger,
}
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
  static const int _asymmetryThresholdFrames = 3; // lowered from 5
  static const double _asymmetryAngleDiff = 15.0; // tightened from 20°

  int _forwardLeanFrameCount = 0;
  static const int _forwardLeanThresholdFrames = 3;
  static const double _forwardLeanRatio = 0.75;

  // Bench press checks
  int _elbowFlareFrameCount = 0;
  static const int _elbowFlareThresholdFrames = 3;
  static const double _elbowFlareRatio = 1.15; // tightened from 1.35

  int _wristStackFrameCount = 0;
  static const int _wristStackThresholdFrames = 3;
  static const double _wristStackTolerance = 0.15; // tightened from 0.25

  int _barTiltFrameCount = 0;
  static const int _barTiltThresholdFrames = 3;
  static const double _barTiltRatio = 0.10; // tightened from 0.15

  // Row checks
  int _rowTorsoFrameCount = 0;
  static const int _rowTorsoThresholdFrames = 4;

  int _rowElbowFrameCount = 0;
  static const int _rowElbowThresholdFrames = 3;

  int _rowBackRoundingFrameCount = 0;
  static const int _rowBackRoundingThresholdFrames = 5; // more frames = less noise
  static const double _rowBackRoundingAngleMin = 140.0; // loosened from 150°

  int _rowUnevenBarFrameCount = 0;
  static const int _rowUnevenBarThresholdFrames = 3;
  static const double _rowUnevenBarRatio = 0.12;

  // Overhead press checks
  int _overheadLeanFrameCount = 0;
  static const int _overheadLeanThresholdFrames = 4;

  int _overheadAsymmetryFrameCount = 0;
  static const int _overheadAsymmetryThresholdFrames = 4;

  int _overheadWristStackFrameCount = 0;
  static const int _overheadWristStackThresholdFrames = 3;
  static const double _overheadWristStackTolerance = 0.26;

  int _overheadLegDriveFrameCount = 0;
  static const int _overheadLegDriveThresholdFrames = 2;
  static const double _overheadLegDriveDipAngle = 175.0;
  static const double _overheadLegDriveRecoveryAngle = 172.0;
  bool _overheadLegDriveDipSeen = false;

  // Deadlift checks
  int _backRoundingFrameCount = 0;
  static const int _backRoundingThresholdFrames = 4;
  static const double _backRoundingAngleMin = 160.0;

  int _deadliftAsymmetryFrameCount = 0;
  static const int _deadliftAsymmetryThresholdFrames = 4;
  static const double _deadliftAsymmetryAngleDiff = 17.0;

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
    _hipAsymmetryFrameCount = 0;
    _wristTiltFrameCount = 0;
    _forwardLeanFrameCount = 0;
    _elbowFlareFrameCount = 0;
    _wristStackFrameCount = 0;
    _barTiltFrameCount = 0;
    _rowTorsoFrameCount = 0;
    _rowElbowFrameCount = 0;
    _rowBackRoundingFrameCount = 0;
    _rowUnevenBarFrameCount = 0;
    _overheadLeanFrameCount = 0;
    _overheadAsymmetryFrameCount = 0;
    _overheadWristStackFrameCount = 0;
    _overheadLegDriveFrameCount = 0;
    _overheadLegDriveDipSeen = false;
    _backRoundingFrameCount = 0;
    _deadliftAsymmetryFrameCount = 0;
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
        ? _baselineKneeAnkleRatio! * 0.90
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

  // Hip height asymmetry frame counter (separate from knee angle counter)
  int _hipAsymmetryFrameCount = 0;
  int _wristTiltFrameCount = 0;

  FormCheckResult checkSquatSymmetry(Pose pose, ExerciseState currentState) {
    final leftHip = pose.landmarks[PoseLandmarkType.leftHip];
    final leftKnee = pose.landmarks[PoseLandmarkType.leftKnee];
    final leftAnkle = pose.landmarks[PoseLandmarkType.leftAnkle];
    final rightHip = pose.landmarks[PoseLandmarkType.rightHip];
    final rightKnee = pose.landmarks[PoseLandmarkType.rightKnee];
    final rightAnkle = pose.landmarks[PoseLandmarkType.rightAnkle];
    final leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final rightShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
    final leftWrist = pose.landmarks[PoseLandmarkType.leftWrist];
    final rightWrist = pose.landmarks[PoseLandmarkType.rightWrist];

    if (leftHip == null || leftKnee == null || leftAnkle == null ||
        rightHip == null || rightKnee == null || rightAnkle == null ||
        leftKnee.likelihood < _confidenceMed || rightKnee.likelihood < _confidenceMed ||
        leftHip.likelihood < _confidenceHigh || rightHip.likelihood < _confidenceHigh) {
      _asymmetryFrameCount = 0;
      _hipAsymmetryFrameCount = 0;
      _wristTiltFrameCount = 0;
      return FormCheckResult(hasError: false);
    }

    bool isRelevantPhase = currentState == ExerciseState.descent ||
                           currentState == ExerciseState.bottom ||
                           currentState == ExerciseState.ascending;
    if (!isRelevantPhase) {
      _asymmetryFrameCount = 0;
      _hipAsymmetryFrameCount = 0;
      _wristTiltFrameCount = 0;
      return FormCheckResult(hasError: false);
    }

    // Check 1: knee angle asymmetry (one leg deeper than the other)
    final double leftKneeAngle = AngleCalculator.calculateAngle(leftHip, leftKnee, leftAnkle);
    final double rightKneeAngle = AngleCalculator.calculateAngle(rightHip, rightKnee, rightAnkle);
    final double angleDifference = (leftKneeAngle - rightKneeAngle).abs();
    if (angleDifference > _asymmetryAngleDiff) {
      _asymmetryFrameCount++;
      if (_asymmetryFrameCount >= _asymmetryThresholdFrames) {
        _hipAsymmetryFrameCount = 0;
        _wristTiltFrameCount = 0;
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

    // Check 2: hip height asymmetry (weight shifting to one side)
    final shoulderWidth = leftShoulder != null && rightShoulder != null
        ? AngleCalculator.calculateHorizontalDistance(leftShoulder, rightShoulder)
        : AngleCalculator.calculateHorizontalDistance(leftHip, rightHip);
    if (shoulderWidth > 0) {
      final hipHeightDiff = (leftHip.y - rightHip.y).abs();
      final normalizedHipDiff = hipHeightDiff / shoulderWidth;
      if (normalizedHipDiff > 0.08) {
        _hipAsymmetryFrameCount++;
        if (_hipAsymmetryFrameCount >= _asymmetryThresholdFrames) {
          _wristTiltFrameCount = 0;
          return FormCheckResult(
            hasError: true,
            errorMessage: "⚠️ UNEVEN HIPS - Don't shift weight!",
            errorType: FormErrorType.asymmetry,
            severity: FormErrorSeverity.warning,
          );
        }
      } else {
        _hipAsymmetryFrameCount = 0;
      }

      // Check 3: wrist height asymmetry (bar tilt on back)
      if (leftWrist != null && rightWrist != null &&
          leftWrist.likelihood >= _confidenceLow && rightWrist.likelihood >= _confidenceLow) {
        final wristHeightDiff = (leftWrist.y - rightWrist.y).abs();
        final normalizedWristDiff = wristHeightDiff / shoulderWidth;
        if (normalizedWristDiff > 0.15) {
          _wristTiltFrameCount++;
          if (_wristTiltFrameCount >= _asymmetryThresholdFrames) {
            return FormCheckResult(
              hasError: true,
              errorMessage: "⚠️ BAR TILTING - Level the bar!",
              errorType: FormErrorType.barTilt,
              severity: FormErrorSeverity.warning,
            );
          }
        } else {
          _wristTiltFrameCount = 0;
        }
      }
    }

    return FormCheckResult(hasError: false);
  }

  // BENCH PRESS CHECKS

  /// Returns true if the user appears to be lying down (bench position).
  /// Guards bench checks from triggering during OHP.
  bool _isLyingDown(Pose pose) {
    final leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final leftHip = pose.landmarks[PoseLandmarkType.leftHip];
    final rightShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
    if (leftShoulder == null || leftHip == null || rightShoulder == null) return false;
    final torsoVertical = (leftShoulder.y - leftHip.y).abs();
    final shoulderWidth = AngleCalculator.calculateHorizontalDistance(leftShoulder, rightShoulder);
    // When lying flat, torso height < shoulder width
    return torsoVertical < shoulderWidth * 1.0;
  }

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

    // Only fire when user is lying down — prevents OHP from triggering bench checks
    if (!_isLyingDown(pose)) {
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

    // Only fire when user is lying down — prevents OHP from triggering bench checks
    if (!_isLyingDown(pose)) {
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

    // Only fire when user is lying down — prevents OHP from triggering bench checks
    if (!_isLyingDown(pose)) {
      _barTiltFrameCount = 0;
      return FormCheckResult(hasError: false);
    }

    if (currentState == ExerciseState.standing) {
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

  // ROW CHECKS

  /// Check that the torso is sufficiently hinged forward for a row.
  /// From a front-facing camera, hinge is detected by how far the shoulders
  /// have dropped vertically toward hip level. When upright, shoulders are
  /// well above hips. When hinged, the gap closes significantly.
  FormCheckResult checkRowTorsoAngle(Pose pose, ExerciseState currentState) {
    final leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final rightShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
    final leftHip = pose.landmarks[PoseLandmarkType.leftHip];
    final rightHip = pose.landmarks[PoseLandmarkType.rightHip];

    if (leftShoulder == null || rightShoulder == null ||
        leftHip == null || rightHip == null ||
        leftShoulder.likelihood < _confidenceHigh ||
        leftHip.likelihood < _confidenceHigh) {
      _rowTorsoFrameCount = 0;
      return FormCheckResult(hasError: false);
    }

    if (currentState == ExerciseState.standing) {
      _rowTorsoFrameCount = 0;
      return FormCheckResult(hasError: false);
    }

    final avgShoulderY = (leftShoulder.y + rightShoulder.y) / 2;
    final avgHipY = (leftHip.y + rightHip.y) / 2;
    final shoulderWidth = AngleCalculator.calculateHorizontalDistance(leftShoulder, rightShoulder);

    if (shoulderWidth <= 0) {
      _rowTorsoFrameCount = 0;
      return FormCheckResult(hasError: false);
    }

    // In MediaPipe, Y increases downward. When hinged, shoulders drop closer
    // to hip Y. Normalize by shoulder width as a body-size reference.
    // When upright: (hipY - shoulderY) / shoulderWidth is large (shoulders well above hips).
    // When hinged: ratio shrinks as shoulders approach hip height.
    // Fire if the ratio is too large, meaning not hinged enough.
    final verticalGap = (avgHipY - avgShoulderY) / shoulderWidth;

    // If shoulder-to-hip vertical gap > 0.9x shoulder width, not hinged enough
    if (verticalGap > 0.9) {
      _rowTorsoFrameCount++;
      if (_rowTorsoFrameCount >= _rowTorsoThresholdFrames) {
        return FormCheckResult(
          hasError: true,
          errorMessage: "⚠️ HINGE MORE - Lean torso forward!",
          errorType: FormErrorType.forwardLean,
          severity: FormErrorSeverity.warning,
        );
      }
    } else {
      _rowTorsoFrameCount = 0;
    }
    return FormCheckResult(hasError: false);
  }

  /// Check that elbows drive back during the pull phase of the row.
  /// Fires during descent (pulling) if the elbow hasn't moved behind the shoulder yet.
  FormCheckResult checkRowElbowDrive(Pose pose, ExerciseState currentState) {
    final leftElbow = pose.landmarks[PoseLandmarkType.leftElbow];
    final leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final rightShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];

    if (leftElbow == null || leftShoulder == null || rightShoulder == null ||
        leftElbow.likelihood < _confidenceMed ||
        leftShoulder.likelihood < _confidenceHigh) {
      _rowElbowFrameCount = 0;
      return FormCheckResult(hasError: false);
    }

    // Only check at the top of the pull (bottom state = bar at torso)
    if (currentState != ExerciseState.bottom) {
      _rowElbowFrameCount = 0;
      return FormCheckResult(hasError: false);
    }

    final shoulderElbowOffset = (leftElbow.x - leftShoulder.x).abs();
    final shoulderWidth = AngleCalculator.calculateHorizontalDistance(leftShoulder, rightShoulder);

    if (shoulderElbowOffset < shoulderWidth * 0.10) {
      _rowElbowFrameCount++;
      if (_rowElbowFrameCount >= _rowElbowThresholdFrames) {
        return FormCheckResult(
          hasError: true,
          errorMessage: "⚠️ PULL MORE - Drive elbows behind torso!",
          errorType: FormErrorType.asymmetry,
          severity: FormErrorSeverity.warning,
        );
      }
    } else {
      _rowElbowFrameCount = 0;
    }
    return FormCheckResult(hasError: false);
  }

  /// Check that the row hinge stays neutral instead of rounding through the back.
  /// From front-on, back rounding causes the shoulders to drop lower than they
  /// should be relative to the hips. We compare shoulder Y against expected
  /// position based on hip Y — if shoulders are too low, back is rounding.
  FormCheckResult checkRowBackRounding(Pose pose, ExerciseState currentState) {
    final leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final leftHip = pose.landmarks[PoseLandmarkType.leftHip];
    final rightShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
    final rightHip = pose.landmarks[PoseLandmarkType.rightHip];
    final leftKnee = pose.landmarks[PoseLandmarkType.leftKnee];
    final rightKnee = pose.landmarks[PoseLandmarkType.rightKnee];

    if (leftShoulder == null || leftHip == null ||
        rightShoulder == null || rightHip == null ||
        leftKnee == null || rightKnee == null ||
        leftShoulder.likelihood < _confidenceHigh ||
        leftHip.likelihood < _confidenceHigh) {
      _rowBackRoundingFrameCount = 0;
      return FormCheckResult(hasError: false);
    }

    final isRelevantPhase = currentState == ExerciseState.descent ||
        currentState == ExerciseState.bottom ||
        currentState == ExerciseState.ascending;
    if (!isRelevantPhase) {
      _rowBackRoundingFrameCount = 0;
      return FormCheckResult(hasError: false);
    }

    final avgShoulderY = (leftShoulder.y + rightShoulder.y) / 2;
    final avgHipY = (leftHip.y + rightHip.y) / 2;
    final avgKneeY = (leftKnee.y + rightKnee.y) / 2;
    final shoulderWidth = AngleCalculator.calculateHorizontalDistance(leftShoulder, rightShoulder);

    if (shoulderWidth <= 0) {
      _rowBackRoundingFrameCount = 0;
      return FormCheckResult(hasError: false);
    }

    // Hip-to-knee distance as a body proportion reference
    final hipToKnee = (avgKneeY - avgHipY).abs();
    if (hipToKnee <= 0) {
      _rowBackRoundingFrameCount = 0;
      return FormCheckResult(hasError: false);
    }

    // When properly hinged, shoulders should be above hips.
    // Back rounding causes shoulders to drop below or level with hips.
    // If shoulders are at or below hip height, back is rounding.
    // (avgShoulderY > avgHipY means shoulders are lower in frame = rounding)
    final shoulderBelowHip = avgShoulderY - avgHipY;
    final normalizedDrop = shoulderBelowHip / hipToKnee;

    // Fire if shoulders have dropped below hips by > 10% of hip-to-knee distance
    if (normalizedDrop > 0.10) {
      _rowBackRoundingFrameCount++;
      if (_rowBackRoundingFrameCount >= _rowBackRoundingThresholdFrames) {
        return FormCheckResult(
          hasError: true,
          errorMessage: "⚠️ BACK ROUNDING - Keep spine neutral!",
          errorType: FormErrorType.backRounding,
          severity: FormErrorSeverity.warning,
        );
      }
    } else {
      _rowBackRoundingFrameCount = 0;
    }

    return FormCheckResult(hasError: false);
  }

  /// Check if one side of the bar drifts higher than the other during the row.
  FormCheckResult checkRowUnevenBar(Pose pose, ExerciseState currentState) {
    final leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final rightShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
    final leftWrist = pose.landmarks[PoseLandmarkType.leftWrist];
    final rightWrist = pose.landmarks[PoseLandmarkType.rightWrist];

    if (leftShoulder == null || rightShoulder == null ||
        leftWrist == null || rightWrist == null ||
        leftWrist.likelihood < _minConfidence ||
        rightWrist.likelihood < _minConfidence) {
      _rowUnevenBarFrameCount = 0;
      return FormCheckResult(hasError: false);
    }

    final isRelevantPhase = currentState == ExerciseState.descent ||
        currentState == ExerciseState.bottom ||
        currentState == ExerciseState.ascending;
    if (!isRelevantPhase) {
      _rowUnevenBarFrameCount = 0;
      return FormCheckResult(hasError: false);
    }

    final shoulderWidth =
        AngleCalculator.calculateHorizontalDistance(leftShoulder, rightShoulder);
    if (shoulderWidth <= 0) {
      _rowUnevenBarFrameCount = 0;
      return FormCheckResult(hasError: false);
    }

    final wristHeightDelta = (leftWrist.y - rightWrist.y).abs();
    final normalizedTilt = wristHeightDelta / shoulderWidth;

    if (normalizedTilt > _rowUnevenBarRatio) {
      _rowUnevenBarFrameCount++;
      if (_rowUnevenBarFrameCount >= _rowUnevenBarThresholdFrames) {
        return FormCheckResult(
          hasError: true,
          errorMessage: "⚠️ UNEVEN BAR - Keep the bar level!",
          errorType: FormErrorType.barTilt,
          severity: FormErrorSeverity.warning,
        );
      }
    } else {
      _rowUnevenBarFrameCount = 0;
    }

    return FormCheckResult(hasError: false);
  }

  // OVERHEAD PRESS CHECKS

  /// Check for excessive back lean during overhead press.
  FormCheckResult checkOverheadLean(Pose pose, ExerciseState currentState) {
    final leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final leftHip = pose.landmarks[PoseLandmarkType.leftHip];
    final leftKnee = pose.landmarks[PoseLandmarkType.leftKnee];

    if (leftShoulder == null || leftHip == null || leftKnee == null ||
        leftShoulder.likelihood < _confidenceHigh ||
        leftHip.likelihood < _confidenceHigh) {
      _overheadLeanFrameCount = 0;
      return FormCheckResult(hasError: false);
    }

    if (currentState == ExerciseState.standing) {
      _overheadLeanFrameCount = 0;
      return FormCheckResult(hasError: false);
    }

    // Spine angle shoulder-hip-knee. Back lean = angle < 155°
    final spineAngle = AngleCalculator.calculateAngle(leftShoulder, leftHip, leftKnee);
    if (spineAngle < 155.0) {
      _overheadLeanFrameCount++;
      if (_overheadLeanFrameCount >= _overheadLeanThresholdFrames) {
        return FormCheckResult(
          hasError: true,
          errorMessage: "⚠️ BACK LEAN - Keep torso upright!",
          errorType: FormErrorType.forwardLean,
          severity: FormErrorSeverity.warning,
        );
      }
    } else {
      _overheadLeanFrameCount = 0;
    }
    return FormCheckResult(hasError: false);
  }

  /// Check for asymmetric pressing by comparing wrist and shoulder Y positions.
  /// If one wrist is significantly higher than the other, the press is uneven.
  FormCheckResult checkOverheadAsymmetry(Pose pose, ExerciseState currentState) {
    final leftWrist = pose.landmarks[PoseLandmarkType.leftWrist];
    final rightWrist = pose.landmarks[PoseLandmarkType.rightWrist];
    final leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final rightShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];

    if (leftWrist == null || rightWrist == null ||
        leftShoulder == null || rightShoulder == null ||
        leftWrist.likelihood < _minConfidence ||
        rightWrist.likelihood < _minConfidence) {
      _overheadAsymmetryFrameCount = 0;
      return FormCheckResult(hasError: false);
    }

    if (currentState == ExerciseState.standing) {
      _overheadAsymmetryFrameCount = 0;
      return FormCheckResult(hasError: false);
    }

    // Use shoulder width as a normalizing reference
    final shoulderWidth = AngleCalculator.calculateHorizontalDistance(leftShoulder, rightShoulder);
    if (shoulderWidth <= 0) {
      _overheadAsymmetryFrameCount = 0;
      return FormCheckResult(hasError: false);
    }

    // If one wrist is significantly higher (lower Y) than the other, press is uneven.
    final wristYDiff = (leftWrist.y - rightWrist.y).abs();
    final normalized = wristYDiff / shoulderWidth;

    // > 20% of shoulder width difference = visibly uneven
    if (normalized > 0.20) {
      _overheadAsymmetryFrameCount++;
      if (_overheadAsymmetryFrameCount >= _overheadAsymmetryThresholdFrames) {
        return FormCheckResult(
          hasError: true,
          errorMessage: "⚠️ UNEVEN PRESS - Press both arms equally!",
          errorType: FormErrorType.asymmetry,
          severity: FormErrorSeverity.warning,
        );
      }
    } else {
      _overheadAsymmetryFrameCount = 0;
    }
    return FormCheckResult(hasError: false);
  }

  /// Check that forearms stay mostly vertical during an overhead press.
  FormCheckResult checkOverheadWristStack(Pose pose, ExerciseState currentState) {
    final leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final rightShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
    final leftElbow = pose.landmarks[PoseLandmarkType.leftElbow];
    final rightElbow = pose.landmarks[PoseLandmarkType.rightElbow];
    final leftWrist = pose.landmarks[PoseLandmarkType.leftWrist];
    final rightWrist = pose.landmarks[PoseLandmarkType.rightWrist];

    if (leftShoulder == null || rightShoulder == null ||
        leftElbow == null || rightElbow == null ||
        leftWrist == null || rightWrist == null ||
        leftElbow.likelihood < _minConfidence ||
        rightElbow.likelihood < _minConfidence ||
        leftWrist.likelihood < _minConfidence ||
        rightWrist.likelihood < _minConfidence) {
      _overheadWristStackFrameCount = 0;
      return FormCheckResult(hasError: false);
    }

    final isRelevantPhase = currentState == ExerciseState.descent ||
        currentState == ExerciseState.bottom ||
        currentState == ExerciseState.ascending;
    if (!isRelevantPhase) {
      _overheadWristStackFrameCount = 0;
      return FormCheckResult(hasError: false);
    }

    final shoulderWidth =
        AngleCalculator.calculateHorizontalDistance(leftShoulder, rightShoulder);
    if (shoulderWidth <= 0) {
      _overheadWristStackFrameCount = 0;
      return FormCheckResult(hasError: false);
    }

    final leftOffset = (leftWrist.x - leftElbow.x).abs();
    final rightOffset = (rightWrist.x - rightElbow.x).abs();
    final avgOffset = (leftOffset + rightOffset) / 2;

    if (avgOffset > shoulderWidth * _overheadWristStackTolerance) {
      _overheadWristStackFrameCount++;
    } else {
      _overheadWristStackFrameCount = 0;
    }

    if (_overheadWristStackFrameCount >= _overheadWristStackThresholdFrames) {
      return FormCheckResult(
        hasError: true,
        errorMessage: "⚠️ POOR WRIST STACKING - Keep forearms more vertical!",
        errorType: FormErrorType.wristStack,
        severity: FormErrorSeverity.warning,
      );
    }

    return FormCheckResult(hasError: false);
  }

  /// Check for push-press style knee dip and re-extension during a strict press.
  FormCheckResult checkOverheadLegDrive(Pose pose, ExerciseState currentState) {
    final leftHip = pose.landmarks[PoseLandmarkType.leftHip];
    final leftKnee = pose.landmarks[PoseLandmarkType.leftKnee];
    final leftAnkle = pose.landmarks[PoseLandmarkType.leftAnkle];
    final rightHip = pose.landmarks[PoseLandmarkType.rightHip];
    final rightKnee = pose.landmarks[PoseLandmarkType.rightKnee];
    final rightAnkle = pose.landmarks[PoseLandmarkType.rightAnkle];

    if (leftHip == null || leftKnee == null || leftAnkle == null ||
        rightHip == null || rightKnee == null || rightAnkle == null ||
        leftKnee.likelihood < _confidenceMed || rightKnee.likelihood < _confidenceMed ||
        leftHip.likelihood < _confidenceMed || rightHip.likelihood < _confidenceMed) {
      _overheadLegDriveFrameCount = 0;
      _overheadLegDriveDipSeen = false;
      return FormCheckResult(hasError: false);
    }

    final leftKneeAngle = AngleCalculator.calculateAngle(leftHip, leftKnee, leftAnkle);
    final rightKneeAngle = AngleCalculator.calculateAngle(rightHip, rightKnee, rightAnkle);
    final averageKneeAngle = (leftKneeAngle + rightKneeAngle) / 2;

    if (currentState == ExerciseState.descent ||
        currentState == ExerciseState.bottom ||
        currentState == ExerciseState.ascending) {
      if (averageKneeAngle < _overheadLegDriveDipAngle) {
        _overheadLegDriveDipSeen = true;
        _overheadLegDriveFrameCount = 0;
        return FormCheckResult(hasError: false);
      }
    }

    if (_overheadLegDriveDipSeen &&
        (currentState == ExerciseState.ascending || currentState == ExerciseState.standing) &&
        averageKneeAngle > _overheadLegDriveRecoveryAngle) {
      _overheadLegDriveFrameCount++;
      if (_overheadLegDriveFrameCount >= _overheadLegDriveThresholdFrames) {
        _overheadLegDriveDipSeen = false;
        _overheadLegDriveFrameCount = 0;
        return FormCheckResult(
          hasError: true,
          errorMessage: "⚠️ LEG DRIVE - Keep it strict. Try not to use your legs.",
          errorType: FormErrorType.legDrive,
          severity: FormErrorSeverity.warning,
        );
      }
    } else if (currentState == ExerciseState.standing && !_overheadLegDriveDipSeen) {
      _overheadLegDriveFrameCount = 0;
    } else if (averageKneeAngle <= _overheadLegDriveRecoveryAngle) {
      _overheadLegDriveFrameCount = 0;
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

  FormCheckResult checkAllRowForm(Pose pose, ExerciseState currentState) {
    final torsoResult = checkRowTorsoAngle(pose, currentState);
    final backRoundingResult = checkRowBackRounding(pose, currentState);
    final unevenBarResult = checkRowUnevenBar(pose, currentState);
    // Elbow drive check disabled — unreliable from front-facing camera
    return _persistError(
      _prioritizeError([backRoundingResult, unevenBarResult, torsoResult]),
    );
  }

  FormCheckResult checkAllOverheadForm(Pose pose, ExerciseState currentState) {
    final leanResult = checkOverheadLean(pose, currentState);
    final asymmetryResult = checkOverheadAsymmetry(pose, currentState);
    final wristStackResult = checkOverheadWristStack(pose, currentState);
    final legDriveResult = checkOverheadLegDrive(pose, currentState);
    return _persistError(
      _prioritizeError([legDriveResult, wristStackResult, leanResult, asymmetryResult]),
    );
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
    return currentError;
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
  legDrive,
}

enum FormErrorSeverity {
  info,
  warning,
  danger,
}

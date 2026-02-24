import '../models/exercise_config.dart';

class RepCounter {
  final ExerciseConfig config;
  ExerciseState currentState = ExerciseState.standing;
  int count = 0;
  
  double _smoothedAngle = 180.0;
  final double _emaAlpha = 0.3;
  double _previousAngle = 180.0;
  int _consecutiveFrames = 0;
  final int _frameThreshold = 2;
  bool _isInitialized = false;

  String feedbackMessage = "Ready? Begin your descent.";
  bool isError = false;
  String? timingWarningMessage;

  // Loose safety timing checks (seconds)
  static const double _minEccentricSeconds = 0.7;
  static const double _minConcentricSeconds = 0.5;
  DateTime? _descentStartTime;
  DateTime? _bottomReachedTime;
  double? lastEccentricDurationSeconds;
  double? lastConcentricDurationSeconds;
  double _totalEccentricDurationSeconds = 0.0;
  double _totalConcentricDurationSeconds = 0.0;
  int _eccentricSamples = 0;
  int _concentricSamples = 0;

  double? get averageEccentricDurationSeconds =>
      _eccentricSamples == 0 ? null : _totalEccentricDurationSeconds / _eccentricSamples;

  double? get averageConcentricDurationSeconds =>
      _concentricSamples == 0 ? null : _totalConcentricDurationSeconds / _concentricSamples;

  RepCounter(this.config) : feedbackMessage = config.readyCue;

  void update(double rawAngle) {
    if (!_isInitialized) {
      _smoothedAngle = rawAngle;
      _previousAngle = rawAngle;
      _isInitialized = true;
      print('RepCounter initialized: ${config.name}, angle: ${rawAngle.toStringAsFixed(1)}°');
    }
    
    _smoothedAngle = (_emaAlpha * rawAngle) + (1 - _emaAlpha) * _smoothedAngle;
    double velocity = (_smoothedAngle - _previousAngle).abs();
    _previousAngle = _smoothedAngle;

    // Debug for rows
    if (_isRow() && currentState != ExerciseState.standing) {
      print('Row - State: $currentState, Angle: ${_smoothedAngle.toStringAsFixed(1)}°, '
            'Velocity: ${velocity.toStringAsFixed(1)}°, Frames: $_consecutiveFrames');
    }

    switch (currentState) {
      case ExerciseState.standing:
        if (_smoothedAngle < config.standingThreshold - 5) {
          _transitionTo(ExerciseState.descent, _getDescentMessage());
        }
        break;

      case ExerciseState.descent:
        if (_smoothedAngle <= config.bottomThreshold + 20 && velocity < 15.0) {
          _consecutiveFrames++;
          if (_consecutiveFrames >= _frameThreshold) {
            _transitionTo(ExerciseState.bottom, _getBottomMessage());
          }
        } else if (_smoothedAngle > config.standingThreshold - 2) {
          // Only go back to standing if almost fully upright (large hysteresis gap)
          currentState = ExerciseState.standing;
          _consecutiveFrames = 0;
        } else {
          _consecutiveFrames = 0;
        }
        break;

      case ExerciseState.bottom:
        if (_smoothedAngle > config.bottomThreshold + 15) {
          _consecutiveFrames++;
          if (_consecutiveFrames >= _frameThreshold) {
            _transitionTo(ExerciseState.ascending, _getAscendingMessage());
          }
        } else {
          _consecutiveFrames = 0;
        }
        break;

      case ExerciseState.ascending:
        if (_smoothedAngle >= config.standingThreshold - 15) {
          _consecutiveFrames++;
          if (_consecutiveFrames >= _frameThreshold) {
            count++;
            _transitionTo(ExerciseState.standing, _getCompleteMessage());
          }
        } else {
          _consecutiveFrames = 0;
        }
        break;
    }
  }

  void _transitionTo(ExerciseState newState, String msg) {
    final now = DateTime.now();

    if (newState == ExerciseState.descent) {
      _descentStartTime = now;
    }

    if (newState == ExerciseState.bottom) {
      if (_descentStartTime != null) {
        lastEccentricDurationSeconds =
            now.difference(_descentStartTime!).inMilliseconds / 1000.0;
        _totalEccentricDurationSeconds += lastEccentricDurationSeconds!;
        _eccentricSamples++;

        if (lastEccentricDurationSeconds! < _minEccentricSeconds) {
          isError = true;
          timingWarningMessage = "Lower the weight more controlled.";
        }
      }
      _bottomReachedTime = now;
    }

    if (newState == ExerciseState.standing &&
        currentState == ExerciseState.ascending &&
        _bottomReachedTime != null) {
      lastConcentricDurationSeconds =
          now.difference(_bottomReachedTime!).inMilliseconds / 1000.0;
      _totalConcentricDurationSeconds += lastConcentricDurationSeconds!;
      _concentricSamples++;

      if (lastConcentricDurationSeconds! < _minConcentricSeconds) {
        isError = true;
        timingWarningMessage = "Avoid bouncing out of the bottom.";
      }
    }

    currentState = newState;
    feedbackMessage = msg;
    _consecutiveFrames = 0;
  }

  String _getDescentMessage() {
    if (_isBenchPress()) return "Lowering... control the bar.";
    if (_isSquat()) return "Lowering... keep it controlled.";
    if (_isRow()) return "Pulling... squeeze your back!";
    if (_isOverhead()) return "Lowering... stay tight!";
    if (_isDeadlift()) return "Lowering... hinge at hips!";
    return "Lowering... stay controlled.";
  }

  String _getBottomMessage() {
    if (_isBenchPress()) return "Bar to chest! Now press up.";
    if (_isSquat()) return "Good depth! Now push up.";
    if (_isRow()) return "Bar to torso! Squeeze and hold.";
    if (_isOverhead()) return "Bar at shoulders! Press up!";
    if (_isDeadlift()) return "Touch the floor! Now drive up!";
    return "Bottom position! Now rise.";
  }

  String _getAscendingMessage() {
    if (_isBenchPress()) return "Press! Drive through!";
    if (_isSquat()) return "Push through!";
    if (_isRow()) return "Extending arms... controlled!";
    if (_isOverhead()) return "Press! Lock it out!";
    if (_isDeadlift()) return "Drive! Push the floor!";
    return "Rising! Keep going.";
  }

  String _getCompleteMessage() {
    if (_isBenchPress()) return "Locked out! Next rep.";
    if (_isSquat()) return "Rep Complete! Next one.";
    if (_isRow()) return "Full extension! Next rep.";
    if (_isOverhead()) return "Locked overhead! Next rep.";
    if (_isDeadlift()) return "Lockout complete! Next rep.";
    return "Rep Complete! Next one.";
  }

  bool _isBenchPress() => config.name.toLowerCase().contains('bench');
  bool _isSquat() => config.name.toLowerCase().contains('squat');
  bool _isRow() => config.name.toLowerCase().contains('row');
  bool _isOverhead() => config.name.toLowerCase().contains('overhead');
  bool _isDeadlift() => config.name.toLowerCase().contains('deadlift');
}

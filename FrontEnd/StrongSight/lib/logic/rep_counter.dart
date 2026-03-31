import '../models/exercise_config.dart';

class RepCounter {
  final ExerciseConfig config;

  ExerciseState currentState = ExerciseState.standing;
  int count = 0;
  String feedbackMessage = '';
  bool isError = false;
  String? timingWarningMessage;

  int _consecutiveFrames = 0;
  static const int _frameThreshold = 3;
  bool _isInitialized = false;

  // Timing
  static const double _minEccentricSeconds = 0.4;
  static const double _minConcentricSeconds = 0.3;
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

  RepCounter(this.config) {
    feedbackMessage = config.readyCue;
  }

  void update(double angle) {
    if (!_isInitialized) {
      _isInitialized = true;
    }

    // Clear error state each frame — caller checks timingWarningMessage after update()
    isError = false;
    timingWarningMessage = null;

    switch (currentState) {
      case ExerciseState.standing:
        if (angle < config.standingThreshold - 5) {
          _transitionTo(ExerciseState.descent);
        }

      case ExerciseState.descent:
        if (angle <= config.bottomThreshold + 20) {
          _consecutiveFrames++;
          if (_consecutiveFrames >= _frameThreshold) {
            _transitionTo(ExerciseState.bottom);
          }
        } else if (angle > config.standingThreshold - 2) {
          currentState = ExerciseState.standing;
          _consecutiveFrames = 0;
        } else {
          _consecutiveFrames = 0;
        }

      case ExerciseState.bottom:
        if (angle > config.bottomThreshold + 15) {
          _consecutiveFrames++;
          if (_consecutiveFrames >= _frameThreshold) {
            _transitionTo(ExerciseState.ascending);
          }
        } else {
          _consecutiveFrames = 0;
        }

      case ExerciseState.ascending:
        if (angle >= config.standingThreshold - 15) {
          _consecutiveFrames++;
          if (_consecutiveFrames >= _frameThreshold) {
            count++;
            _transitionTo(ExerciseState.standing);
          }
        } else {
          _consecutiveFrames = 0;
        }
    }
  }

  void _transitionTo(ExerciseState newState) {
    final now = DateTime.now();

    if (newState == ExerciseState.descent) {
      _descentStartTime = now;
      feedbackMessage = config.descentCue;
    }

    if (newState == ExerciseState.bottom) {
      if (_descentStartTime != null) {
        lastEccentricDurationSeconds =
            now.difference(_descentStartTime!).inMilliseconds / 1000.0;
        _totalEccentricDurationSeconds += lastEccentricDurationSeconds!;
        _eccentricSamples++;

        if (lastEccentricDurationSeconds! < _minEccentricSeconds) {
          isError = true;
          timingWarningMessage = "⚠️ TOO FAST - Lower with control!";
        }
      }
      _bottomReachedTime = now;
      feedbackMessage = config.bottomCue;
    }

    if (newState == ExerciseState.ascending) {
      feedbackMessage = config.ascentCue;
    }

    if (newState == ExerciseState.standing) {
      if (currentState == ExerciseState.ascending && _bottomReachedTime != null) {
        lastConcentricDurationSeconds =
            now.difference(_bottomReachedTime!).inMilliseconds / 1000.0;
        _totalConcentricDurationSeconds += lastConcentricDurationSeconds!;
        _concentricSamples++;

        if (lastConcentricDurationSeconds! < _minConcentricSeconds) {
          isError = true;
          timingWarningMessage = "⚠️ TOO FAST - Avoid bouncing out of the bottom!";
        }
        feedbackMessage = config.repCompleteCue;
      } else {
        feedbackMessage = config.readyCue;
      }
    }

    currentState = newState;
    _consecutiveFrames = 0;
  }

  void reset() {
    currentState = ExerciseState.standing;
    count = 0;
    feedbackMessage = config.readyCue;
    isError = false;
    timingWarningMessage = null;
    _consecutiveFrames = 0;
    _isInitialized = false;
    _descentStartTime = null;
    _bottomReachedTime = null;
    lastEccentricDurationSeconds = null;
    lastConcentricDurationSeconds = null;
    _totalEccentricDurationSeconds = 0.0;
    _totalConcentricDurationSeconds = 0.0;
    _eccentricSamples = 0;
    _concentricSamples = 0;
  }
}

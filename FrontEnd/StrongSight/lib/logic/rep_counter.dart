import '../models/exercise_config.dart';

class RepCounter {
  final ExerciseConfig config;
  ExerciseState currentState = ExerciseState.standing;
  int count = 0;
  
  // Tracking Metrics
  double _smoothedAngle = 180.0;
  final double _emaAlpha = 0.3; // As per doc [cite: 1378]
  double _previousAngle = 180.0;
  int _consecutiveFrames = 0;
  final int _frameThreshold = 3; // To ensure deliberate movement [cite: 1369]

  // Form Feedback
  String feedbackMessage = "Ready? Begin your descent.";
  bool isError = false;

  RepCounter(this.config);

  void update(double rawAngle) {
    // 1. EMA Filter to handle jitter [cite: 388, 1378]
    _smoothedAngle = (_emaAlpha * rawAngle) + (1 - _emaAlpha) * _smoothedAngle;
    
    // 2. Calculate Velocity (degrees per frame) [cite: 386, 1365]
    double velocity = (_smoothedAngle - _previousAngle).abs();
    _previousAngle = _smoothedAngle;

    // 3. State Machine Logic [cite: 1341, 1354]
    switch (currentState) {
      case ExerciseState.standing:
        isError = false;
        if (_smoothedAngle < config.standingThreshold - 5) {
          _transitionTo(ExerciseState.descent, "Lowering... keep it controlled.");
        }
        break;

      case ExerciseState.descent:
        // More lenient bottom detection - increased velocity limit and added depth buffer
        if (_smoothedAngle <= config.bottomThreshold + 10 && velocity < 8.0) {
          _consecutiveFrames++;
          if (_consecutiveFrames >= _frameThreshold) {
            _transitionTo(ExerciseState.bottom, "Good depth! Now push up.");
          }
        } else if (_smoothedAngle > config.standingThreshold) {
           currentState = ExerciseState.standing; // Reset if they stand back up
        } else {
          // Reset counter if conditions not met
          _consecutiveFrames = 0;
        }
        break;

      case ExerciseState.bottom:
        if (_smoothedAngle > config.bottomThreshold + 5) {
          _consecutiveFrames++;
          if (_consecutiveFrames >= _frameThreshold) {
            _transitionTo(ExerciseState.ascending, "Push through!");
          }
        } else {
          // Reset counter if not ascending yet
          _consecutiveFrames = 0;
        }
        break;

      case ExerciseState.ascending:
        if (_smoothedAngle >= config.standingThreshold) {
          count++;
          _transitionTo(ExerciseState.standing, "Rep Complete! Next one.");
        }
        break;
    }
  }

  void _transitionTo(ExerciseState newState, String msg) {
    currentState = newState;
    feedbackMessage = msg;
    _consecutiveFrames = 0;
  }
}

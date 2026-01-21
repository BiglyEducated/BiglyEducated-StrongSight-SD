import '../models/exercise_config.dart';

/// Structured result from pose analysis
class PoseAnalysisResult {
  final bool isValid;
  final String feedback;
  final String phase;
  final int repCount;
  final ExerciseState state;
  final double? currentAngle;
  final bool hasFormError;
  final String? formErrorMessage;

  PoseAnalysisResult({
    required this.isValid,
    required this.feedback,
    required this.phase,
    required this.repCount,
    required this.state,
    this.currentAngle,
    this.hasFormError = false,
    this.formErrorMessage,
  });

  /// Create an invalid result (when pose can't be analyzed)
  factory PoseAnalysisResult.invalid(String reason) {
    return PoseAnalysisResult(
      isValid: false,
      feedback: reason,
      phase: 'unknown',
      repCount: 0,
      state: ExerciseState.standing,
    );
  }

  /// Create a valid result from rep counter and form checker
  factory PoseAnalysisResult.fromAnalysis({
    required int count,
    required ExerciseState state,
    required String feedbackMessage,
    required double angle,
    bool hasFormError = false,
    String? formErrorMessage,
  }) {
    // Determine phase string from state
    String phase = _getPhaseString(state);

    // Use form error message if present, otherwise use rep counter feedback
    String feedback = hasFormError && formErrorMessage != null
        ? formErrorMessage
        : feedbackMessage;

    return PoseAnalysisResult(
      isValid: true,
      feedback: feedback,
      phase: phase,
      repCount: count,
      state: state,
      currentAngle: angle,
      hasFormError: hasFormError,
      formErrorMessage: formErrorMessage,
    );
  }

  static String _getPhaseString(ExerciseState state) {
    switch (state) {
      case ExerciseState.standing:
        return 'standing';
      case ExerciseState.descent:
        return 'descending';
      case ExerciseState.bottom:
        return 'parallel';
      case ExerciseState.ascending:
        return 'ascending';
    }
  }

  /// Convert to map for legacy compatibility
  Map<String, dynamic> toMap() {
    return {
      'isValid': isValid,
      'feedback': feedback,
      'phase': phase,
      'count': repCount,
      'state': state,
      'angle': currentAngle,
      'isKneeCave': hasFormError,
    };
  }
}

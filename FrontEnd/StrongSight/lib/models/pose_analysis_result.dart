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

  factory PoseAnalysisResult.invalid(String reason) {
    return PoseAnalysisResult(
      isValid: false,
      feedback: reason,
      phase: 'unknown',
      repCount: 0,
      state: ExerciseState.standing,
    );
  }

  factory PoseAnalysisResult.fromAnalysis({
    required int count,
    required ExerciseState state,
    required String feedbackMessage,
    required double angle,
    String exerciseName = '',
    bool hasFormError = false,
    String? formErrorMessage,
  }) {
    final String phase = _getPhaseString(state, exerciseName);
    final String feedback = hasFormError && formErrorMessage != null
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

  static String _getPhaseString(ExerciseState state, String? exerciseName) {
    final isBench = exerciseName?.toLowerCase().contains('bench') ?? false;
    final isSquat = exerciseName?.toLowerCase().contains('squat') ?? false;
    final isRow = exerciseName?.toLowerCase().contains('row') ?? false;
    final isOverhead = exerciseName?.toLowerCase().contains('overhead') ?? false;
    final isDeadlift = exerciseName?.toLowerCase().contains('deadlift') ?? false;

    switch (state) {
      case ExerciseState.standing:
        if (isBench) return 'locked out';
        if (isSquat) return 'standing';
        if (isRow) return 'arms extended';
        if (isOverhead) return 'overhead lockout';
        if (isDeadlift) return 'standing upright';
        return 'ready';

      case ExerciseState.descent:
        if (isBench) return 'lowering bar';
        if (isSquat) return 'descending';
        if (isRow) return 'pulling';
        if (isOverhead) return 'lowering';
        if (isDeadlift) return 'lowering bar';
        return 'lowering';

      case ExerciseState.bottom:
        if (isBench) return 'bar at chest';
        if (isSquat) return 'parallel';
        if (isRow) return 'bar to torso';
        if (isOverhead) return 'bar at shoulders';
        if (isDeadlift) return 'bar at floor';
        return 'bottom';

      case ExerciseState.ascending:
        if (isBench) return 'pressing up';
        if (isSquat) return 'ascending';
        if (isRow) return 'extending';
        if (isOverhead) return 'pressing overhead';
        if (isDeadlift) return 'lifting';
        return 'rising';
    }
  }

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
import 'package:flutter/material.dart';

/// Widget for displaying workout stats overlay
class WorkoutStatsOverlay extends StatelessWidget {
  final int repCount;
  final String feedback;
  final String phase;
  final bool hasError;

  const WorkoutStatsOverlay({
    super.key,
    required this.repCount,
    required this.feedback,
    required this.phase,
    this.hasError = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Rep count
          Text(
            'Reps: $repCount',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          
          // Feedback message
          Text(
            feedback,
            style: TextStyle(
              color: _getFeedbackColor(),
              fontSize: 18,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          
          // Phase indicator
          Text(
            'Phase: $phase',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Color _getFeedbackColor() {
    if (hasError || feedback.contains('⚠️') || feedback.contains('CAVE')) {
      return Colors.redAccent;
    }
    return Colors.greenAccent;
  }
}

/// Widget for finish workout button
class FinishWorkoutButton extends StatelessWidget {
  final VoidCallback onPressed;

  const FinishWorkoutButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF039E39),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: const Text(
        'Finish Workout',
        style: TextStyle(fontSize: 18, color: Colors.white),
      ),
    );
  }
}

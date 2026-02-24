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
          
          // Feedback message - BIGGER and MORE VISIBLE when error
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: hasError ? 16 : 0,
              vertical: hasError ? 12 : 0,
            ),
            decoration: hasError ? BoxDecoration(
              color: Colors.red.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.red,
                width: 2,
              ),
            ) : null,
            child: Text(
              feedback,
              style: TextStyle(
                color: _getFeedbackColor(),
                fontSize: hasError ? 22 : 18, // Bigger when error
                fontWeight: hasError ? FontWeight.bold : FontWeight.normal,
                shadows: hasError ? [
                  Shadow(
                    color: Colors.black.withOpacity(0.8),
                    offset: const Offset(2, 2),
                    blurRadius: 4,
                  ),
                ] : null,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 4),
          
          // Phase indicator
          if (!hasError) // Hide phase when showing error
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
    if (hasError || feedback.contains('⚠️') || feedback.contains('CAVE') || 
        feedback.contains('LEAN') || feedback.contains('UNEVEN') ||
        feedback.contains('FLARE') || feedback.contains('WRIST') ||
        feedback.contains('TILT')) {
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

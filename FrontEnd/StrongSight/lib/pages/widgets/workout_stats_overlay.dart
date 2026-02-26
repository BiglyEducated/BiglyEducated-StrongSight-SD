import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/theme_provider.dart';

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
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    const lightModeGreen = Color(0xFF094941);
    const darkCard = Color(0xFF1A1917);

    final panelColor = isDark
        ? Colors.black.withOpacity(0.7)
        : Colors.white.withOpacity(0.88);
    final panelBorder = isDark
        ? Colors.white.withOpacity(0.14)
        : lightModeGreen.withOpacity(0.18);
    final primaryText = isDark ? Colors.white : lightModeGreen;
    final secondaryText = isDark ? Colors.white70 : Colors.grey[700]!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: panelColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: panelBorder),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Rep count
          Text(
            'Reps: $repCount',
            style: TextStyle(
              color: primaryText,
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
                color: _getFeedbackColor(isDark),
                fontSize: hasError ? 22 : 18, // Bigger when error
                fontWeight: hasError ? FontWeight.bold : FontWeight.normal,
                shadows: hasError ? [
                  Shadow(
                    color: (isDark ? Colors.black : darkCard).withOpacity(0.55),
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
              style: TextStyle(
                color: secondaryText,
                fontSize: 14,
              ),
            ),
        ],
      ),
    );
  }

  Color _getFeedbackColor(bool isDark) {
    const lightModeGreen = Color(0xFF094941);

    if (hasError || feedback.contains('⚠️') || feedback.contains('CAVE') || 
        feedback.contains('LEAN') || feedback.contains('UNEVEN') ||
        feedback.contains('FLARE') || feedback.contains('WRIST') ||
        feedback.contains('TILT')) {
      return Colors.redAccent;
    }
    return isDark ? Colors.greenAccent : lightModeGreen;
  }
}

/// Widget for finish workout button
class FinishWorkoutButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isDarkMode;

  const FinishWorkoutButton({
    super.key,
    required this.onPressed,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    const lightModeGreen = Color(0xFF094941);
    const darkModeGreen = Color(0xFF039E39);
    final accentColor = isDarkMode ? darkModeGreen : lightModeGreen;

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: accentColor,
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: const Text(
        'Finish Workout',
        style: TextStyle(fontSize: 18, color: Colors.white),
      ),
    );
  }
}

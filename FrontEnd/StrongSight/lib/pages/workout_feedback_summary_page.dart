import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/theme_provider.dart';

class WorkoutFeedbackSummaryPage extends StatelessWidget {
  final String exerciseName;
  final int repCount;
  final Map<String, int> formIssueCounts;
  final double? averageEccentricSeconds;
  final double? averageConcentricSeconds;

  const WorkoutFeedbackSummaryPage({
    super.key,
    required this.exerciseName,
    required this.repCount,
    required this.formIssueCounts,
    this.averageEccentricSeconds,
    this.averageConcentricSeconds,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    final hasIssues = formIssueCounts.isNotEmpty;
    final sortedIssues = formIssueCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    const ivory = Color(0xFFF3EBD3);
    const espresso = Color(0xFF12110F);
    const lightModeGreen = Color(0xFF094941);
    const darkModeGreen = Color(0xFF039E39);
    const darkCard = Color(0xFF1A1917);

    final bgColor = isDark ? espresso : const Color(0xFFFCF5E3);
    final appBarColor = ivory;
    final appBarTextColor = lightModeGreen;
    final cardColor = isDark ? darkCard : Colors.white;
    final primaryTextColor = isDark ? Colors.white : lightModeGreen;
    final secondaryTextColor = isDark ? Colors.white70 : Colors.grey[700]!;
    final accentColor = isDark ? darkModeGreen : lightModeGreen;
    final neutralBorderColor =
        isDark ? Colors.white24 : lightModeGreen.withOpacity(0.18);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: appBarColor,
        iconTheme: IconThemeData(color: appBarTextColor),
        title: Text(
          'Workout Feedback',
          style: TextStyle(color: appBarTextColor),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: accentColor, width: 1.2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exerciseName,
                      style: TextStyle(
                        color: primaryTextColor,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Reps completed: $repCount',
                      style: TextStyle(
                        color: secondaryTextColor,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: neutralBorderColor, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Average Rep Timing',
                      style: TextStyle(
                        color: primaryTextColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Average eccentric (down phase): ${_formatSeconds(averageEccentricSeconds)}',
                      style: TextStyle(color: secondaryTextColor, fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Average concentric (up phase): ${_formatSeconds(averageConcentricSeconds)}',
                      style: TextStyle(color: secondaryTextColor, fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                hasIssues ? 'Improper form detected:' : 'Form looks good!',
                style: TextStyle(
                  color: hasIssues
                      ? Colors.redAccent
                      : (isDark ? Colors.greenAccent : accentColor),
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              if (hasIssues)
                Expanded(
                  child: ListView.separated(
                    itemCount: sortedIssues.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final issue = sortedIssues[index];
                      return FormIssueMobilityTile(
                        issueTitle: issue.key,
                        issueCount: issue.value,
                        isDarkMode: isDark,
                      );
                    },
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: (isDark ? Colors.greenAccent : accentColor)
                        .withValues(alpha: isDark ? 0.10 : 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: (isDark ? Colors.greenAccent : accentColor)
                          .withValues(alpha: 0.35),
                      width: 1.2,
                    ),
                  ),
                  child: Text(
                    'No form breakdowns were detected during this set. Keep the same setup and bar path next session.',
                    style: TextStyle(
                      color: primaryTextColor,
                      fontSize: 15,
                      height: 1.35,
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Done',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatSeconds(double? value) {
    if (value == null) return 'N/A';
    return '${value.toStringAsFixed(2)}s';
  }
}

class FormIssueMobilityTile extends StatelessWidget {
  final String? issueTitle;
  final int? issueCount;
  final bool isDarkMode;

  const FormIssueMobilityTile({
    super.key,
    required this.issueTitle,
    this.issueCount,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final title = issueTitle?.trim();
    if (title == null || title.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final suggestedMuscles = _suggestedMobilityMusclesForIssue(title);
    const lightModeGreen = Color(0xFF094941);
    final primaryTextColor = isDarkMode ? Colors.white : lightModeGreen;
    final issueBorderColor = Colors.redAccent.withValues(alpha: isDarkMode ? 0.45 : 0.35);
    final issueBgColor = Colors.red.withValues(alpha: isDarkMode ? 0.12 : 0.08);
    final countTextColor = isDarkMode ? Colors.white70 : Colors.grey[700]!;
    final iconLabelColor = isDarkMode ? Colors.white70 : lightModeGreen;

    return Container(
      decoration: BoxDecoration(
        color: issueBgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: issueBorderColor,
          width: 1.2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.redAccent,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: primaryTextColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (issueCount != null)
                  Text(
                    '${issueCount}x',
                    style: TextStyle(
                      color: countTextColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Theme(
              data: theme.copyWith(
                dividerColor: Colors.transparent,
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
              ),
              child: ExpansionTile(
                tilePadding: EdgeInsets.zero,
                childrenPadding: const EdgeInsets.only(bottom: 8),
                iconColor: iconLabelColor,
                collapsedIconColor: iconLabelColor,
                title: Text(
                  'Suggested mobility work',
                  style: TextStyle(
                    color: iconLabelColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                children: suggestedMuscles
                    .map(
                      (muscle) => Padding(
                        padding: const EdgeInsets.only(left: 4, bottom: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(top: 2),
                              child: Text(
                                '•',
                                style: TextStyle(
                                  color: primaryTextColor,
                                  fontSize: 16,
                                  height: 1.2,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                muscle,
                                style: TextStyle(
                                  color: primaryTextColor,
                                  fontSize: 14,
                                  height: 1.25,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

List<String> _suggestedMobilityMusclesForIssue(String issueTitle) {
  final feedback = issueTitle.toUpperCase();

  if (feedback.contains('CAVE')) {
    return const [
      'Hip adductors',
      'Glute medius',
      'Hip external rotators',
    ];
  }

  if (feedback.contains('LEAN')) {
    return const [
      'Hip flexors',
      'Hamstrings',
      'Thoracic spine',
      'Ankle mobility',
    ];
  }

  if (feedback.contains('UNEVEN')) {
    return const [
      'Hip flexors',
      'Adductors',
      'Single-leg stability',
    ];
  }

  return const ['General hip mobility'];
}

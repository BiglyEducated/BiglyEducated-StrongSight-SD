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
    const appBarColor = ivory;
    const appBarTextColor = lightModeGreen;
    final cardColor = isDark ? darkCard : Colors.white;
    final primaryTextColor = isDark ? Colors.white : lightModeGreen;
    final secondaryTextColor = isDark ? Colors.white70 : Colors.grey[700]!;
    final accentColor = isDark ? darkModeGreen : lightModeGreen;
    final neutralBorderColor =
        isDark ? Colors.white24 : lightModeGreen.withValues(alpha: 0.18);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: appBarColor,
        iconTheme: const IconThemeData(color: appBarTextColor),
        title: const Text(
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
                      return FormIssueFeedbackTile(
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

class FormIssueFeedbackTile extends StatelessWidget {
  final String? issueTitle;
  final int? issueCount;
  final bool isDarkMode;

  const FormIssueFeedbackTile({
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
    final suggestions = _suggestedFeedbackForIssue(title);
    const lightModeGreen = Color(0xFF094941);
    final primaryTextColor = isDarkMode ? Colors.white : lightModeGreen;
    final issueBorderColor =
        Colors.redAccent.withValues(alpha: isDarkMode ? 0.45 : 0.35);
    final issueBgColor =
        Colors.red.withValues(alpha: isDarkMode ? 0.12 : 0.08);
    final countTextColor = isDarkMode ? Colors.white70 : Colors.grey[700]!;
    final iconLabelColor = isDarkMode ? Colors.white70 : lightModeGreen;
    final detailPanelColor = isDarkMode
        ? Colors.white.withValues(alpha: 0.06)
        : lightModeGreen.withValues(alpha: 0.07);
    final detailBorderColor = isDarkMode
        ? Colors.white.withValues(alpha: 0.10)
        : lightModeGreen.withValues(alpha: 0.12);

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
            if (suggestions.isNotEmpty) ...[
              const SizedBox(height: 6),
              Theme(
                data: theme.copyWith(
                  dividerColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                ),
                child: ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  childrenPadding: const EdgeInsets.only(top: 4, bottom: 8),
                  iconColor: iconLabelColor,
                  collapsedIconColor: iconLabelColor,
                  title: Text(
                    'What to try',
                    style: TextStyle(
                      color: iconLabelColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: detailPanelColor,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: detailBorderColor,
                        ),
                      ),
                      child: Column(
                        children: List.generate(suggestions.length, (index) {
                          final suggestion = suggestions[index];
                          final isLast = index == suggestions.length - 1;
                          return Padding(
                            padding: EdgeInsets.only(bottom: isLast ? 0 : 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Icon(
                                    Icons.arrow_right_alt_rounded,
                                    size: 18,
                                    color: primaryTextColor,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    suggestion,
                                    style: TextStyle(
                                      color: primaryTextColor,
                                      fontSize: 14,
                                      height: 1.3,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

List<String> _suggestedFeedbackForIssue(String issueTitle) {
  switch (issueTitle) {
    case 'Leg drive':
      return const [
        'Stay strict and let your shoulders do the work.',
        'If your legs keep helping, lighten the weight slightly.',
      ];
    case 'Eccentric too fast':
    case 'Concentric too fast':
    case 'Bounced out of bottom':
      return const [
        'Slow the rep down and stay in control.',
        'If control keeps breaking down, lighten the weight slightly.',
      ];
    case 'Uneven press':
      return const [
        'Keep the bar stable from shoulders to lockout.',
      ];
    case 'Uneven bar':
      return const [
        'Keep both sides of the bar moving level.',
      ];
    case 'Poor wrist stacking':
      return const [
        'Keep your forearms more vertical as you press.',
        'Let the wrists stay stacked over the elbows.',
      ];
    case 'Back rounding':
      return const [
        'Keep your chest up and spine neutral.',
      ];
    case 'Torso not hinged enough':
      return const [
        'Stay hinged over the bar through the full rep.',
      ];
    case 'Incomplete row pull':
      return const [
        'Finish each rep by driving your elbows back.',
      ];
    default:
      return const [];
  }
}

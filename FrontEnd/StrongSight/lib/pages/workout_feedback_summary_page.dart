import 'package:flutter/material.dart';

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
    final hasIssues = formIssueCounts.isNotEmpty;
    final sortedIssues = formIssueCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      backgroundColor: const Color(0xFF12110F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF12110F),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Workout Feedback',
          style: TextStyle(color: Colors.white),
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
                  color: const Color(0xFF1A1917),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF039E39), width: 1.2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exerciseName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Reps completed: $repCount',
                      style: const TextStyle(
                        color: Colors.white70,
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
                  color: const Color(0xFF1A1917),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white24, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Average Rep Timing',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Average eccentric (down phase): ${_formatSeconds(averageEccentricSeconds)}',
                      style: const TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Average concentric (up phase): ${_formatSeconds(averageConcentricSeconds)}',
                      style: const TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                hasIssues ? 'Improper form detected:' : 'Form looks good!',
                style: TextStyle(
                  color: hasIssues ? Colors.redAccent : Colors.greenAccent,
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
                      );
                    },
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.greenAccent.withValues(alpha: 0.35),
                      width: 1.2,
                    ),
                  ),
                  child: const Text(
                    'No form breakdowns were detected during this set. Keep the same setup and bar path next session.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      height: 1.35,
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF039E39),
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

  const FormIssueMobilityTile({
    super.key,
    required this.issueTitle,
    this.issueCount,
  });

  @override
  Widget build(BuildContext context) {
    final title = issueTitle?.trim();
    if (title == null || title.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final suggestedMuscles = _suggestedMobilityMusclesForIssue(title);

    return Container(
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.redAccent.withValues(alpha: 0.45),
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
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (issueCount != null)
                  Text(
                    '${issueCount}x',
                    style: const TextStyle(
                      color: Colors.white70,
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
                iconColor: Colors.white70,
                collapsedIconColor: Colors.white70,
                title: const Text(
                  'Suggested mobility work',
                  style: TextStyle(
                    color: Colors.white70,
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
                            const Padding(
                              padding: EdgeInsets.only(top: 2),
                              child: Text(
                                '•',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  height: 1.2,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                muscle,
                                style: const TextStyle(
                                  color: Colors.white,
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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class WorkoutPage extends StatefulWidget {
  const WorkoutPage({super.key});

  @override
  State<WorkoutPage> createState() => _WorkoutPageState();
}

class _WorkoutPageState extends State<WorkoutPage> {
  String? _selectedExercise;
  bool _isRecording = false;

  final List<String> _exerciseList = [
    "Squat",
    "Bench Press",
    "Deadlift",
    "Bicep Curls",
  ];

  void _startRecording() async {
    setState(() {
      _isRecording = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Camera starting... (placeholder)")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    // --- StrongSight Colors ---
    const ivory = Color(0xFFF3EBD3);
    const espresso = Color(0xFF12110F);
    const lightModeGreen = Color(0xFF094941);
    const darkModeGreen = Color(0xFF039E39);
    const darkCard = Color(0xFF1A1917);

    final bgColor = isDark ? espresso : const Color(0xFFFCF5E3);
    final cardColor = isDark ? darkCard : Colors.white;
    final textColor = isDark ? darkModeGreen : lightModeGreen;
    final subTextColor = isDark ? const Color(0xFFD9CBB8) : Colors.grey[700]!;
    final accentColor = isDark ? darkModeGreen : lightModeGreen;
    final borderColor = isDark ? darkModeGreen : lightModeGreen;

    return Scaffold(
      backgroundColor: bgColor,

      // ---------- App Bar ----------
      appBar: AppBar(
        backgroundColor: ivory, // Always ivory
        title: const Text(
          "Start Workout",
          style: TextStyle(
            color: lightModeGreen, // Always dark green
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: lightModeGreen), // Always dark green icons
      ),

      // ---------- Body ----------
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Select Exercise:",
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 12),

            // --- Dropdown Menu ---
            DropdownButtonFormField<String>(
              value: _selectedExercise,
              hint: Text(
                "Choose an exercise",
                style: TextStyle(color: subTextColor),
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: cardColor,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: borderColor, width: 1.2),
                ),
              ),
              dropdownColor: cardColor,
              iconEnabledColor: textColor,
              items: _exerciseList.map((exercise) {
                return DropdownMenuItem<String>(
                  value: exercise,
                  child: Text(
                    exercise,
                    style: TextStyle(fontSize: 16, color: textColor),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedExercise = value;
                  _isRecording = false;
                });
              },
            ),
            const SizedBox(height: 24),

            // --- Conditional Exercise Demo ---
            if (_selectedExercise != null) ...[
              _buildExerciseDemo(
                _selectedExercise!,
                isDark,
                cardColor,
                textColor,
                subTextColor,
                borderColor,
              ),
              const SizedBox(height: 30),

              // --- Start Recording Button ---
              Center(
                child: ElevatedButton.icon(
                  onPressed: _startRecording,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: ivory,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.videocam),
                  label: Text(
                    _isRecording ? "Recording..." : "Start Recording",
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ---------- Exercise Demo Card ----------
  Widget _buildExerciseDemo(
    String exercise,
    bool isDark,
    Color cardColor,
    Color textColor,
    Color subTextColor,
    Color borderColor,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            exercise,
            style: TextStyle(
              color: textColor,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF1B1A18)
                  : const Color(0xFF748067).withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: borderColor, width: 1.5),
            ),
            child: Center(
              child: Text(
                "🎥 Video Demonstration Here (Coming Soon)",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: subTextColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Watch how to perform the ${exercise.toLowerCase()} with proper form before starting.",
            style: TextStyle(
              fontSize: 14,
              color: subTextColor,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

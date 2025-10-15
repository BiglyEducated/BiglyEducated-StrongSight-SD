import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class ExercisesPage extends StatefulWidget {
  const ExercisesPage({super.key});

  @override
  State<ExercisesPage> createState() => _ExercisesPageState();
}

class _ExercisesPageState extends State<ExercisesPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  final List<Map<String, dynamic>> _exercises = [
    {
      "name": "Squat",
      "image": "assets/images/Squat.png",
      "muscles": "Quadriceps, Glutes, Hamstrings, Core",
      "equipment": "Barbell, Squat Rack (optional)",
      "form": [
        "Stand with feet shoulder-width apart and toes slightly pointed out.",
        "Keep chest up and core tight.",
        "Lower hips down and back until thighs are parallel to the floor.",
        "Push through heels to return to the starting position."
      ]
    },
    {
      "name": "Bench Press",
      "image": "assets/images/BenchPress.png",
      "muscles": "Chest, Shoulders, Triceps",
      "equipment": "Barbell, Flat Bench",
      "form": [
        "Lie flat on a bench with your feet planted on the floor.",
        "Grip the bar slightly wider than shoulder width.",
        "Lower the bar slowly to mid-chest level.",
        "Push the bar back up until your arms are fully extended."
      ]
    },
    {
      "name": "Deadlift",
      "image": "assets/images/Deadlift.png",
      "muscles": "Hamstrings, Glutes, Back, Core, Forearms",
      "equipment": "Barbell, Lifting Belt (optional)",
      "form": [
        "Stand with feet hip-width apart and barbell over mid-foot.",
        "Bend at the hips and knees, keeping your back straight.",
        "Grip the bar just outside your knees.",
        "Drive through your heels, extending hips and knees to lift the bar.",
        "Lower under control by hinging at the hips."
      ]
    },
    {
      "name": "Bicep Curls",
      "image": "assets/images/BicepCurl.png",
      "muscles": "Biceps Brachii, Forearms",
      "equipment": "Dumbbells or Barbell",
      "form": [
        "Stand tall with arms fully extended and elbows close to torso.",
        "Curl the weight upward while contracting your biceps.",
        "Pause at the top, then slowly lower the weight back down.",
        "Avoid swinging your body during the motion."
      ]
    },
  ];

  List<Map<String, dynamic>> get _filteredExercises {
    if (_searchQuery.isEmpty) return _exercises;
    final query = _searchQuery.toLowerCase();
    return _exercises.where((ex) {
      return ex["name"].toLowerCase().contains(query) ||
          ex["muscles"].toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    // 🎨 StrongSight colors
    const ivory = Color(0xFFF3EBD3);
    const green = Color(0xFF094941);
    const espresso = Color(0xFF12110F);

    final bgColor = isDark ? espresso : const Color(0xFFFCF5E3);
    final cardColor = isDark ? const Color(0xFF1A1917) : Colors.white;
    final textColor = green;
    final subTextColor = isDark ? const Color(0xFFD9CBB8) : Colors.grey;
    final accentColor = green;

    return Scaffold(
      backgroundColor: bgColor,

      // 🧩 Ivory header for light mode, cream for dark
      appBar: AppBar(
        backgroundColor: isDark ? ivory : ivory,
        title: const Text(
          'Exercises',
          style: TextStyle(
            color: green,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: green),
      ),

      body: Column(
        children: [
          // 🔍 Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value),
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                hintText: "Search by exercise or muscle group...",
                hintStyle: TextStyle(color: subTextColor),
                prefixIcon: Icon(Icons.search, color: accentColor),
                filled: true,
                fillColor: isDark ? const Color(0xFF1B1A18) : Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: accentColor.withOpacity(0.6),
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: accentColor, width: 2),
                ),
              ),
            ),
          ),

          // 🏋️ Exercise List
          Expanded(
            child: _filteredExercises.isEmpty
                ? Center(
                    child: Text(
                      "No exercises found.",
                      style: TextStyle(color: subTextColor, fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filteredExercises.length,
                    itemBuilder: (context, index) {
                      final ex = _filteredExercises[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 18),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            if (!isDark)
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 6,
                                offset: const Offset(0, 4),
                              ),
                          ],
                        ),
                        child: ExpansionTile(
                          collapsedBackgroundColor: cardColor,
                          backgroundColor: cardColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          title: Row(
                            children: [
                              // 🖼 Thumbnail
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.asset(
                                  ex["image"],
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  ex["name"],
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          childrenPadding:
                              const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          children: [
                            _buildInfoRow("Muscles Worked:", ex["muscles"], textColor, subTextColor),
                            _buildInfoRow("Equipment:", ex["equipment"], textColor, subTextColor),
                            const SizedBox(height: 8),
                            Text(
                              "Proper Form:",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: (ex["form"] as List<String>).map((step) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 2),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "• ",
                                        style: TextStyle(
                                          color: accentColor.withOpacity(0.8),
                                          fontSize: 15,
                                          height: 1.4,
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          step,
                                          style: TextStyle(
                                            color: textColor.withOpacity(0.9),
                                            fontSize: 15,
                                            height: 1.4,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 12),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, Color textColor, Color subTextColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label ",
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: subTextColor,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

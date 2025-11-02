import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final String userName = "Yoendry";
  final String profileImagePath = "assets/images/profile_placeholder.png";

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    // --- StrongSight colors ---
    const ivory = Color(0xFFF3EBD3);
    const green = Color(0xFF094941);
    const espresso = Color(0xFF12110F);
    const darkModeGreen = Color(0xFF039E39); // light pastel green
    const lightModeGreen = Color(0xFF094941); // deep dark green

    final bgColor = isDark ? espresso : const Color(0xFFFCF5E3);
    final cardColor = isDark ? const Color(0xFF1A1917) : Colors.white;
    final primaryTextColor = isDark ? darkModeGreen : lightModeGreen;
    final subTextColor = isDark ? const Color(0xFFD9CBB8) : Colors.grey[700]!;
    final accentColor = isDark ? darkModeGreen : lightModeGreen;

    return Scaffold(
      backgroundColor: bgColor,
      endDrawerEnableOpenDragGesture: true,

      // ---------- Sidebar Drawer ----------
      endDrawer: Drawer(
        backgroundColor: cardColor,
        child: GestureDetector(
          onHorizontalDragUpdate: (details) {
            if (details.primaryDelta! > 15) {
              Navigator.of(context).pop();
            }
          },
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage(profileImagePath),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    userName,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: primaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text("Email: yoendry@example.com",
                      style: TextStyle(color: subTextColor)),
                  Text("Phone: (407) 555-1234",
                      style: TextStyle(color: subTextColor)),
                  Text("Weight: 160 lbs",
                      style: TextStyle(color: subTextColor)),
                  Text("Height: 5'10\"",
                      style: TextStyle(color: subTextColor)),
                  const SizedBox(height: 20),
                  Divider(color: subTextColor.withOpacity(0.4)),
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.redAccent),
                    title:
                        Text("Log Out", style: TextStyle(color: subTextColor)),
                    onTap: () => Navigator.pushReplacementNamed(context, '/'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

      // ---------- Page Content ----------
      body: Column(
        children: [
          // ---------- Header ----------
          Container(
            color: ivory,
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 30),
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Welcome back,",
                      style: TextStyle(
                        color: green.withOpacity(0.8),
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      userName,
                      style: const TextStyle(
                        color: green,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Builder(
                  builder: (context) => GestureDetector(
                    onTap: () => Scaffold.of(context).openEndDrawer(),
                    child: CircleAvatar(
                      radius: 28,
                      backgroundColor: accentColor,
                      backgroundImage: AssetImage(profileImagePath),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ---------- Scrollable Content ----------
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildFitnessScoreCard(cardColor, primaryTextColor, subTextColor, accentColor),
                  const SizedBox(height: 20),
                  _buildSectionTitle("Recent Workouts", primaryTextColor),
                  _buildWorkoutList(cardColor, primaryTextColor, subTextColor, accentColor),
                  const SizedBox(height: 20),
                  _buildSectionTitle("Metrics & Improvements", primaryTextColor),
                  _buildMetricsRow(cardColor, primaryTextColor, subTextColor, accentColor),
                  const SizedBox(height: 20),
                  _buildSectionTitle("Personal Records (PR Tracker)", primaryTextColor),
                  _buildPRTracker(cardColor, primaryTextColor, subTextColor, accentColor),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- COMPONENTS ----------

  Widget _buildFitnessScoreCard(Color cardColor, Color textColor, Color subTextColor, Color accentColor) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            "Overall Fitness Score",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 18,
              color: textColor,
            ),
          ),
          const SizedBox(height: 10),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 120,
                width: 120,
                child: CircularProgressIndicator(
                  value: 0.76,
                  strokeWidth: 10,
                  backgroundColor: subTextColor.withOpacity(0.2),
                  color: accentColor,
                ),
              ),
              Text(
                "76",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "Good Progress! Keep training 💪",
            style: TextStyle(
              color: subTextColor,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color textColor) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: textColor,
      ),
    );
  }

    Widget _buildWorkoutList(Color cardColor, Color textColor, Color subTextColor, Color accentColor) {
    final workouts = [
      {"title": "Push Day", "date": "Oct 9", "duration": "1h 10m"},
      {"title": "Leg Day", "date": "Oct 8", "duration": "1h 25m"},
      {"title": "Cardio + Core", "date": "Oct 7", "duration": "50m"},
    ];

    return Column(
      children: workouts.map((w) {
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 6,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Workout Title → now uses subTextColor instead of textColor
              Text(
                w["title"]!,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: subTextColor, // changed from textColor ✅
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    w["date"]!,
                    style: TextStyle(color: subTextColor.withOpacity(0.9), fontSize: 14),
                  ),
                  Text(
                    w["duration"]!,
                    style: TextStyle(
                      color: accentColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMetricsRow(Color cardColor, Color textColor, Color subTextColor, Color accentColor) {
    final metrics = [
      {"title": "Volume", "value": "12,400 lbs"},
      {"title": "Duration", "value": "5h 30m"},
      {"title": "Calories", "value": "1,950 kcal"},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: metrics.map((m) {
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(m["title"]!, style: TextStyle(fontWeight: FontWeight.w500, color: subTextColor)),
                const SizedBox(height: 8),
                Text(m["value"]!,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: accentColor,
                    )),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPRTracker(Color cardColor, Color textColor, Color subTextColor, Color accentColor) {
    final prs = [
      {"lift": "Bench Press", "weight": "205 lbs"},
      {"lift": "Squat", "weight": "275 lbs"},
      {"lift": "Deadlift", "weight": "315 lbs"},
    ];

    return Column(
      children: prs.map((p) {
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 6,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(p["lift"]!,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: subTextColor)),
              Text(p["weight"]!,
                  style: TextStyle(fontSize: 16, color: accentColor, fontWeight: FontWeight.w700)),
            ],
          ),
        );
      }).toList(),
    );
  }
}

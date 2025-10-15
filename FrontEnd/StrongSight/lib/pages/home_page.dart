import 'package:flutter/material.dart';

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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      endDrawerEnableOpenDragGesture: true,

      //Sidebar Drawer
      endDrawer: Drawer(
        backgroundColor: theme.scaffoldBackgroundColor,
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
                  const CircleAvatar(
                    radius: 50,
                    backgroundImage:
                        AssetImage("assets/images/profile_placeholder.png"),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    userName,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text("Email: yoendry@example.com",
                      style: TextStyle(color: theme.colorScheme.onBackground)),
                  Text("Phone: (407) 555-1234",
                      style: TextStyle(color: theme.colorScheme.onBackground)),
                  Text("Weight: 160 lbs",
                      style: TextStyle(color: theme.colorScheme.onBackground)),
                  Text("Height: 5'10\"",
                      style: TextStyle(color: theme.colorScheme.onBackground)),
                  const SizedBox(height: 20),
                  Divider(color: theme.dividerColor),
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.redAccent),
                    title: Text("Log Out",
                        style:
                            TextStyle(color: theme.colorScheme.onBackground)),
                    onTap: () => Navigator.pushReplacementNamed(context, '/'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

      //Page Content
      body: Column(
        children: [
          //Header
          Container(
            color: const Color(0xFFF3EBD3), //ivory background
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
                        color: const Color(0xFF094941).withOpacity(0.8), //green text
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      userName,
                      style: const TextStyle(
                        color: Color(0xFF094941), //green text
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Builder(
                  builder: (context) => GestureDetector(
                    onTap: () => Scaffold.of(context).openEndDrawer(),
                    child: const CircleAvatar(
                      radius: 28,
                      backgroundColor: Color(0xFF094941), //dark green border
                      backgroundImage: AssetImage("assets/images/profile_placeholder.png"),
                    ),
                  ),
                ),
              ],
            ),
          ),


          //Scrollable content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildFitnessScoreCard(theme),
                  const SizedBox(height: 20),
                  _buildSectionTitle("Recent Workouts", theme),
                  _buildWorkoutList(theme),
                  const SizedBox(height: 20),
                  _buildSectionTitle("Metrics & Improvements", theme),
                  _buildMetricsRow(theme),
                  const SizedBox(height: 20),
                  _buildSectionTitle("Personal Records (PR Tracker)", theme),
                  _buildPRTracker(theme),
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

  Widget _buildFitnessScoreCard(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          if (theme.brightness == Brightness.light)
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
              color: theme.colorScheme.primary,
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
                  backgroundColor:
                      theme.colorScheme.secondary.withOpacity(0.2),
                  color: theme.colorScheme.primary,
                ),
              ),
              Text(
                "76",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "Good Progress! Keep training 💪",
            style: TextStyle(
              color: theme.colorScheme.onBackground.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: theme.colorScheme.primary,
      ),
    );
  }

  Widget _buildWorkoutList(ThemeData theme) {
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
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              if (theme.brightness == Brightness.light)
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
              Text(
                w["title"]!,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onBackground,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(w["date"]!,
                      style: TextStyle(
                          color: theme.colorScheme.onBackground
                              .withOpacity(0.7),
                          fontSize: 14)),
                  Text(w["duration"]!,
                      style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMetricsRow(ThemeData theme) {
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
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                if (theme.brightness == Brightness.light)
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 4),
                  ),
              ],
            ),
            child: Column(
              children: [
                Text(m["title"]!,
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.onBackground)),
                const SizedBox(height: 8),
                Text(m["value"]!,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPRTracker(ThemeData theme) {
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
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              if (theme.brightness == Brightness.light)
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
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onBackground)),
              Text(p["weight"]!,
                  style: TextStyle(
                      fontSize: 16,
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w700)),
            ],
          ),
        );
      }).toList(),
    );
  }
}

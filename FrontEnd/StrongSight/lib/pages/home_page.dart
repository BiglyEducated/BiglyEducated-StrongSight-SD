import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  final String userName = "Yoendry";
  final String profileImagePath = "assets/images/profile_placeholder.png";
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _isDrawerOpen = false;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  int _streakDays = 5;
  int? _expandedWorkoutIndex;

  final Map<String, dynamic> todaysWorkout = {
    "title": "Push Day",
    "focus": "Chest, Shoulders, Triceps",
    "duration": "1h 15m",
    "exercises": [
      {"name": "Bench Press", "sets": "4 x 8"},
      {"name": "Overhead Press", "sets": "3 x 10"},
      {"name": "Tricep Dips", "sets": "3 x 12"},
    ]
  };

  final List<Map<String, dynamic>> workouts = [
    {
      "title": "Push Day",
      "date": "Nov 4",
      "duration": "1h 10m",
      "exercises": [
        {"name": "Bench Press", "sets": "4 x 8"},
        {"name": "Incline Dumbbell Press", "sets": "3 x 10"},
        {"name": "Tricep Dips", "sets": "3 x 12"},
      ]
    },
    {
      "title": "Leg Day",
      "date": "Nov 3",
      "duration": "1h 25m",
      "exercises": [
        {"name": "Back Squat", "sets": "5 x 5"},
        {"name": "Leg Press", "sets": "4 x 10"},
        {"name": "Calf Raises", "sets": "3 x 15"},
      ]
    },
    {
      "title": "Cardio + Core",
      "date": "Nov 2",
      "duration": "50m",
      "exercises": [
        {"name": "Treadmill Run", "sets": "30 min"},
        {"name": "Plank", "sets": "3 x 1 min"},
        {"name": "Crunches", "sets": "3 x 20"},
      ]
    },
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _toggleDrawer() {
    if (_isDrawerOpen) {
      Navigator.of(context).pop();
    } else {
      _scaffoldKey.currentState!.openEndDrawer();
    }
  }

  void _onDrawerChanged(bool isOpen) {
    setState(() {
      _isDrawerOpen = isOpen;
      if (isOpen) {
        _fadeController.forward();
      } else {
        _fadeController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    // --- StrongSight Colors ---
    const ivory = Color(0xFFF3EBD3);
    const green = Color(0xFF094941);
    const espresso = Color(0xFF12110F);
    const darkModeGreen = Color(0xFF039E39);
    const lightModeGreen = Color(0xFF094941);

    final bgColor = isDark ? espresso : const Color(0xFFFCF5E3);
    final cardColor = isDark ? const Color(0xFF1A1917) : Colors.white;
    final primaryTextColor = isDark ? darkModeGreen : lightModeGreen;
    final subTextColor = isDark ? const Color(0xFFD9CBB8) : Colors.grey[700]!;
    final accentColor = isDark ? darkModeGreen : lightModeGreen;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: bgColor,
      endDrawerEnableOpenDragGesture: true,
      onEndDrawerChanged: _onDrawerChanged,

      // ---------- Sidebar ----------
      endDrawer: Drawer(
        elevation: 16,
        backgroundColor: cardColor,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: CircleAvatar(radius: 50, backgroundImage: AssetImage(profileImagePath)),
                ),
                const SizedBox(height: 16),
                Text(userName,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: primaryTextColor)),
                const SizedBox(height: 8),
                Text("Email: yoendry@example.com", style: TextStyle(color: subTextColor)),
                Text("Phone: (407) 555-1234", style: TextStyle(color: subTextColor)),
                Text("Weight: 160 lbs", style: TextStyle(color: subTextColor)),
                Text("Height: 5'10\"", style: TextStyle(color: subTextColor)),
                const SizedBox(height: 20),
                Divider(color: subTextColor.withOpacity(0.4)),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.redAccent),
                  title: Text("Log Out", style: TextStyle(color: subTextColor)),
                  onTap: () => Navigator.pushReplacementNamed(context, '/'),
                ),
              ],
            ),
          ),
        ),
      ),

      // ---------- Main Body ----------
      body: Stack(
        children: [
          Column(
            children: [
              // ---------- Header ----------
              Container(
                color: ivory,
                padding: const EdgeInsets.fromLTRB(20, 50, 20, 30),
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text("Welcome back,",
                          style: TextStyle(color: green.withOpacity(0.8), fontSize: 16)),
                      Text(userName,
                          style: const TextStyle(color: green, fontSize: 24, fontWeight: FontWeight.bold)),
                    ]),
                    GestureDetector(
                      onTap: _toggleDrawer,
                      child: CircleAvatar(
                        radius: 28,
                        backgroundColor: accentColor,
                        backgroundImage: AssetImage(profileImagePath),
                      ),
                    ),
                  ],
                ),
              ),

              // ---------- Scrollable Body ----------
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildStreakCard(cardColor, primaryTextColor, subTextColor, accentColor),
                      const SizedBox(height: 20),
                      _buildSectionTitle("Today's Workout", primaryTextColor),
                      _buildTodaysWorkout(cardColor, primaryTextColor, subTextColor, accentColor),
                      const SizedBox(height: 20),
                      _buildSectionTitle("Recent Workouts", primaryTextColor),
                      _buildExpandableWorkoutList(cardColor, primaryTextColor, subTextColor, accentColor),
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

          // ---------- Dark Overlay ----------
          IgnorePointer(
            ignoring: !_isDrawerOpen,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Container(color: Colors.black.withOpacity(0.5)),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- COMPONENTS ----------

  Widget _buildSectionTitle(String title, Color textColor) {
    return Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: textColor));
  }

  Widget _buildStreakCard(Color cardColor, Color textColor, Color subTextColor, Color accentColor) {
    final streakBars = [1, 1, 1, 0.8, 0.4, 0.0, 0.0];

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Icon(Icons.local_fire_department, color: accentColor, size: 42),
          const SizedBox(width: 16),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text("$_streakDays-day streak",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: accentColor)),
              const SizedBox(height: 4),
              Text(
                _streakDays < 3
                    ? "Just getting started!"
                    : _streakDays < 7
                        ? "Keep it going!"
                        : "Amazing consistency!",
                style: TextStyle(color: subTextColor, fontSize: 14),
              ),
              const SizedBox(height: 10),
              Row(
                children: streakBars.map((v) {
                  return Expanded(
                    child: Container(
                      height: (v * 10) + 6,
                      margin: const EdgeInsets.symmetric(horizontal: 1),
                      decoration: BoxDecoration(
                        color: v > 0 ? accentColor : subTextColor.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildTodaysWorkout(
    Color cardColor, Color textColor, Color subTextColor, Color accentColor) {
  final bool hasWorkout = todaysWorkout["title"] != null &&
      todaysWorkout["exercises"] != null &&
      (todaysWorkout["exercises"] as List).isNotEmpty;

  return Container(
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
    child: hasWorkout
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                todaysWorkout["title"],
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: accentColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                todaysWorkout["focus"],
                style: TextStyle(color: subTextColor, fontSize: 14),
              ),
              const SizedBox(height: 10),
              ...(todaysWorkout["exercises"] as List).map<Widget>((exercise) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      exercise["name"],
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      exercise["sets"],
                      style: TextStyle(color: subTextColor, fontSize: 14),
                    ),
                  ],
                );
              }).toList(),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  "Est. Duration: ${todaysWorkout["duration"]}",
                  style: TextStyle(
                    color: subTextColor,
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          )
        : Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  Icon(Icons.hotel, color: subTextColor.withOpacity(0.7), size: 36),
                  const SizedBox(height: 10),
                  Text(
                    "No workout planned,\nEnjoy your rest day",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: subTextColor,
                      fontSize: 15,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ),
  );
}


  // ---------- Expandable Recent Workouts ----------
  Widget _buildExpandableWorkoutList(
      Color cardColor, Color textColor, Color subTextColor, Color accentColor) {
    return Column(
      children: List.generate(workouts.length, (index) {
        final workout = workouts[index];
        final isExpanded = _expandedWorkoutIndex == index;

        return GestureDetector(
          onTap: () => setState(() => _expandedWorkoutIndex = isExpanded ? null : index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(vertical: 6),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 4))],
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(workout["title"],
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: accentColor)),
                Icon(isExpanded ? Icons.expand_less : Icons.expand_more, color: subTextColor),
              ]),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(workout["date"], style: TextStyle(color: subTextColor, fontSize: 14)),
                  Text(workout["duration"],
                      style: TextStyle(color: subTextColor, fontWeight: FontWeight.w500)),
                ],
              ),
              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Column(
                    children: [
                      ...workout["exercises"].map<Widget>((e) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(e["name"],
                                  style: TextStyle(color: textColor, fontWeight: FontWeight.w500)),
                              Text(e["sets"],
                                  style: TextStyle(color: subTextColor, fontSize: 13)),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
                crossFadeState:
                    isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 200),
              ),
            ]),
          ),
        );
      }),
    );
  }

  // ---------- Metrics & PR Tracker ----------
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
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 4)),
              ],
            ),
            child: Column(
              children: [
                Text(m["title"]!,
                    style: TextStyle(fontWeight: FontWeight.w500, color: subTextColor)),
                const SizedBox(height: 8),
                Text(m["value"]!,
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: accentColor)),
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
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 4)),
            ],
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(p["lift"]!,
                  style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: subTextColor)),
              Text(p["weight"]!,
                  style:
                      TextStyle(fontSize: 16, color: accentColor, fontWeight: FontWeight.w700)),
            ],
          ),
        );
      }).toList(),
    );
  }
}

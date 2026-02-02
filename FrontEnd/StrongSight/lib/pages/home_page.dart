import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';


String _formatWorkoutDate(DateTime date) {
  const months = [
    "", "Jan", "Feb", "Mar", "Apr", "May", "Jun",
    "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
  ];
  return "${months[date.month]} ${date.day}";
}


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}


//Workout data models
class Workout {
  final String workoutName;
  final DateTime date;
  final List<WorkoutExercise> exercises;

  Workout({
    required this.workoutName,
    required this.exercises,
    required this.date,
  });
}

class WorkoutExercise {
  final String name;
  final String equipment;
  final List<WorkoutSet> sets;

  WorkoutExercise({
    required this.name,
    required this.sets,
    required this.equipment,
  });
}

class WorkoutSet {
  final int reps;
  final int weight;

  WorkoutSet({
    required this.reps,
    required this.weight,
  });
}


class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final String userName = "Yoendry";
  final String profileImagePath = "assets/images/profile_placeholder.png";
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _isDrawerOpen = false;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  late Color workoutTitleColor;
  late Color exerciseNameColor;


  int _streakDays = 0;
  int? _expandedWorkoutIndex;
  

  // --------------------- Today's Workout --------------------------------------------
  Workout? todaysWorkout =Workout(                                                                             //////////API FOR TODAYS WORKOUT GOES HERE//////////////////////////////////////////////////////
  workoutName: "Leetcode Session",
  date: DateTime.now(),
  exercises: [
    WorkoutExercise(
      name: "Squat",
      equipment: "Barbell",
      sets: [
        WorkoutSet(reps: 8, weight: 135),
        WorkoutSet(reps: 8, weight: 135),
        WorkoutSet(reps: 6, weight: 145),
      ],
    ),
    WorkoutExercise(
      name: "Bench Press",
      equipment: "Barbell",
      sets: [
        WorkoutSet(reps: 10, weight: 95),
      ],
    ),
    WorkoutExercise(
      name: "Bicep Curls",
      equipment: "Dumbbell",
      sets: [
        WorkoutSet(reps: 12, weight: 25),
        WorkoutSet(reps: 12, weight: 25),
      ],
    ),
  ],
);


// --------------------- Recent Workouts ---------------------------------------------
  final List<Workout> recentWorkouts = [
    Workout(
      workoutName: "Push Day",
      date: DateTime.now().subtract(const Duration(days: 1)),
      exercises: [
        WorkoutExercise(
          name: "Bench Press",
          equipment: "Barbell",
          sets: [
            WorkoutSet(reps: 8, weight: 135),
            WorkoutSet(reps: 8, weight: 135),
            WorkoutSet(reps: 8, weight: 135),
            WorkoutSet(reps: 8, weight: 135),
          ],
        ),
        WorkoutExercise(
          name: "Incline Dumbbell Press",
          equipment: "Dumbbell",
          sets: [
            WorkoutSet(reps: 10, weight: 50),
            WorkoutSet(reps: 10, weight: 50),
            WorkoutSet(reps: 10, weight: 50),
          ],
        ),
      ],
    ),

    Workout(
      workoutName: "Leg Day",
      date: DateTime.now().subtract(const Duration(days: 1)),
      exercises: [
        WorkoutExercise(
          name: "Back Squat",
          equipment: "Barbell",
          sets: [
            WorkoutSet(reps: 5, weight: 225),
            WorkoutSet(reps: 5, weight: 225),
            WorkoutSet(reps: 5, weight: 225),
            WorkoutSet(reps: 5, weight: 225),
            WorkoutSet(reps: 5, weight: 225),
          ],
        ),
      ],
    ),
    Workout(
      workoutName: "Chest Day",
      date: DateTime.now().subtract(const Duration(days: 1)),
      exercises: [
        WorkoutExercise(
          name: "Back Squat",
          equipment: "Barbell",
          sets: [
            WorkoutSet(reps: 5, weight: 225),
            WorkoutSet(reps: 5, weight: 225),
            WorkoutSet(reps: 5, weight: 225),
            WorkoutSet(reps: 5, weight: 225),
            WorkoutSet(reps: 5, weight: 225),
          ],
        ),
      ],
    ),
    Workout(
      workoutName: "Arm Day",
      date: DateTime.now().subtract(const Duration(days: 1)),
      exercises: [
        WorkoutExercise(
          name: "Back Squat",
          equipment: "Barbell",
          sets: [
            WorkoutSet(reps: 5, weight: 225),
            WorkoutSet(reps: 5, weight: 225),
            WorkoutSet(reps: 5, weight: 225),
            WorkoutSet(reps: 5, weight: 225),
            WorkoutSet(reps: 5, weight: 225),
          ],
        ),
      ],
    ),
    Workout(
      workoutName: "Back Day",
      date: DateTime.now().subtract(const Duration(days: 1)),
      exercises: [
        WorkoutExercise(
          name: "Back Squat",
          equipment: "Barbell",
          sets: [
            WorkoutSet(reps: 5, weight: 225),
            WorkoutSet(reps: 5, weight: 225),
            WorkoutSet(reps: 5, weight: 225),
            WorkoutSet(reps: 5, weight: 225),
            WorkoutSet(reps: 5, weight: 225),
          ],
        ),
      ],
    ),
    Workout(
      workoutName: "Cardio Day",
      date: DateTime.now().subtract(const Duration(days: 1)),
      exercises: [
        WorkoutExercise(
          name: "Back Squat",
          equipment: "Barbell",
          sets: [
            WorkoutSet(reps: 5, weight: 225),
            WorkoutSet(reps: 5, weight: 225),
            WorkoutSet(reps: 5, weight: 225),
            WorkoutSet(reps: 5, weight: 225),
            WorkoutSet(reps: 5, weight: 225),
          ],
        ),
      ],
    ),
  ];


  // --------------------- WEEKLY STREAK LOGIC ---------------------------------------------
  DateTime _parseWorkoutDate(String dateString) {
    final parts = dateString.split(" ");
    final monthStr = parts[0];
    final day = int.parse(parts[1]);
    final year = DateTime.now().year;

    final month = {
      "Jan": 1,
      "Feb": 2,
      "Mar": 3,
      "Apr": 4,
      "May": 5,
      "Jun": 6,
      "Jul": 7,
      "Aug": 8,
      "Sep": 9,
      "Oct": 10,
      "Nov": 11,
      "Dec": 12,
    }[monthStr];

    return DateTime(year, month!, day);
  }

  //Monday → Sunday dates for the current week
  List<DateTime> _getCurrentWeekDates() {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    return List.generate(
        7, (i) => DateTime(monday.year, monday.month, monday.day + i));
  }

  //Convert month number back to "Nov"
  String _monthNumberToStr(int m) {
    const months = [
      "",
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec"
    ];
    return months[m];
  }

  //Count how many days this week the user worked out
  int _calculateWeeklyStreak() {
    final weekDates = _getCurrentWeekDates();
    int count = 0;

    for (final date in weekDates) {
      final formatted = "${_monthNumberToStr(date.month)} ${date.day}";
      final hasWorkout = recentWorkouts.isNotEmpty;
      if (hasWorkout) count++;
    }

    return count;
  }

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _fadeAnimation =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut);

    //Calculate weekly streak
    _streakDays = _calculateWeeklyStreak();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  // --------------------- UI BEGINS ---------------------------------------------
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    const ivory = Color(0xFFF3EBD3);
    const green = Color(0xFF094941);
    const espresso = Color(0xFF12110F);
    const darkModeGreen = Color(0xFF039E39);
    const lightModeGreen = Color(0xFF094941);

    final bgColor = isDark ? espresso : const Color(0xFFFCF5E3);
    final cardColor = isDark ? const Color(0xFF1A1917) : Colors.white;
    final primaryTextColor = isDark ? darkModeGreen : lightModeGreen;
    workoutTitleColor =
    isDark ? const Color.fromARGB(255, 197, 183, 142) : lightModeGreen;
    exerciseNameColor =
    isDark ? const Color.fromARGB(255, 198, 184, 143) : lightModeGreen;

    final subTextColor =
        isDark ? const Color(0xFFD9CBB8) : Colors.grey[700]!;
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
                CircleAvatar(
                    radius: 50, backgroundImage: AssetImage(profileImagePath)),
                const SizedBox(height: 16),
                Text(userName,
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: primaryTextColor)),
                const SizedBox(height: 8),
                Text("Email: yoendry@example.com", style: TextStyle(color: subTextColor)),
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

      // ---------- BODY ----------
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
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Welcome back,",
                              style: TextStyle(
                                  color: green.withOpacity(0.8), fontSize: 16)),
                          Text(userName,
                              style: const TextStyle(
                                  color: green,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold)),
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
                      _buildStreakCard(
                          cardColor, primaryTextColor, subTextColor, accentColor),
                      const SizedBox(height: 20),

                      _buildSectionTitle(
                          "Today's Workout", primaryTextColor),
                      _buildTodaysWorkout(
                          cardColor, primaryTextColor, subTextColor, accentColor),

                      const SizedBox(height: 20),

                      _buildSectionTitle(
                          "Recent Workouts", primaryTextColor),
                      _buildExpandableWorkoutList(cardColor, primaryTextColor,
                          subTextColor, accentColor),

                      const SizedBox(height: 20),

                      _buildSectionTitle(
                          "Metrics", primaryTextColor),
                      _buildMetricsRow(
                          cardColor, primaryTextColor, subTextColor, accentColor),

                      const SizedBox(height: 20),

                      _buildSectionTitle(
                          "Personal Records", primaryTextColor),
                      _buildPRTracker(
                          cardColor, primaryTextColor, subTextColor, accentColor),

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
    return Text(title,
        style:
            TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: textColor));
  }

  // ---------- WEEKLY STREAK CARD ----------
  Widget _buildStreakCard(
      Color cardColor, Color textColor, Color subTextColor, Color accentColor) {
    final streakBars =
        List.generate(7, (i) => i < _streakDays ? 1.0 : 0.0);

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4))
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Icon(Icons.local_fire_department, color: Color.fromARGB(255, 173, 17, 17), size: 42),
          const SizedBox(width: 16),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text("${_streakDays}-day streak",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: accentColor)),
              const SizedBox(height: 4),
              Text(
                "Mon–Sun progress",
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
                        color:
                            v > 0 ? Color(0xFFFF0000) : Color.fromARGB(255, 200, 59, 12),
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

  Widget _buildNoWorkoutCard(
  Color cardColor,
  Color subTextColor,
  Color accentColor,
) {
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
    child: Column(
      children: [
        Icon(Icons.event_available,
            color: subTextColor.withOpacity(0.7), size: 36),
        const SizedBox(height: 10),
        Text(
          "No workout scheduled for today",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: subTextColor,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.calendar_today, size: 18),
            label: const Text("Set Workout in Calendar"),
            style: ElevatedButton.styleFrom(
              backgroundColor: accentColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/calendar');
            },
          ),
        ),
      ],
    ),
  );
}


  // ---------- Today's Workout ----------
  Widget _buildTodaysWorkout(
  Color cardColor,
  Color textColor,
  Color subTextColor,
  Color accentColor,
) {
  final bool hasWorkout =
      todaysWorkout != null && todaysWorkout!.exercises.isNotEmpty;

  return hasWorkout
      ? GestureDetector(
          onTap: () => setState(() {
            _expandedWorkoutIndex =
                _expandedWorkoutIndex == -1 ? null : -1;
          }),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(vertical: 6),
            padding: const EdgeInsets.all(16),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ---- Header----
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      todaysWorkout!.workoutName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: workoutTitleColor,
                      ),
                    ),
                    Icon(
                      _expandedWorkoutIndex == -1
                          ? Icons.expand_less
                          : Icons.expand_more,
                      color: subTextColor,
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                // ---- Expandable Per-Set Details ----
                AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Column(
                      children: todaysWorkout!.exercises.map((exercise) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Exercise Name
                              Text(
                                exercise.name,
                                style: TextStyle(
                                  color: exerciseNameColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                exercise.equipment,
                                style: TextStyle(
                                  color: subTextColor,
                                  fontSize: 12,
                                ),),
                              const SizedBox(height: 4),

                              // Individual Sets
                              ...List.generate(exercise.sets.length, (i) {
                                final set = exercise.sets[i];

                                return Padding(
                                  padding: const EdgeInsets.only(
                                      left: 12, top: 2, bottom: 2),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Set ${i + 1}",
                                        style: TextStyle(
                                          color: subTextColor,
                                          fontSize: 13,
                                        ),
                                      ),
                                      Text(
                                        "${set.reps} @ ${set.weight}",
                                        style: TextStyle(
                                          color: accentColor,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  crossFadeState: _expandedWorkoutIndex == -1
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 200),
                ),
              ],
            ),
          ),
        )
      : _buildNoWorkoutCard(cardColor, subTextColor, accentColor);
}



  // ---------- Expandable Recent Workouts ----------
  Widget _buildExpandableWorkoutList(
      Color cardColor, Color textColor, Color subTextColor, Color accentColor,) {
    
    //Takes the 6 most recent workouts
    final recent = recentWorkouts.take(6).toList();

    return Column(
      children: List.generate(recent.length, (index) {
        final workout = recent[index];
        final isExpanded = _expandedWorkoutIndex == index;

        return GestureDetector(
          onTap: () =>
              setState(() => _expandedWorkoutIndex = isExpanded ? null : index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(vertical: 6),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 4))
              ],
            ),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(workout.workoutName,
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: exerciseNameColor)),
                      Icon(isExpanded ? Icons.expand_less : Icons.expand_more,
                          color: subTextColor)
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_formatWorkoutDate(workout.date),
                          style: TextStyle(color: subTextColor, fontSize: 14)),
                    ],
                  ),
                  AnimatedCrossFade(
                    firstChild: const SizedBox.shrink(),
                    secondChild: Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Column(
                        children: [
                          Column(
                            children: workout.exercises.map((exercise) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 6),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      exercise.name,
                                      style: TextStyle(
                                        color: exerciseNameColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      exercise.equipment,
                                      style: TextStyle(
                                        color: subTextColor,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 4),

                                    ...List.generate(exercise.sets.length, (i) {
                                      final set = exercise.sets[i];
                                      return Padding(
                                        padding: const EdgeInsets.only(left: 12, top: 2),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "Set ${i + 1}",
                                              style: TextStyle(
                                                color: subTextColor,
                                                fontSize: 13,
                                              ),
                                            ),
                                            Text(
                                              "${set.reps} @ ${set.weight}",
                                              style: TextStyle(
                                                color: accentColor,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                              );
                            }).toList(),)
                        ],
                      ),
                    ),
                    crossFadeState: isExpanded
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 200),
                  ),
                ]),
          ),
        );
      }),
    );
  }


  // ---------- Metrics ----------
  Widget _buildMetricsRow(Color cardColor, Color textColor,
      Color subTextColor, Color accentColor) {
    final metrics = [
      //Track the amount of days worked for x amount of months 
      {"title": "Workout Frequency", "value": "87%"},
      //Take the average of the users workout lenghts for a week at a time 
      {"title": "Duration", "value": "Average: 1hr 30min"},
      //Maybe prompt the user for their weigth once a week and display the difference 
      {"title": "Weight", "value": "+5lbs"},
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
                    offset: const Offset(0, 4))
              ],
            ),
            child: Column(
              children: [
                Text(m["title"]!,
                    style: TextStyle(
                        fontWeight: FontWeight.w500, color: subTextColor)),
                const SizedBox(height: 8),
                Text(m["value"]!,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: accentColor)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ---------- PR TRACKER ----------
  Widget _buildPRTracker(Color cardColor, Color textColor, Color accentColor,
      Color subTextColor,) {
    final prs = [
      {"lift": "Bench Press", "weight": "205 lbs", "date": "October 26, 2025"},
      {"lift": "Squat", "weight": "275 lbs", "date": "September 1, 2025"},
      {"lift": "Deadlift", "weight": "315 lbs", "date": "October 12, 2025"},
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
                  offset: const Offset(0, 4))
            ],
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p["lift"]!,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: exerciseNameColor)),
                const SizedBox(height: 4),
                Text(p["date"]!,
                    style: TextStyle(fontSize: 12, color: subTextColor))
              ],
            ),
            Text(p["weight"]!,
                style: TextStyle(
                    fontSize: 16,
                    color: accentColor,
                    fontWeight: FontWeight.w700)),
          ]),
        );
      }).toList(),
    );
  }

  // ---------- Drawer Logic ----------
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
}

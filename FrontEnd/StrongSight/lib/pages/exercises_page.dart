import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';



///-----------MODELS -----------///
class WorkoutSet {
  int reps;
  double weight;

  WorkoutSet({required this.reps, required this.weight});
}

class WorkoutExercise {
  String name;
  List<WorkoutSet> sets;

  WorkoutExercise({
    required this.name,
    required this.sets,
  });
}

class Workout {
  final String workoutName;
  final List<WorkoutExercise> exercises;

  Workout({
    required this.workoutName,
    required this.exercises,
  });
}

///------------PAGE-----------------///

class ExercisesPage extends StatefulWidget {
  const ExercisesPage({super.key});

  @override
  State<ExercisesPage> createState() => _ExercisesPageState();
}

class _ExercisesPageState extends State<ExercisesPage> {
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _pinnedExercises = {};
  String _searchQuery = "";
  Set<String> _selectedMuscles = {};

  //Exercise Card Builder
  Widget _buildExerciseCard({
  required String name,
  required String image,
  required String muscles,
  required String equipment,
  required List<String> form,
  String? stats,
  bool pinnable = false,
}) {
  final isDark =
      Provider.of<ThemeProvider>(context, listen: false).isDarkMode;

  final cardColor = isDark ? const Color(0xFF1A1917) : Colors.white;
  final textColor =
      isDark ? const Color(0xFF039E39) : const Color(0xFF094941);
  final subTextColor =
      isDark ? const Color(0xFFD9CBB8) : Colors.grey[700]!;
  final accentColor = textColor;

  return Container(
    margin: const EdgeInsets.only(bottom: 18),
    decoration: BoxDecoration(
      color: cardColor,
      borderRadius: BorderRadius.circular(16),
    ),
    child: ExpansionTile(
      collapsedBackgroundColor: cardColor,
      backgroundColor: cardColor,
      title: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: isDark
                  ? const Color(0xFF12110F)
                  : const Color(0xFFEDE6D1),
            ),
            child: Image.asset(image, fit: BoxFit.contain),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
          if (pinnable)
            IconButton(
              icon: Icon(
                _isPinned(name) ? Icons.push_pin : Icons.push_pin_outlined,
                color: accentColor,
              ),
              onPressed: () => _togglePin(name),
            ),
        ],
      ),
      childrenPadding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      children: [
        if (stats != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              stats,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: subTextColor,
              ),
            ),
          ),
        _buildInfoRow("Muscles Worked:", muscles, textColor, subTextColor),
        _buildInfoRow("Equipment:", equipment, textColor, subTextColor),
        const SizedBox(height: 8),
        Text(
          "Proper Form:",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        const SizedBox(height: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: form.map((step) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("• ",
                      style: TextStyle(
                        color: accentColor,
                        fontSize: 15,
                      )),
                  Expanded(
                    child: Text(
                      step,
                      style: TextStyle(
                        color: subTextColor,
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
      ],
    ),
  );
}

  // Finds exercise details by name
  Map<String, dynamic>? _findExerciseDetails(String name) {
  return _exercises.firstWhere(
    (ex) => ex["name"] == name,
    orElse: () => {},
  );
}


// Pinning Functionality
bool _isPinned(String exerciseName) {
  return _pinnedExercises.contains(exerciseName);
}

void _togglePin(String exerciseName) {
  setState(() {
    if (_isPinned(exerciseName)) {
      _pinnedExercises.remove(exerciseName);
    } else {
      _pinnedExercises.add(exerciseName);
    }
  });
}

// Get pinned exercise cards
List<Map<String, dynamic>> get _pinnedExerciseCards {
  return _exercises
      .where((ex) => _pinnedExercises.contains(ex["name"]))
      .toList();
}

// Format sets for display
String _formatSets(List<WorkoutSet> sets) {
    return sets.map((s) => "${s.reps} @ ${s.weight} lbs").join(" | ");
  }


  //Todays workout(REPLACE WITH API DATA)
  final Workout? todaysWorkout = Workout(
  workoutName: "Leetcode Session",
  exercises: [
    WorkoutExercise(
      name: "Squat",
      sets: [
        WorkoutSet(reps: 8, weight: 135),
        WorkoutSet(reps: 8, weight: 135),
      ],
    ),
    WorkoutExercise(
      name: "Bench Press",
      sets: [
        WorkoutSet(reps: 10, weight: 95),
      ],
    ),
    WorkoutExercise(
      name: "Bicep Curls",
      sets: [
        WorkoutSet(reps: 12, weight: 25),
        WorkoutSet(reps: 12, weight: 25),
      ],
    ),
  ],
);


  //Exercise Library

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
      "muscles": "Biceps, Forearms",
      "equipment": "Dumbbells or Barbell",
      "form": [
        "Stand tall with arms fully extended and elbows close to torso.",
        "Curl the weight upward while contracting your biceps.",
        "Pause at the top, then slowly lower the weight back down.",
        "Avoid swinging your body during the motion."
      ]
    },
    {
    "name": "Lat Pulldowns",
    "image": "assets/images/LatPulldown.png",
    "muscles": "Lats, Biceps, Rear Delts",
    "equipment": "Cable Machine",
    "form": [
      "Sit down at a lat pulldown station and grab the bar with a wide overhand grip.",
      "Keep your chest tall and engage your core.",
      "Pull the bar down to your upper chest, squeezing your shoulder blades together.",
      "Pause briefly, then slowly return to the starting position with control."
    ]
  },
  {
    "name": "Pull-ups",
    "image": "assets/images/PullUp.png",
    "muscles": "Lats, Biceps, Forearms, Core",
    "equipment": "Pull-up Bar",
    "form": [
      "Grab the pull-up bar with an overhand grip slightly wider than shoulder width.",
      "Hang fully extended, then pull yourself upward until your chin clears the bar.",
      "Pause briefly at the top, then lower yourself down with control.",
      "Avoid swinging or using momentum to complete the movement."
    ]
  },
  {
    "name": "Push-ups",
    "image": "assets/images/PushUp.png",
    "muscles": "Chest, Shoulders, Triceps, Core",
    "equipment": "Bodyweight",
    "form": [
      "Place your hands slightly wider than shoulder-width on the floor.",
      "Keep your body straight from head to heels and your core engaged.",
      "Lower your chest toward the floor until your elbows reach 90 degrees.",
      "Push back up through your palms to return to the starting position."
    ]
  },
  {
    "name": "Sit-ups",
    "image": "assets/images/SitUp.png",
    "muscles": "Abdominals, Hip Flexors",
    "equipment": "Bodyweight or Mat",
    "form": [
      "Lie flat on your back with knees bent and feet anchored.",
      "Place your hands behind your head or cross them over your chest.",
      "Engage your core to lift your upper body toward your knees.",
      "Lower yourself back down slowly with control."
    ]
  },
  {
    "name": "Dumbbell Shoulder Press",
    "image": "assets/images/ShoulderPress.png",
    "muscles": "Deltoids, Triceps, Upper Chest",
    "equipment": "Dumbbells or Barbell",
    "form": [
      "Sit or stand with a dumbbell in each hand at shoulder height, palms facing forward.",
      "Engage your core and press the weights overhead until your arms are fully extended.",
      "Lower the weights slowly back to shoulder height and repeat."
    ]
  },
  {
    "name": "Plank",
    "image": "assets/images/Plank.png",
    "muscles": "Core, Shoulders, Back, Glutes",
    "equipment": "Bodyweight or Mat",
    "form": [
      "Start in a push-up position but rest on your forearms instead of your hands.",
      "Keep your body in a straight line from head to heels.",
      "Engage your abs and glutes, holding the position without letting your hips sag.",
      "Breathe steadily and maintain good form for the duration."
    ]
  },
  {
    "name": "Lunges",
    "image": "assets/images/Lunges.png",
    "muscles": "Glutes, Quads, Hamstrings",
    "equipment": "Bodyweight or Dumbbells",
    "form": [
      "Stand tall with feet hip-width apart and core engaged.",
      "Step forward with one leg and lower until both knees form 90° angles.",
      "Push through your front heel to return to standing position.",
      "Alternate legs and repeat for reps."
    ]
  },
  {
    "name": "Tricep Dips",
    "image": "assets/images/TricepDip.png",
    "muscles": "Triceps, Chest, Shoulders",
    "equipment": "Parallel Bars or Bench",
    "form": [
      "Position your hands shoulder-width apart on parallel bars or a bench behind you.",
      "Lower your body by bending your elbows until they reach 90°.",
      "Press back up to the starting position, keeping your chest lifted."
    ]
  },
  {
    "name": "Seated Cable Row",
    "image": "assets/images/SeatedRow.png",
    "muscles": "Lats, Rhomboids, Biceps",
    "equipment": "Cable Machine",
    "form": [
      "Sit at a cable row station with feet braced and a neutral grip handle.",
      "Keep your back straight and pull the handle toward your torso.",
      "Squeeze your shoulder blades together, then slowly extend your arms forward."
    ]
  },
  {
    "name": "Leg Press",
    "image": "assets/images/LegPress.png",
    "muscles": "Quads, Glutes, Hamstrings",
    "equipment": "Leg Press Machine",
    "form": [
      "Sit in the leg press machine with your feet shoulder-width apart on the platform.",
      "Lower the platform toward you until your knees reach a 90° angle.",
      "Push through your heels to extend your legs without locking your knees."
    ]
  },
  {
    "name": "Calf Raises",
    "image": "assets/images/CalfRaise.png",
    "muscles": "Calves",
    "equipment": "Bodyweight, Dumbbells, or Machine",
    "form": [
      "Stand on the edge of a step with heels hanging off.",
      "Raise your heels as high as possible while contracting your calves.",
      "Pause briefly, then lower your heels below the step for a full stretch."
    ]
  },
  {
    "name": "Russian Twists",
    "image": "assets/images/RussianTwist.png",
    "muscles": "Obliques, Core",
    "equipment": "Bodyweight or Medicine Ball",
    "form": [
      "Sit on the floor with knees bent and feet slightly elevated.",
      "Hold a weight or clasp your hands together.",
      "Twist your torso to each side, engaging your obliques as you move."
    ]
  },
  {
    "name": "Burpees",
    "image": "assets/images/Burpees.png",
    "muscles": "Full Body (Chest, Legs, Core, Shoulders)",
    "equipment": "Bodyweight",
    "form": [
      "Start standing, then squat down and place your hands on the floor.",
      "Jump your feet back into a plank position.",
      "Perform a push-up, then jump your feet forward.",
      "Explosively jump upward and repeat."
    ]
  },
  {
    "name": "Kettlebell Swings",
    "image": "assets/images/KettlebellSwing.png",
    "muscles": "Glutes, Hamstrings, Core, Shoulders",
    "equipment": "Kettlebell",
    "form": [
      "Stand with feet shoulder-width apart holding a kettlebell with both hands.",
      "Hinge at your hips and swing the kettlebell back between your legs.",
      "Drive your hips forward to swing it up to shoulder height.",
      "Control the swing and let it return between your legs for the next rep."
    ]
  },
  {
    "name": "Mountain Climbers",
    "image": "assets/images/MountainClimber.png",
    "muscles": "Core, Shoulders, Hip Flexors",
    "equipment": "Bodyweight or Mat",
    "form": [
      "Start in a high plank position with hands under shoulders.",
      "Drive one knee toward your chest, then quickly switch legs.",
      "Continue alternating at a quick pace, keeping your back straight."
    ]
  }
  ];

  //Gets the muscle groups from the exercise list
  List<String> get _muscleGroups {
  final muscles = _exercises
      .expand((e) => (e["muscles"] as String)
          .split(",")
          .map((m) => m.trim()))
      .toSet()
      .toList()
      .cast<String>(); 

  muscles.sort();
  return muscles;
}

  // Filters exercises based on search query and selected muscles
  List<Map<String, dynamic>> get _filteredExercises {
    final query = _searchQuery.toLowerCase();
    return _exercises.where((ex) {
      final matchesSearch = query.isEmpty ||
          ex["name"].toLowerCase().contains(query) ||
          ex["muscles"].toLowerCase().contains(query);

      if (_selectedMuscles.isEmpty) return matchesSearch;

      final muscleList =
          ex["muscles"].toLowerCase().split(",").map((m) => m.trim()).toList();
      final matchesMuscles = _selectedMuscles.any((m) => muscleList.contains(m.toLowerCase()));

      return matchesSearch && matchesMuscles;
    }).toList();
  }

  //--- UI BUILD METHOD ---
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

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: ivory,
        title: const Text(
          'Exercises',
          style: TextStyle(
            color: lightModeGreen,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: lightModeGreen),
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        //--- Todays Workout Section ---
        children: [
          if (todaysWorkout != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
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
                  tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  title: Text(
                    "Today's Workout · ${todaysWorkout!.workoutName}",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  children: todaysWorkout!.exercises.map((planned) {
                    final details = _findExerciseDetails(planned.name);
                    if (details == null || details.isEmpty) {
                      return const SizedBox();
                    }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildExerciseCard(
              name: planned.name,
              image: details["image"],
              muscles: details["muscles"],
              equipment: details["equipment"],
              form: List<String>.from(details["form"]),
              stats: _formatSets(planned.sets),
              ),
            );
        }).toList(),
      ),
    ),
  ),


          const SizedBox(height: 8),
          const Divider(),
          // --- Search Bar ---
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value),
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                hintText: "Search by exercise or muscle group...",
                hintStyle: TextStyle(color: subTextColor),
                prefixIcon: Icon(Icons.search, color: accentColor),
                filled: true,
                fillColor: cardColor,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: accentColor.withOpacity(0.6), width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: accentColor, width: 2),
                ),
              ),
            ),
          ),

          // --- Pinned Exercises ---
          if (_searchQuery.isEmpty && _pinnedExerciseCards.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Text(
                "Pinned Exercises",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ),

          if (_searchQuery.isEmpty)
            ..._pinnedExerciseCards.map((ex) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildExerciseCard(
                  name: ex["name"],
                  image: ex["image"],
                  muscles: ex["muscles"],
                  equipment: ex["equipment"],
                  form: List<String>.from(ex["form"]),
                  pinnable: true,
                ),
              );
            }).toList(),


          // --- Muscle Filter Chips ---
          Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: _muscleGroups.map((muscle) {
                final isSelected = _selectedMuscles.contains(muscle);
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(muscle,
                        style: TextStyle(
                            color: isSelected ? Colors.white : textColor,
                            fontWeight: FontWeight.w500)),
                    selected: isSelected,
                    backgroundColor: cardColor,
                    selectedColor: accentColor,
                    checkmarkColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: accentColor.withOpacity(0.6)),
                    ),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedMuscles.add(muscle);
                        } else {
                          _selectedMuscles.remove(muscle);
                        }
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),

          // --- Exercise List ---
          // --- Exercise List ---
          if (_filteredExercises.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Text(
                  "No exercises found.",
                  style: TextStyle(color: subTextColor, fontSize: 16),
                ),
              ),
            )
          else
            ..._filteredExercises.map((ex) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildExerciseCard(
                  name: ex["name"],
                  image: ex["image"],
                  muscles: ex["muscles"],
                  equipment: ex["equipment"],
                  form: List<String>.from(ex["form"]),
                  pinnable: true,
                ),
              );
            }).toList(),
                  ],
                ),
              );
            }

  Widget _buildInfoRow(
      String label, String value, Color textColor, Color subTextColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("$label ",
              style: TextStyle(
                  color: textColor, fontWeight: FontWeight.w600, fontSize: 15)),
          Expanded(
            child:
                Text(value, style: TextStyle(color: subTextColor, fontSize: 15)),
          ),
        ],
      ),
    );
  }
}

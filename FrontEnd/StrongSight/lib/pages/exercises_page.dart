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
  Set<String> _selectedMuscles = {};

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

  List<String> get _muscleGroups {
  final muscles = _exercises
      .expand((e) => (e["muscles"] as String)
          .split(",")
          .map((m) => m.trim()))
      .toSet()
      .toList()
      .cast<String>(); // ensures List<String>

  muscles.sort();
  return muscles;
}


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
      body: Column(
        children: [
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
          Expanded(
            child: _filteredExercises.isEmpty
                ? Center(
                    child: Text("No exercises found.",
                        style: TextStyle(color: subTextColor, fontSize: 16)),
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
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: isDark ? espresso : const Color(0xFFEDE6D1),
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.all(6),
                                child: Image.asset(ex["image"], fit: BoxFit.contain),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  ex["name"],
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: textColor),
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
                            Text("Proper Form:",
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: textColor)),
                            const SizedBox(height: 4),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: (ex["form"] as List<String>).map((step) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 2),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("• ",
                                          style: TextStyle(
                                              color: accentColor.withOpacity(0.8),
                                              fontSize: 15,
                                              height: 1.4)),
                                      Expanded(
                                        child: Text(step,
                                            style: TextStyle(
                                                color: subTextColor,
                                                fontSize: 15,
                                                height: 1.4)),
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

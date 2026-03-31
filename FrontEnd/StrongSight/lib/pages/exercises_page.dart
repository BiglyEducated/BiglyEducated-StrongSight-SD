import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../models/exercise_catalog.dart';
import 'package:fl_chart/fl_chart.dart';



///-----------MODELS -----------///
class WorkoutSet {
  int reps;
  double weight;

  WorkoutSet({required this.reps, required this.weight});
}

class WorkoutExercise {
  String name;
  String equipment;
  List<WorkoutSet> sets;

  WorkoutExercise({
    required this.name,
    required this.equipment,
    required this.sets,
  });
}

class Workout {
  final String workoutName;
  final List<WorkoutExercise> exercises;
  final DateTime date;

  Workout({
    required this.workoutName,
    required this.exercises,
    required this.date,
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
  final Map<String, String> _selectedEquipment = {};
  final Set<String> _expandedCards = {};
  String _searchQuery = "";
  Set<String> _selectedMuscles = {};

  // Builds a line chart for PRs or volume
  Widget _buildPRChart(Map<DateTime, double> data) {
    final isDark =
        Provider.of<ThemeProvider>(context, listen: false).isDarkMode;

    final entries = data.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    final spots = List.generate(entries.length, (i) {
      return FlSpot(i.toDouble(), entries[i].value);
    });

    final lineColor = isDark
        ? const Color(0xFF039E39)
        : const Color(0xFF094941);

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 20,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Colors.grey.withOpacity(0.15),
            strokeWidth: 1,
          ),
        ),

        borderData: FlBorderData(
          show: true,
          border: Border(
            bottom: BorderSide(color: lineColor.withOpacity(0.4)),
            left: BorderSide(color: lineColor.withOpacity(0.4)),
            right: BorderSide.none,
            top: BorderSide.none,
          ),
        ),

        titlesData: FlTitlesData(
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),

          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= entries.length) return const SizedBox();
                final date = entries[index].key;
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    "${date.month}/${date.day}",
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              },
            ),
          ),

          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
            ),
          ),
        ),

        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                return LineTooltipItem(
                  "${spot.y.toStringAsFixed(0)} lbs",
                  const TextStyle(color: Colors.white),
                );
              }).toList();
            },
          ),
        ),

        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            barWidth: 3,

            gradient: LinearGradient(
              colors: [
                lineColor,
                lineColor.withOpacity(0.5),
              ],
            ),

            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  lineColor.withOpacity(0.3),
                  Colors.transparent,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),

            dotData: FlDotData(show: true),
          ),
        ],
      ),
    );
  }

// Builds a bar chart for volume
Widget _buildVolumeChart(Map<DateTime, double> data) {
  final isDark =
      Provider.of<ThemeProvider>(context, listen: false).isDarkMode;

  final entries = data.entries.toList()
    ..sort((a, b) => a.key.compareTo(b.key));

  final barColor = isDark
      ? const Color(0xFF039E39)
      : const Color(0xFF094941);

  return BarChart(
    BarChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        getDrawingHorizontalLine: (value) => FlLine(
          color: Colors.grey.withOpacity(0.15),
          strokeWidth: 1,
        ),
      ),

      borderData: FlBorderData(
        show: true,
        border: Border(
          bottom: BorderSide(color: barColor.withOpacity(0.4)),
          left: BorderSide(color: barColor.withOpacity(0.4)),
          right: BorderSide.none,
          top: BorderSide.none,
        ),
      ),

      titlesData: FlTitlesData(
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),

        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              if (index >= entries.length) return const SizedBox();
              final date = entries[index].key;
              return Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  "${date.month}/${date.day}",
                  style: const TextStyle(fontSize: 10),
                ),
              );
            },
          ),
        ),

        leftTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: true, reservedSize: 32),
        ),
      ),

      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            return BarTooltipItem(
              "${rod.toY.toStringAsFixed(0)}",
              const TextStyle(color: Colors.white),
            );
          },
        ),
      ),

      barGroups: List.generate(entries.length, (i) {
        return BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: entries[i].value,
              width: 14,
              borderRadius: BorderRadius.circular(6),

              gradient: LinearGradient(
                colors: [
                  barColor,
                  barColor.withOpacity(0.6),
                ],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
          ],
        );
      }),
    ),
  );
}

// Builds the metrics section with PR and volume charts
  Widget _buildMetricsSection(String exerciseName) {
  //API GOES HERE REPLACE REPLACE YEUUUURRRR
    final allWorkouts = [
      Workout(
        workoutName: "Test",
        date: DateTime.now().subtract(const Duration(days: 10)),
        exercises: [
          WorkoutExercise(
            name: exerciseName,
            equipment: "Barbell",
            sets: [WorkoutSet(reps: 10, weight: 100)],
          ),
        ],
      ),
      Workout(
        workoutName: "Test",
        date: DateTime.now().subtract(const Duration(days: 5)),
        exercises: [
          WorkoutExercise(
            name: exerciseName,
            equipment: "Dumbbell",
            sets: [WorkoutSet(reps: 8, weight: 120)],
          ),
        ],
      ),
    ];
  final rawOptions = allWorkouts
    .expand((w) => w.exercises)
    .where((e) => e.name == exerciseName)
    .map((e) => e.equipment)
    .toSet()
    .toList();

final options = rawOptions.isNotEmpty
    ? rawOptions
    : ["Barbell", "Dumbbell", "Machine"];

final selected = _selectedEquipment[exerciseName] ?? options.first;

if (!options.contains(selected)) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    setState(() {
      _selectedEquipment[exerciseName] = options.first;
    });
  });
}

  final filtered = filterWorkoutsByExercise(allWorkouts, exerciseName, selected);

  final lastMonth = filterByRange(filtered, const Duration(days: 30));
  final last6Months = filterByRange(filtered, const Duration(days: 180));

  final prsMonth = getPRs(lastMonth, exerciseName, selected);
  final volumeMonth = getVolume(lastMonth, exerciseName, selected);

  // If no data, show placeholder
  if (prsMonth.isEmpty && volumeMonth.isEmpty) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Text(
          "Lift for results",
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
  return Column(
    children: [
      DropdownButton<String>(
        value: selected,
        items: options.map((e) {
          return DropdownMenuItem(
            value: e,
            child: Text(e),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedEquipment[exerciseName] = value!;
          });
        },
      ),

      const SizedBox(height: 8),
      //Shows PR and Volume charts for the last month and last 6 months
      const Text("PR (Last Month)"),
      const SizedBox(height: 8),

      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF12110F)
              : Colors.grey[100],
        ),
        child: SizedBox(
          height: 160,
          child: _buildPRChart(prsMonth),
        ),
      ),

      const SizedBox(height: 12),

      const Text("PR (6 Months)"),
      const SizedBox(height: 8),

      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF12110F)
              : Colors.grey[100],
        ),
        child: SizedBox(
          height: 160,
          child: _buildPRChart(
            getPRs(last6Months, exerciseName, selected),
          ),
        ),
      ),
      
      const SizedBox(height: 12),
      const Text("Volume (Last Month)"),
      const SizedBox(height: 8),

      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF12110F)
              : Colors.grey[100],
        ),
        child: SizedBox(
          height: 160,
          child: _buildVolumeChart(volumeMonth),
        ),
      ),

      const SizedBox(height: 12),

      const Text("Volume (6 Months)"),
      const SizedBox(height: 8),

      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF12110F)
              : Colors.grey[100],
        ),
        child: SizedBox(
          height: 160,
          child: _buildVolumeChart(
            getVolume(last6Months, exerciseName, selected),
          ),
        ),
      ),
    ],
  );
  }

  //Exercise Card Builder
Widget _buildExerciseCard({
  required String name,
  required String image,
  required String muscles,
  required String equipment,
  required List<String> form,
  String? stats,
  bool pinnable = false,
}){
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
        const SizedBox(height: 12),
        const Divider(height: 20),
        ExpansionTile(
  title: Text(
    "Metrics",
    style: TextStyle(
      fontWeight: FontWeight.w600,
      color: textColor,
    ),
  ),
  onExpansionChanged: (expanded) {
    setState(() {
      if (expanded) {
        _expandedCards.add(name);
      } else {
        _expandedCards.remove(name);
      }
    });
  },
  children: [
    if (_expandedCards.contains(name))
      Padding(
        padding: const EdgeInsets.only(top: 8),
        child: _buildMetricsSection(name),
      )
    else
      const SizedBox.shrink(),
  ],
),
      ],
    ),
  );
}

  // Finds exercise details by name
  ExerciseDefinition? _findExerciseDetails(String name) {
  try {
    return _exercises.firstWhere((ex) => ex.name == name);
  } catch (e) {
    return null;
  }
}

// Filters workouts to find those containing a specific exercise
List<Workout> filterWorkoutsByExercise(
  List<Workout> workouts,
  String exerciseName,
  String equipment,
) {
  return workouts.where((w) =>
      w.exercises.any((e) => e.name == exerciseName && e.equipment == equipment)).toList();
}

// Extracts PRs for a specific exercise across workouts
Map<DateTime, double> getPRs(
  List<Workout> workouts,
  String exerciseName,
  String equipment,
) {
  final Map<DateTime, double> prs = {};

  for (var workout in workouts) {
    final exercise = workout.exercises.firstWhere(
      (e) => e.name == exerciseName && e.equipment == equipment,
      orElse: () => WorkoutExercise(name: '', equipment: '', sets: []),
    );

    if (exercise.name.isEmpty) continue;

    double maxWeight = 0;

    for (var set in exercise.sets) {
      if (set.weight > maxWeight) {
        maxWeight = set.weight.toDouble();
      }
    }

    prs[workout.date] = maxWeight;
  }

  return prs;
}



// Calculates total volume (weight x reps) for a specific exercise across workouts
Map<DateTime, double> getVolume(
  List<Workout> workouts,
  String exerciseName,
  String equipment,
) {
  final Map<DateTime, double> volume = {};

  for (var workout in workouts) {
    final exercise = workout.exercises.firstWhere(
      (e) => e.name == exerciseName && e.equipment == equipment,
      orElse: () => WorkoutExercise(name: '', equipment: '', sets: []),
    );

    if (exercise.name.isEmpty) continue;

    double total = 0;

    for (var set in exercise.sets) {
      total += set.weight * set.reps;
    }

    volume[workout.date] = total;
  }

  return volume;
}


// Filters workouts to a specific date range (e.g., last week, last month)
List<Workout> filterByRange(List<Workout> workouts, Duration range) {
  final cutoff = DateTime.now().subtract(range);
  return workouts.where((w) => w.date.isAfter(cutoff)).toList();
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
List<ExerciseDefinition> get _pinnedExerciseCards {
  return _exercises
      .where((ex) => _pinnedExercises.contains(ex.name))
      .toList();
}

// Format sets for display
String _formatSets(List<WorkoutSet> sets) {
    return sets.map((s) => "${s.reps} @ ${s.weight} lbs").join(" | ");
  }


  //Todays workout(REPLACE WITH API DATA)
  final Workout? todaysWorkout = Workout(                                                                         ///REPLACE WITH API DATA
    date: DateTime.now(),
    workoutName: "Leetcode Session",
    exercises: [
      WorkoutExercise(
        name: "Squat",
        equipment: "Barbell",
        sets: [
        WorkoutSet(reps: 8, weight: 135),
        WorkoutSet(reps: 8, weight: 135),
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

  //Exercise Library

  List<ExerciseDefinition> get _exercises => exerciseCatalog;
   

  //Gets the muscle groups from the exercise list
  List<String> get _muscleGroups {
  final muscles = _exercises
      .expand((e) => e.muscles.map((m) => m.name))
      .toSet()
      .toList();

  muscles.sort();
  return muscles;
}
  

  // Filters exercises based on search query and selected muscles
  List<ExerciseDefinition> get _filteredExercises {
  final query = _searchQuery.toLowerCase();

  return _exercises.where((ex) {
    final matchesSearch =
        query.isEmpty ||
        ex.name.toLowerCase().contains(query) ||
        ex.muscles.map((m) => m.name).join(", ").toLowerCase().contains(query);

    if (_selectedMuscles.isEmpty) return matchesSearch;

    final matchesMuscles = ex.muscles
        .map((m) => m.name.toLowerCase())
        .any((m) => _selectedMuscles.contains(m));

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
                    if (details == null) {
                      return const SizedBox();
                    }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildExerciseCard(
              name: planned.name,
              image: details.image,
              muscles: details.muscles.map((m) => m.name).join(", "),
              equipment: details.equipment.map((e) => e.name).join(", "),
              form: List<String>.from(details.formCues),
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
                  name: ex.name,
                  image: ex.image,
                  muscles: ex.muscles.map((m) => m.name).join(", "),
                  equipment: ex.equipment.map((e) => e.name).join(", "),
                  form: List<String>.from(ex.formCues),
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
                  name: ex.name,
                  image: ex.image,
                  muscles: ex.muscles.map((m) => m.name).join(", "),
                  equipment: ex.equipment.map((e) => e.name).join(", "),
                  form: List<String>.from(ex.formCues),
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
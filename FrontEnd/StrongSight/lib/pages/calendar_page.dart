import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

/// ======================================================
/// ===================== DATA MODELS =====================
/// ======================================================

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
  String title;
  List<WorkoutExercise> exercises;

  Workout({
    required this.title,
    required this.exercises,
  });
}

/// ======================================================
/// ===================== CALENDAR PAGE ===================
/// ======================================================

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  /// In-memory storage (replace with API/Firebase later)
  final Map<DateTime, Workout> _workoutsByDay = {};

  /// Fake exercise library (later sync with Exercises page)
  final List<String> _exerciseLibraryNames = [
    "Squat",
    "Bench Press",
    "Deadlift",
    "Bicep Curls",
    "Pull-ups",
    "Push-ups",
    "Shoulder Press",
    "Lunges",
    "Tricep Dips",
  ];

  /// Normalize date for Map keys
  DateTime _normalize(DateTime d) => DateTime.utc(d.year, d.month, d.day);

  Workout? _getWorkout(DateTime day) {
    return _workoutsByDay[_normalize(day)];
  }

  List<String> _getEventsForDay(DateTime day) {
    final workout = _getWorkout(day);
    return workout == null ? [] : [workout.title];
  }


  Widget _buildCalendarCell(DateTime day, Color textColor) {
      final hasWorkout = _getWorkout(day) != null;

      return SizedBox.expand(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "${day.day}",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            const SizedBox(height: 4),
            Image.asset(
              hasWorkout
                  ? "assets/images/OpenEyeLogo.png"
                  : "assets/images/ClosedEyeLogo.png",
              width: 22,
              height: 22,
            ),
          ],
        ),
      );
    }

  /// ======================================================
  /// ===================== MAIN BUILD =====================
  /// ======================================================

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    const ivory = Color(0xFFF3EBD3);
    const espresso = Color(0xFF12110F);
    const lightGreen = Color(0xFF094941);
    const darkGreen = Color(0xFF039E39);
    const darkCard = Color(0xFF1A1917);

    final bgColor = isDark ? espresso : const Color(0xFFFCF5E3);
    final cardColor = isDark ? darkCard : Colors.white;
    final textColor = isDark ? darkGreen : lightGreen;
    final subTextColor = isDark ? const Color(0xFFD9CBB8) : Colors.grey[700]!;
    final accentColor = isDark ? darkGreen : lightGreen;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: ivory,
        centerTitle: true,
        title: const Text(
          'Workout Calendar',
          style: TextStyle(
            color: lightGreen,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),


    /// ======================================================
    /// ===================== CALENDAR CELL ==================
    /// ======================================================

      body: Column(
        children: [
          /// ===================== CALENDAR =====================
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              eventLoader: _getEventsForDay,

              /// 👁️ CUSTOM DAY CELLS (OPEN/CLOSED EYE)
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, _) =>
                    _buildCalendarCell(day, textColor),
                todayBuilder: (context, day, _) => Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accentColor.withOpacity(0.2),
                  ),
                  child: _buildCalendarCell(day, textColor),
                ),
                selectedBuilder: (context, day, _) => Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accentColor,
                  ),
                  child: _buildCalendarCell(day, Colors.white),
                ),
              ),

              headerStyle: HeaderStyle(
                titleCentered: true,
                formatButtonVisible: false,
                titleTextStyle: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                leftChevronIcon: Icon(Icons.chevron_left, color: textColor),
                rightChevronIcon: Icon(Icons.chevron_right, color: textColor),
              ),

              calendarStyle: const CalendarStyle(
                outsideDaysVisible: false,
                markersMaxCount: 0,
              ),

              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: TextStyle(color: subTextColor),
                weekendStyle: TextStyle(color: subTextColor),
              ),

              onDaySelected: (selected, focused) {
                setState(() {
                  _selectedDay = selected;
                  _focusedDay = focused;
                });
              },
            ),

          ),

          /// ===================== WORKOUT PANEL =====================
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: _buildWorkoutPanel(
                _selectedDay ?? _focusedDay,
                accentColor,
                subTextColor,
                textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ======================================================
  /// ===================== WORKOUT PANEL ==================
  /// ======================================================

  Widget _buildWorkoutPanel(
    DateTime day,
    Color accentColor,
    Color subTextColor,
    Color textColor,
  ) {
    final workout = _getWorkout(day);

    if (workout == null) {
      return Center(
        child: ElevatedButton.icon(
          icon: const Icon(Icons.add),
          label: const Text("Add Workout"),
          onPressed: () => _openWorkoutForm(day),
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Workout Title
          Text(
            workout.title,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: accentColor,
            ),
          ),
          const SizedBox(height: 16),

          /// Exercises + Sets
          ...workout.exercises.map((ex) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ex.name,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                ...ex.sets.map((s) => Text(
                      "${s.reps} reps @ ${s.weight} lbs",
                      style: TextStyle(color: subTextColor),
                    )),
                const SizedBox(height: 12),
              ],
            );
          }),

          const SizedBox(height: 20),

          /// Actions
          Row(
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.edit),
                label: const Text("Edit"),
                onPressed: () =>
                    _openWorkoutForm(day, workout: workout),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                icon: const Icon(Icons.delete),
                label: const Text("Delete"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                ),
                onPressed: () => _deleteWorkout(day),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// ======================================================
  /// ===================== WORKOUT FORM ===================
  /// ======================================================

  void _openWorkoutForm(DateTime day, {Workout? workout}) {
    final titleController =
        TextEditingController(text: workout?.title ?? '');

    List<WorkoutExercise> tempExercises =
        workout?.exercises
                .map((e) => WorkoutExercise(
                      name: e.name,
                      sets: e.sets
                          .map((s) =>
                              WorkoutSet(reps: s.reps, weight: s.weight))
                          .toList(),
                    ))
                .toList() ??
            [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                16,
                16,
                MediaQuery.of(ctx).viewInsets.bottom + 16,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Workout Name
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                          labelText: 'Workout Title'),
                    ),
                    const SizedBox(height: 16),

                    /// Exercises
                    const Text("Exercises",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),

                    ...tempExercises.map((exercise) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(exercise.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold)),
                          ...exercise.sets.map((set) {
                            return Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    keyboardType: TextInputType.number,
                                    decoration:
                                        const InputDecoration(labelText: "Reps"),
                                    onChanged: (v) =>
                                        set.reps = int.tryParse(v) ?? 0,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                        labelText: "Weight(lbs)"),
                                    onChanged: (v) =>
                                        set.weight = double.tryParse(v) ?? 0,
                                  ),
                                ),
                              ],
                            );
                          }),
                          TextButton.icon(
                            icon: const Icon(Icons.add),
                            label: const Text("Add Set"),
                            onPressed: () {
                              setModalState(() {
                                exercise.sets
                                    .add(WorkoutSet(reps: 10, weight: 0));
                              });
                            },
                          ),
                          const Divider(),
                        ],
                      );
                    }),

                    /// Add Exercise Button
                    TextButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text("Add Exercise"),
                      onPressed: () async {
                        final selected = await _selectExerciseDialog();
                        if (selected != null) {
                          setModalState(() {
                            tempExercises.add(
                              WorkoutExercise(name: selected, sets: [
                                WorkoutSet(reps: 10, weight: 0),
                              ]),
                            );
                          });
                        }
                      },
                    ),

                    const SizedBox(height: 20),

                    /// Save Workout
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _workoutsByDay[_normalize(day)] = Workout(
                            title: titleController.text,
                            exercises: tempExercises,
                          );
                        });
                        Navigator.pop(ctx);
                      },
                      child: Text(
                          workout == null ? 'Create Workout' : 'Save Changes'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// ======================================================
  /// ===================== EXERCISE PICKER =================
  /// ======================================================

  Future<String?> _selectExerciseDialog() {
    return showDialog<String>(
      context: context,
      builder: (_) => SimpleDialog(
        title: const Text("Select Exercise"),
        children: _exerciseLibraryNames
            .map((name) => SimpleDialogOption(
                  child: Text(name),
                  onPressed: () => Navigator.pop(context, name),
                ))
            .toList(),
      ),
    );
  }

  /// ======================================================
  /// ===================== DELETE WORKOUT =================
  /// ======================================================

  void _deleteWorkout(DateTime day) {
    setState(() {
      _workoutsByDay.remove(_normalize(day));
    });
  }
}

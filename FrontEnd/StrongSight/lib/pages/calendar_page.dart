import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../models/workout_models.dart';
import '../models/exercise_catalog.dart';
import '../models/equipment_mapper.dart';
import 'package:uuid/uuid.dart';

final _uuid = const Uuid();

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  final Map<DateTime, Workout> _workoutsByDay = {};

  DateTime _normalize(DateTime d) => DateTime(d.year, d.month, d.day);

  Workout? _getWorkout(DateTime day) =>
      _workoutsByDay[_normalize(day)];

  List<String> _getEventsForDay(DateTime day) {
    final workout = _getWorkout(day);
    return workout == null ? [] : [workout.workoutName];
  }

  Widget _buildCalendarCell(
  DateTime day,
  Color textColor, {
  bool isSelected = false,
  Color? selectedColor,
}) {
  final hasWorkout = _getWorkout(day) != null;

  return SizedBox.expand(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            if (isSelected)
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selectedColor,
                ),
              ),
            Text(
              "${day.day}",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : textColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Image.asset(
          hasWorkout
              ? "assets/images/OpenEyeLogo.png"
              : "assets/images/ClosedEyeLogo.png",
          width: 20,
          height: 20,
        ),
      ],
    ),
  );
}


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
    final subTextColor =
        isDark ? const Color(0xFFD9CBB8) : Colors.grey[700]!;
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
      body: Column(
        children: [
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
              selectedDayPredicate: (day) =>
                  isSameDay(_selectedDay, day),
              eventLoader: _getEventsForDay,
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, _) =>
                    _buildCalendarCell(day, textColor),

                todayBuilder: (context, day, _) =>
                    _buildCalendarCell(
                      day,
                      textColor,
                      isSelected: true,
                      selectedColor: accentColor.withOpacity(0.25),
                    ),

                selectedBuilder: (context, day, _) =>
                    _buildCalendarCell(
                      day,
                      textColor,
                      isSelected: true,
                      selectedColor: accentColor,
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
                leftChevronIcon:
                    Icon(Icons.chevron_left, color: textColor),
                rightChevronIcon:
                    Icon(Icons.chevron_right, color: textColor),
              ),
              calendarStyle: const CalendarStyle(
                outsideDaysVisible: false,
                markersMaxCount: 0,
              ),
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle:
                    TextStyle(color: subTextColor),
                weekendStyle:
                    TextStyle(color: subTextColor),
              ),
              onDaySelected: (selected, focused) {
                setState(() {
                  _selectedDay = selected;
                  _focusedDay = focused;
                });
              },
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
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

  Widget _buildWorkoutPanel(
    DateTime day,
    Color accentColor,
    Color subTextColor,
    Color textColor,
  ) {
    final workout = _getWorkout(day);

    if (workout == null) {
      return Center(
        child: ElevatedButton(
          onPressed: () => _openWorkoutForm(day),
          child: const Text('Add Workout'),
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            workout.workoutName,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 12),
          ...workout.exercises.map((e) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Exercise name
                Text(
                  e.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),

                /// Equipment
                Text(
                  "Equipment: ${e.equipment.name}",
                  style: TextStyle(
                    fontSize: 12,
                    color: subTextColor,
                  ),
                ),

                const SizedBox(height: 4),

                /// Sets
                ...e.sets.asMap().entries.map((entry) {
                  final i = entry.key + 1;
                  final set = entry.value;

                  return Text(
                    "Set $i: ${set.reps} reps @ ${set.weight}",
                    style: TextStyle(
                      fontSize: 13,
                      color: subTextColor,
                    ),
                  );
                }),
              ],
            ),
          );
        }),

          const SizedBox(height: 16),
          Row(
            children: [
              ElevatedButton(
                onPressed: () =>
                    _openWorkoutForm(day, workout: workout),
                child: const Text("Edit"),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () => _deleteWorkout(day),
                child: const Text("Delete"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _openWorkoutForm(DateTime day, {Workout? workout}) {
    final titleController =
        TextEditingController(text: workout?.workoutName ?? '');

    List<WorkoutExercise> tempExercises =
        workout?.exercises.map((e) => e.copyWith()).toList() ?? [];

    final exerciseMap = {
      for (final e in exerciseCatalog) e.name: e,
    };

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
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
                TextField(
                  controller: titleController,
                  decoration:
                      const InputDecoration(labelText: 'Workout Title'),
                ),
                const SizedBox(height: 16),
                ...tempExercises.map((exercise) {
                  final def = exerciseMap[exercise.name];
                  final equipmentTypes =
                      def?.equipment ?? const <EquipmentType>[];

                  if (equipmentTypes.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exercise.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<EquipmentType>(
                        value: equipmentTypes.firstWhere(
                          (e) =>
                              mapEquipmentTypeToEquipment(e).id ==
                              exercise.equipment.id,
                          orElse: () => equipmentTypes.first,
                        ),
                        items: equipmentTypes
                            .map(
                              (e) => DropdownMenuItem(
                                value: e,
                                child: Text(equipmentLabel(e)),
                              ),
                            )
                            .toList(),
                        onChanged: (newType) {
                          if (newType == null) return;
                          final i =
                              tempExercises.indexOf(exercise);
                          setModalState(() {
                            tempExercises[i] = exercise.copyWith(
                              equipment:
                                  mapEquipmentTypeToEquipment(newType),
                            );
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      ...exercise.sets.map((set) {
                        final setIndex =
                            exercise.sets.indexOf(set);
                        return Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                initialValue:
                                    set.reps.toString(),
                                keyboardType:
                                    TextInputType.number,
                                decoration:
                                    const InputDecoration(labelText: 'Reps'),
                                onChanged: (v) {
                                  final updated =
                                      [...exercise.sets];
                                  updated[setIndex] = set.copyWith(
                                    reps:
                                        int.tryParse(v) ?? set.reps,
                                  );
                                  final i =
                                      tempExercises.indexOf(exercise);
                                  setModalState(() {
                                    tempExercises[i] =
                                        exercise.copyWith(sets: updated);
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextFormField(
                                initialValue:
                                    set.weight.toString(),
                                keyboardType:
                                    TextInputType.number,
                                decoration:
                                    const InputDecoration(labelText: 'Weight'),
                                onChanged: (v) {
                                  final updated =
                                      [...exercise.sets];
                                  updated[setIndex] = set.copyWith(
                                    weight:
                                        int.tryParse(v) ?? set.weight,
                                  );
                                  final i =
                                      tempExercises.indexOf(exercise);
                                  setModalState(() {
                                    tempExercises[i] =
                                        exercise.copyWith(sets: updated);
                                  });
                                },
                              ),
                            ),
                          ],
                        );
                      }),
                      TextButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text('Add Set'),
                        onPressed: () {
                          final i =
                              tempExercises.indexOf(exercise);
                          setModalState(() {
                            tempExercises[i] = exercise.copyWith(
                              sets: [
                                ...exercise.sets,
                                WorkoutSet(reps: 10, weight: 0),
                              ],
                            );
                          });
                        },
                      ),
                      const Divider(),
                    ],
                  );
                }),
                TextButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Add Exercise'),
                  onPressed: () async {
                    final selected =
                        await _selectExerciseDialog();
                    if (selected == null) return;
                    setModalState(() {
                      tempExercises.add(
                        WorkoutExercise(
                          id: _uuid.v4(),
                          name: selected.name,
                          equipment:
                              mapEquipmentTypeToEquipment(
                                  selected.equipment.first),
                          sets: [WorkoutSet(reps: 10, weight: 0)],
                        ),
                      );
                    });
                  },
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _workoutsByDay[_normalize(day)] = Workout(
                        id: workout?.id ?? _uuid.v4(),
                        workoutName: titleController.text,
                        date: _normalize(day),
                        exercises: tempExercises,
                      );
                    });
                    Navigator.pop(ctx);
                  },
                  child:
                      Text(workout == null ? 'Create' : 'Save'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<ExerciseDefinition?> _selectExerciseDialog() {
    return showDialog<ExerciseDefinition>(
      context: context,
      builder: (_) => SimpleDialog(
        title: const Text("Select Exercise"),
        children: exerciseCatalog
            .map(
              (ex) => SimpleDialogOption(
                child: Text(ex.name),
                onPressed: () =>
                    Navigator.pop(context, ex),
              ),
            )
            .toList(),
      ),
    );
  }

  void _deleteWorkout(DateTime day) {
    setState(() {
      _workoutsByDay.remove(_normalize(day));
    });
  }
}

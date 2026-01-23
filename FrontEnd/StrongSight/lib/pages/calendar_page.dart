import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

/// ------------------ WORKOUT MODEL ------------------
class Workout {
  String title;
  String notes;

  Workout({
    required this.title,
    required this.notes,
  });
}

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

  /// Normalize date (important for map keys)
  DateTime _normalize(DateTime d) => DateTime.utc(d.year, d.month, d.day);

  Workout? _getWorkout(DateTime day) {
    return _workoutsByDay[_normalize(day)];
  }

  List<String> _getEventsForDay(DateTime day) {
    final workout = _getWorkout(day);
    return workout == null ? [] : [workout.title];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    // -------- COLORS --------
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
        iconTheme: const IconThemeData(color: lightGreen),
      ),

      body: Column(
        children: [
          /// ------------------ CALENDAR ------------------
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                if (!isDark)
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
              ],
            ),
            child: TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              eventLoader: _getEventsForDay,

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
                leftChevronIcon:
                    Icon(Icons.chevron_left, color: textColor),
                rightChevronIcon:
                    Icon(Icons.chevron_right, color: textColor),
              ),

              calendarStyle: const CalendarStyle(
                outsideDaysVisible: false,
                markersMaxCount: 0, // removes black dots
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

          /// ------------------ WORKOUT PANEL ------------------
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

  /// ------------------ CALENDAR CELL ------------------
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


  /// ------------------ WORKOUT PANEL ------------------
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
          Text(
            workout.title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: accentColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            workout.notes,
            style: TextStyle(color: subTextColor, fontSize: 16),
          ),
          const SizedBox(height: 20),
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

  /// ------------------ CREATE / EDIT FORM ------------------
  void _openWorkoutForm(DateTime day, {Workout? workout}) {
    final titleController =
        TextEditingController(text: workout?.title ?? '');
    final notesController =
        TextEditingController(text: workout?.notes ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration:
                    const InputDecoration(labelText: 'Workout Title'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: notesController,
                decoration:
                    const InputDecoration(labelText: 'Notes / Focus'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _workoutsByDay[_normalize(day)] = Workout(
                      title: titleController.text,
                      notes: notesController.text,
                    );
                  });
                  Navigator.pop(context);
                },
                child: Text(
                    workout == null ? 'Create Workout' : 'Save Changes'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _deleteWorkout(DateTime day) {
    setState(() {
      _workoutsByDay.remove(_normalize(day));
    });
  }
}

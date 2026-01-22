import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
//----------- Hard Coded Days(Remove once APIs in place)----------------------
  final Map<DateTime, List<String>> _workoutEvents = {
    DateTime.utc(2025, 10, 8): ['Leg Day', 'Evening Stretch'],
    DateTime.utc(2025, 10, 9): ['Push Day'],
    DateTime.utc(2025, 10, 10): ['Cardio & Core'],
  };

  List<String> _getEventsForDay(DateTime day) {
    return _workoutEvents[DateTime.utc(day.year, day.month, day.day)] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    // StrongSight Colors
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
          'Workout Calendar',
          style: TextStyle(
            color: lightModeGreen,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: lightModeGreen),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ------------------ CALENDAR ------------------
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

                  // ---------- LOGO DAY BUILDER ----------
                  calendarBuilders: CalendarBuilders(
                    defaultBuilder: (context, day, focusedDay) {
                      final events = _getEventsForDay(day);
                      final hasWorkout = events.isNotEmpty;

                      return _buildCalendarDay(
                        dayNumber: day.day,
                        isWorkout: hasWorkout,
                        textColor: textColor,
                      );
                    },

                    todayBuilder: (context, day, focusedDay) {
                      final events = _getEventsForDay(day);
                      final hasWorkout = events.isNotEmpty;

                      return Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: accentColor.withOpacity(0.20),
                        ),
                        child: _buildCalendarDay(
                          dayNumber: day.day,
                          isWorkout: hasWorkout,
                          textColor: textColor,
                        ),
                      );
                    },

                    selectedBuilder: (context, day, focusedDay) {
                      final events = _getEventsForDay(day);
                      final hasWorkout = events.isNotEmpty;

                      return Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: accentColor,
                        ),
                        child: _buildCalendarDay(
                          dayNumber: day.day,
                          isWorkout: hasWorkout,
                          textColor: Colors.white,
                        ),
                      );
                    },
                  ),

                  headerStyle: HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    titleTextStyle: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                    leftChevronIcon: Icon(Icons.chevron_left, color: textColor),
                    rightChevronIcon: Icon(Icons.chevron_right, color: textColor),
                  ),

                  daysOfWeekStyle: DaysOfWeekStyle(
                    weekdayStyle: TextStyle(color: subTextColor),
                    weekendStyle: TextStyle(color: subTextColor),
                  ),

                  calendarStyle: CalendarStyle(
                    outsideDaysVisible: false,
                    defaultTextStyle: TextStyle(color: textColor),
                    weekendTextStyle: TextStyle(color: textColor),
                    todayTextStyle: TextStyle(color: textColor),
                    //Removes the black dot on worked out days(logos for that already implemented)
                    markersAutoAligned: false,
                    markersMaxCount: 0,
                  ),

                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                ),
              ),

              // ------------------ EVENT LIST ------------------
              Container(
                padding: const EdgeInsets.all(16),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                  boxShadow: [
                    if (!isDark)
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, -2),
                      ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Your Workouts",
                      style: TextStyle(
                        color: textColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),
                    _getEventsForDay(_selectedDay ?? _focusedDay).isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                "No workouts logged for this day.",
                                style: TextStyle(
                                  color: subTextColor,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          )
                        : Column(
                            children: _getEventsForDay(
                              _selectedDay ?? _focusedDay,
                            ).map(
                              (event) {
                                return Container(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 6),
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? espresso
                                        : const Color(0xFFFCF5E3),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: accentColor,
                                      width: 1.2,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        event,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: textColor,
                                        ),
                                      ),
                                      Icon(
                                        Icons.check_circle_outline,
                                        color: accentColor,
                                      )
                                    ],
                                  ),
                                );
                              },
                            ).toList(),
                          ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ------------------ CUSTOM DAY CELL ------------------
  Widget _buildCalendarDay({
    required int dayNumber,
    required bool isWorkout,
    required Color textColor,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "$dayNumber",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),

          const SizedBox(height: 4),

          Image.asset(
            isWorkout
                ? "assets/images/OpenEyeLogo.png"
                : "assets/images/ClosedEyeLogo.png",
            width: 22,
            height: 22,
          ),
        ],
      ),
    );
  }
}

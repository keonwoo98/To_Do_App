import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'task.dart';

class CalendarView extends StatelessWidget {
  final List<Task> tasks;
  final Function(DateTime) getTasksForDay;
  final Function(Task) showEditTaskDialog;
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final CalendarFormat calendarFormat;
  final Function(DateTime, DateTime) onDaySelected;
  final Function(CalendarFormat) onFormatChanged;
  final Function(DateTime) onPageChanged;

  const CalendarView({
    super.key,
    required this.tasks,
    required this.getTasksForDay,
    required this.showEditTaskDialog,
    required this.focusedDay,
    required this.selectedDay,
    required this.calendarFormat,
    required this.onDaySelected,
    required this.onFormatChanged,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TableCalendar(
      firstDay: DateTime.utc(2000, 1, 1),
      lastDay: DateTime.utc(2100, 12, 31),
      focusedDay: focusedDay,
      selectedDayPredicate: (day) {
        return isSameDay(selectedDay, day);
      },
      onDaySelected: onDaySelected,
      calendarFormat: calendarFormat,
      onFormatChanged: onFormatChanged,
      onPageChanged: onPageChanged,
      eventLoader: (day) {
        return getTasksForDay(day).map((task) => task.name).toList();
      },
      calendarStyle: const CalendarStyle(
        todayDecoration: BoxDecoration(
          color: Colors.blueAccent,
          shape: BoxShape.circle,
        ),
        selectedDecoration: BoxDecoration(
          color: Colors.blue,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  void _showTasksForSelectedDay(BuildContext context, DateTime day) {
    final tasks = getTasksForDay(day);
    if (tasks.isNotEmpty) {
      showModalBottomSheet(
        context: context,
        builder: (context) {
          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return Card(
                margin:
                    const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                child: ListTile(
                  title: Text(
                    task.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: task.dueDate != null
                      ? Text(
                          'Due: ${task.dueDate!.toLocal().toString().split(' ')[0]}')
                      : null,
                  onTap: () {
                    Navigator.of(context).pop();
                    showEditTaskDialog(task);
                  },
                ),
              );
            },
          );
        },
      );
    }
  }
}

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'task_list.dart';
import 'calendar_view.dart';
import 'task.dart';
import 'readandwrite.dart';

void main() => runApp(const ToDoApp());

class ToDoApp extends StatelessWidget {
  const ToDoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To-Do List',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const ToDoListScreen(),
    );
  }
}

class ToDoListScreen extends StatefulWidget {
  const ToDoListScreen({super.key});

  @override
  _ToDoListScreenState createState() => _ToDoListScreenState();
}

class _ToDoListScreenState extends State<ToDoListScreen> {
  final List<Task> _tasks = [];
  final TextEditingController _textController = TextEditingController();
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  final Map<DateTime, List<Task>> _events = {};
  String _sortOption = 'Due Date';

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final tasks = await ReadAndWrite.readData();
    setState(() {
      _tasks.addAll(tasks);
      _updateEvents();
    });
  }

  void _updateEvents() {
    _events.clear();
    for (var task in _tasks) {
      if (task.dueDate != null) {
        final date = DateTime(
            task.dueDate!.year, task.dueDate!.month, task.dueDate!.day);
        if (_events[date] == null) {
          _events[date] = [];
        }
        _events[date]!.add(task);
      }
    }
  }

  List<Task> _getTasksForDay(DateTime day) {
    return _events[DateTime(day.year, day.month, day.day)] ?? [];
  }

  void _addTask(String task, DateTime? dueDate) {
    if (task.isNotEmpty) {
      setState(() {
        _tasks.add(Task(name: task, isDone: false, dueDate: dueDate));
        _updateEvents();
      });
      ReadAndWrite.writeData(_tasks);
    }
  }

  void _updateTask(Task task, String newName, DateTime? newDueDate) {
    setState(() {
      task.name = newName;
      task.dueDate = newDueDate;
      _updateEvents();
    });
    ReadAndWrite.writeData(_tasks);
  }

  void _toggleTask(Task task) {
    setState(() {
      task.isDone = !task.isDone;
    });
    ReadAndWrite.writeData(_tasks);
  }

  void _deleteTask(Task task) {
    setState(() {
      _tasks.remove(task);
      _updateEvents();
    });
    ReadAndWrite.writeData(_tasks);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Task deleted'),
        action: SnackBarAction(
          label: 'UNDO',
          onPressed: () {
            setState(() {
              _tasks.add(task);
              _updateEvents();
            });
            ReadAndWrite.writeData(_tasks);
          },
        ),
      ),
    );
  }

  void _sortTasks() {
    setState(() {
      if (_sortOption == 'Due Date') {
        _tasks.sort((a, b) {
          if (a.dueDate == null && b.dueDate == null) return 0;
          if (a.dueDate == null) return 1;
          if (b.dueDate == null) return -1;
          return a.dueDate!.compareTo(b.dueDate!);
        });
      } else if (_sortOption == 'Completion Status') {
        _tasks.sort((a, b) {
          if (a.isDone && !b.isDone) return 1;
          if (!a.isDone && b.isDone) return -1;
          return 0;
        });
      }
    });
  }

  void _showAddTaskDialog() {
    _textController.clear();
    DateTime? selectedDate;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add a new task'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextField(
                    controller: _textController,
                    decoration: const InputDecoration(labelText: 'Task name'),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: <Widget>[
                      Text(selectedDate == null
                          ? 'No date chosen!'
                          : 'Due Date: ${selectedDate!.toLocal().toString().split(' ')[0]}'),
                      const Spacer(),
                      TextButton(
                        child: const Text('Choose Date'),
                        onPressed: () {
                          showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2101),
                          ).then((pickedDate) {
                            if (pickedDate != null) {
                              setState(() {
                                selectedDate = pickedDate;
                              });
                            }
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  child: const Text('Add'),
                  onPressed: () {
                    if (_textController.text.isNotEmpty) {
                      _addTask(_textController.text, selectedDate);
                      Navigator.of(context).pop();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Task name cannot be empty'),
                        ),
                      );
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditTaskDialog(Task task) {
    _textController.text = task.name;
    DateTime? selectedDate = task.dueDate;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Edit task'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextField(
                    controller: _textController,
                    decoration: const InputDecoration(labelText: 'Task name'),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: <Widget>[
                      Text(selectedDate == null
                          ? 'No date chosen!'
                          : 'Due Date: ${selectedDate!.toLocal().toString().split(' ')[0]}'),
                      const Spacer(),
                      TextButton(
                        child: const Text('Choose Date'),
                        onPressed: () {
                          showDatePicker(
                            context: context,
                            initialDate: selectedDate ?? DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2101),
                          ).then((pickedDate) {
                            if (pickedDate != null) {
                              setState(() {
                                selectedDate = pickedDate;
                              });
                            }
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  child: const Text('Save'),
                  onPressed: () {
                    if (_textController.text.isNotEmpty) {
                      _updateTask(task, _textController.text, selectedDate);
                      Navigator.of(context).pop();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Task name cannot be empty'),
                        ),
                      );
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('To-Do List'),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(72.0),
            child: Column(
              children: [
                const TabBar(
                  tabs: [
                    Tab(text: 'Tasks'),
                    Tab(text: 'Calendar'),
                  ],
                ),
                Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: DropdownButton<String>(
                    value: _sortOption,
                    onChanged: (String? newValue) {
                      setState(() {
                        _sortOption = newValue!;
                        _sortTasks();
                      });
                    },
                    items: <String>['Due Date', 'Completion Status']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
        body: TabBarView(
          children: [
            TaskList(
              tasks: _tasks,
              toggleTask: _toggleTask,
              deleteTask: _deleteTask,
              showEditTaskDialog: _showEditTaskDialog,
              reorderTasks: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) {
                    newIndex -= 1;
                  }
                  final Task item = _tasks.removeAt(oldIndex);
                  _tasks.insert(newIndex, item);
                  _updateEvents();
                });
                ReadAndWrite.writeData(_tasks);
              },
            ),
            CalendarView(
              tasks: _tasks,
              getTasksForDay: _getTasksForDay,
              showEditTaskDialog: _showEditTaskDialog,
              focusedDay: _focusedDay,
              selectedDay: _selectedDay,
              calendarFormat: _calendarFormat,
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
                _showTasksForSelectedDay(selectedDay);
              },
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
              onPageChanged: (focusedDay) {
                setState(() {
                  _focusedDay = focusedDay;
                });
              },
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _showAddTaskDialog,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  void _showTasksForSelectedDay(DateTime day) {
    final tasks = _getTasksForDay(day);
    if (tasks.isNotEmpty) {
      showModalBottomSheet(
        context: context,
        builder: (context) {
          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return Card(
                margin: const EdgeInsets.symmetric(
                    vertical: 10.0, horizontal: 10.0),
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
                    _showEditTaskDialog(task);
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

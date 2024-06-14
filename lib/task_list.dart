import 'package:flutter/material.dart';
import 'task.dart';

class TaskList extends StatelessWidget {
  final List<Task> tasks;
  final Function(Task) toggleTask;
  final Function(Task) deleteTask;
  final Function(Task) showEditTaskDialog;
  final Function(int, int) reorderTasks;

  const TaskList({
    super.key,
    required this.tasks,
    required this.toggleTask,
    required this.deleteTask,
    required this.showEditTaskDialog,
    required this.reorderTasks,
  });

  @override
  Widget build(BuildContext context) {
    return ReorderableListView(
      onReorder: reorderTasks,
      children: [
        for (int index = 0; index < tasks.length; index++)
          Card(
            key: ValueKey(tasks[index].name),
            margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
            child: ListTile(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tasks[index].name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      decoration: tasks[index].isDone
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                  if (tasks[index].dueDate != null)
                    Text(
                      'Due: ${tasks[index].dueDate!.toLocal().toString().split(' ')[0]}',
                      style: TextStyle(
                        color: tasks[index].dueDate!.isBefore(DateTime.now())
                            ? Colors.red
                            : Colors.black,
                      ),
                    ),
                ],
              ),
              leading: Checkbox(
                value: tasks[index].isDone,
                onChanged: (bool? value) {
                  toggleTask(tasks[index]);
                },
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => deleteTask(tasks[index]),
              ),
              onTap: () => showEditTaskDialog(tasks[index]),
            ),
          ),
      ],
    );
  }
}

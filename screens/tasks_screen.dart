import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/task.dart';
import 'add_task.dart';
import 'subjects_screen.dart';
import 'archived_screen.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
    if (index == 1) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const SubjectsScreen()));
    } else if (index == 2) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const ArchivedScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meine Aufgaben')),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<Task>('tasks').listenable(),
        builder: (context, Box<Task> box, _) {
          final tasks = box.values.where((t) => !t.isArchived).toList();

          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              final taskKey = box.keyAt(box.values.toList().indexOf(task)) as int;

              return ListTile(
                leading: Container(
                  width: 24,
                  height: 24,
                  color: task.subject?.color ?? Colors.grey,
                ),
                title: Text(task.title),
                subtitle: Text(
                  '${task.subject?.name ?? 'Kein Fach'} • '
                      'Fällig am ${task.dueDate?.toLocal().toString().split(' ')[0] ?? 'unbekannt'}',
                ),
                trailing: Checkbox(
                  value: task.isCompleted,
                  onChanged: (value) => _toggleTask(box, taskKey),
                ),
                onTap: () => _editTask(context, box, taskKey),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AddTaskScreen()),
        ),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Aufgaben'),
          BottomNavigationBarItem(icon: Icon(Icons.subject), label: 'Fächer'),
          BottomNavigationBarItem(icon: Icon(Icons.archive), label: 'Archiv'),
        ],
        onTap: _onItemTapped,
      ),
    );
  }

  void _toggleTask(Box<Task> box, int key) {
    final task = box.get(key);
    if (task != null) {
      box.put(key, task..isCompleted = !task.isCompleted);
    }
  }

  void _editTask(BuildContext context, Box<Task> box, int key) {
    final task = box.get(key);
    if (task != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AddTaskScreen(task: task),
        ),
      ).then((updatedTask) {
        if (updatedTask != null) {
          box.put(key, updatedTask);
        }
      });
    }
  }
}
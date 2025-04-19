import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/task.dart';

class ArchivedScreen extends StatelessWidget {
  const ArchivedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Archiv')),
      body: StreamBuilder(
        stream: Hive.box<Task>('tasks').watch(),
        builder: (context, AsyncSnapshot<BoxEvent> snapshot) {
          final box = Hive.box<Task>('tasks');
          final tasks = box.values.where((t) => t.isArchived).toList();
          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return ListTile(
                title: Text(task.title),
                subtitle: Text(
                  '${task.subject?.name ?? 'Kein Fach'} • '
                      'Erledigt am ${task.dueDate?.toLocal().toString().split(' ')[0] ?? 'unbekanntes Datum'}',
                ),
              );
            },
          );
        },
      ),
    );
  }
}
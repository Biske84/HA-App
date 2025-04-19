import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive/hive.dart';
import '../models/task.dart';
import '../models/subject.dart';

class HiveService {
  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(TaskAdapter());
    Hive.registerAdapter(SubjectAdapter());
    await Hive.openBox<Task>('tasks');
    await Hive.openBox<Subject>('subjects');

    // Standardfach hinzufügen falls leer
    if (Hive.box<Subject>('subjects').isEmpty) {
      await Hive.box<Subject>('subjects').add(
          Subject('Mathe', const Color(0xFF2196F3).value),
      );
    }
  }

  static Future<void> archiveOldTasks() async {
    final tasks = Hive.box<Task>('tasks');
    final now = DateTime.now();

    for (final task in tasks.values) {
      if (task.isCompleted &&
          task.dueDate.isBefore(now.subtract(const Duration(days: 1)))) {
        task.isArchived = true;
        tasks.put(task.id, task);
      }
    }
  }
}
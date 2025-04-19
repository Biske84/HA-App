import 'package:hive/hive.dart';
import 'subject.dart';

part 'task.g.dart';

@HiveType(typeId: 1)
class Task {
  @HiveField(0)
  final String id;
  @HiveField(1)
  String title;
  @HiveField(2)
  String description;
  @HiveField(3)
  Subject subject;
  @HiveField(4)
  DateTime dueDate;
  @HiveField(5)
  bool isCompleted;
  @HiveField(6)
  bool isArchived;
  @HiveField(7)
  List<DateTime> reminders;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.subject,
    required this.dueDate,
    this.isCompleted = false,
    this.isArchived = false,
    this.reminders = const [],
  });

  // Kopiermethode für Updates
  Task copyWith({
    String? id,
    String? title,
    String? description,
    Subject? subject,
    DateTime? dueDate,
    bool? isCompleted,
    bool? isArchived,
    List<DateTime>? reminders,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      subject: subject ?? this.subject,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      isArchived: isArchived ?? this.isArchived,
      reminders: reminders ?? this.reminders,
    );
  }
}
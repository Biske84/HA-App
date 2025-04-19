import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/task.dart';
import '../models/subject.dart';
import '../services/notification_service.dart';

class AddTaskScreen extends StatefulWidget {
  final Task? task;
  final Function(Task)? onSave;

  const AddTaskScreen({this.task, this.onSave, super.key});

  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late String _description;
  late Subject? _selectedSubject;
  late DateTime _dueDate;
  final List<DateTime> _reminders = [];
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _title = widget.task!.title;
      _description = widget.task!.description;
      _selectedSubject = widget.task!.subject;
      _dueDate = widget.task!.dueDate;
    } else {
      _title = '';
      _description = '';
      _selectedSubject = null;
      _dueDate = DateTime.now().add(const Duration(days: 1));
    }
  }

  @override
  Widget build(BuildContext context) {
    final subjectsBox = Hive.box<Subject>('subjects');
    final hasSubjects = subjectsBox.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: Text(widget.task == null ? 'Neue Aufgabe' : 'Aufgabe bearbeiten')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Pflichtfeld: Titel
              TextFormField(
                initialValue: _title,
                decoration: const InputDecoration(
                  labelText: 'Titel*',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? 'Titel ist erforderlich' : null,
                onSaved: (value) => _title = value!,
              ),
              const SizedBox(height: 16),

              // Optional: Beschreibung
              TextFormField(
                initialValue: _description,
                decoration: const InputDecoration(
                  labelText: 'Beschreibung',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                onSaved: (value) => _description = value ?? '',
              ),
              const SizedBox(height: 16),

              // Pflichtfeld: Fach
              DropdownButtonFormField<Subject>(
                value: _selectedSubject,
                decoration: const InputDecoration(
                  labelText: 'Fach*',
                  border: OutlineInputBorder(),
                ),
                items: hasSubjects
                    ? subjectsBox.values.map((subject) {
                  return DropdownMenuItem(
                    value: subject,
                    child: Row(
                      children: [
                        Container(width: 12, height: 12, color: subject.color),
                        const SizedBox(width: 8),
                        Text(subject.name),
                      ],
                    ),
                  );
                }).toList()
                    : [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('Keine Fächer vorhanden'),
                  )
                ],
                validator: (value) => value == null ? 'Fach auswählen' : null,
                onChanged: (value) => setState(() => _selectedSubject = value),
              ),
              const SizedBox(height: 16),

              // Pflichtfeld: Fälligkeitsdatum
              ListTile(
                title: const Text('Fällig am*'),
                subtitle: Text(DateFormat('dd.MM.yyyy').format(_dueDate)),
                trailing: const Icon(Icons.calendar_today),
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(4),
                ),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _dueDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (date != null) setState(() => _dueDate = date);
                },
              ),
              const SizedBox(height: 16),

              // Optional: Erinnerungen
              const Text('Erinnerungen:', style: TextStyle(fontWeight: FontWeight.bold)),
              ..._buildReminderList(),
              TextButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Erinnerung hinzufügen'),
                onPressed: _addReminder,
              ),
              const SizedBox(height: 24),

              // Speichern Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: _saveTask,
                child: const Text('SPEICHERN'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildReminderList() {
    return _reminders.map((reminder) {
      return ListTile(
        title: Text(DateFormat('dd.MM.yyyy HH:mm').format(reminder)),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => setState(() => _reminders.remove(reminder)),
        ),
      );
    }).toList();
  }

  void _addReminder() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time != null) {
      setState(() {
        _reminders.add(DateTime(
          _dueDate.year,
          _dueDate.month,
          _dueDate.day,
          time.hour,
          time.minute,
        ));
      });
    }
  }

  Future<void> _saveTask() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final task = widget.task?.copyWith(
        title: _title,
        description: _description,
        subject: _selectedSubject!,
        dueDate: _dueDate,
        reminders: _reminders,
      ) ?? Task(
        id: const Uuid().v4(),
        title: _title,
        description: _description,
        subject: _selectedSubject!,
        dueDate: _dueDate,
        isCompleted: false,
        isArchived: false,
        reminders: _reminders,
      );

      await _scheduleNotifications(task);

      if (widget.onSave != null) {
        widget.onSave!(task);
      } else {
        await Hive.box<Task>('tasks').put(task.id, task);
      }

      if (mounted) Navigator.pop(context);
    }
  }

  Future<void> _scheduleNotifications(Task task) async {
    await _notificationService.cancelAllNotificationsForTask(task.id);

    for (final reminder in task.reminders) {
      await _notificationService.scheduleNotification(
        id: '${task.id}_${reminder.millisecondsSinceEpoch}'.hashCode,
        title: 'Erinnerung: ${task.title}',
        body: task.description.isNotEmpty
            ? task.description
            : 'Fällig am ${DateFormat('dd.MM.yyyy').format(task.dueDate)}',
        scheduledDate: reminder,
      );
    }
  }
}
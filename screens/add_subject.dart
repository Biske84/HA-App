import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/subject.dart';

class AddSubjectScreen extends StatefulWidget {
  const AddSubjectScreen({super.key});

  @override
  _AddSubjectScreenState createState() => _AddSubjectScreenState();
}

class _AddSubjectScreenState extends State<AddSubjectScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  Color _selectedColor = Colors.blue;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Neues Fach')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Fachname'),
                validator: (value) => value!.isEmpty ? 'Name eingeben' : null,
              ),
              const SizedBox(height: 20),
              Text('Farbe auswählen:', style: Theme.of(context).textTheme.titleMedium),
              Wrap(
                spacing: 8,
                children: [
                  _buildColorCircle(Colors.red),
                  _buildColorCircle(Colors.blue),
                  _buildColorCircle(Colors.green),
                  _buildColorCircle(Colors.orange),
                ],
              ),
              ElevatedButton(
                onPressed: _saveSubject,
                child: const Text('Speichern'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildColorCircle(Color color) {
    return GestureDetector(
      onTap: () => setState(() => _selectedColor = color),
      child: CircleAvatar(
        backgroundColor: color,
        radius: 20,
        child: _selectedColor == color ? const Icon(Icons.check, color: Colors.white) : null,
      ),
    );
  }

  void _saveSubject() {
    if (_formKey.currentState!.validate()) {
      final subject = Subject(
        _nameController.text,
        _selectedColor.value,
      );
      Hive.box<Subject>('subjects').add(subject);
      Navigator.pop(context);
    }
  }
}
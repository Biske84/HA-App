import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/subject.dart';
import 'add_subject.dart';

class SubjectsScreen extends StatelessWidget {
  const SubjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fächer')),
      body: StreamBuilder(
        stream: Hive.box<Subject>('subjects').watch(),
        builder: (context, AsyncSnapshot<BoxEvent> snapshot) {
          final box = Hive.box<Subject>('subjects');
          return ListView.builder(
            itemCount: box.values.length,
            itemBuilder: (context, index) {
              final subject = box.getAt(index);
              return ListTile(
                leading: Container(
                  width: 24,
                  height: 24,
                  color: subject?.color ?? Colors.grey,
                ),
                title: Text(subject?.name ?? 'Unbekannt'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => box.deleteAt(index),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddSubjectScreen()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
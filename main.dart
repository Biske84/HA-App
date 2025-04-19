import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'services/hive_service.dart';
import 'services/notification_service.dart';
import 'screens/tasks_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Timezone initialisieren
  tz.initializeTimeZones();

  // Hive und Services initialisieren
  await Hive.initFlutter();
  await HiveService.init();
  await NotificationService().initialize();
  await HiveService.archiveOldTasks();

  runApp(
    MaterialApp(
      builder: (context, widget) {
        ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
          return Scaffold(
            body: Center(child: Text('App-Fehler: ${errorDetails.exception}')),
          );
        };
        return widget!;
      },
      home: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hausaufgaben-App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const TasksScreen(),
    );
  }
}
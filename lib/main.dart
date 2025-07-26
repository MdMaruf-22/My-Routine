import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:routine_tracker/models/routine_item.dart';
import 'package:routine_tracker/screens/home_screen.dart';
import 'package:routine_tracker/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  print("✅ Flutter binding initialized");

  try {
    await Hive.initFlutter();
    print("✅ Hive initialized");

    Hive.registerAdapter(RoutineItemAdapter());
    print("✅ Adapter registered");

    await Hive.openBox<RoutineItem>('routine');
    print("✅ Hive box opened");

    await NotificationService.init();
    print("✅ Notification service initialized");

  } catch (e, st) {
    print("❌ Error during startup: $e");
  }

  runApp(const RoutineTrackerApp());
  print("✅ App started");
}


class RoutineTrackerApp extends StatelessWidget {
  const RoutineTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Routine Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:routine_tracker/models/routine_item.dart';
import 'package:routine_tracker/widgets/routine_tile.dart';
import 'package:routine_tracker/services/notification_service.dart'; // ← Add this

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Box<RoutineItem> box;

  @override
  void initState() {
    super.initState();
    box = Hive.box<RoutineItem>('routine');

    if (box.isEmpty) {
      final defaultItems = [
        RoutineItem(timeRange: '8:00 – 8:45 AM', title: 'Wake up, freshen up, breakfast', icon: '☀️'),
        RoutineItem(timeRange: '9:00 – 1:00 PM', title: 'Competitive Programming', icon: '💻'),
        RoutineItem(timeRange: '1:00 – 4:00 PM', title: 'Lunch, Shower, Nap or Rest', icon: '😴'),
        RoutineItem(timeRange: '4:00 – 6:00 PM', title: 'Project Work (AI, coding)', icon: '🛠️'),
        RoutineItem(timeRange: '6:00 – 6:45 PM', title: 'Tea/snack break + walk', icon: '☕'),
        RoutineItem(timeRange: '6:45 – 8:45 PM', title: 'Research Paper Reading / Notes', icon: '📖'),
        RoutineItem(timeRange: '9:00 – 10:00 PM', title: 'Dinner + relax', icon: '🍽️'),
        RoutineItem(timeRange: '10:00 – 11:00 PM', title: 'Watch One Piece', icon: '📺'),
        RoutineItem(timeRange: '11:00 – 12:30 AM', title: 'Internship Prep', icon: '📚'),
        RoutineItem(timeRange: '12:30 – 2:00 AM', title: 'Bonus CP or Coding', icon: '💻'),
        RoutineItem(timeRange: '2:00 – 8:00 AM', title: 'Sleep', icon: '💤'),
      ];

      for (var item in defaultItems) {
        box.add(item);
      }

      // Schedule notifications after adding defaults
      scheduleDailyNotifications();
    }
  }

  void scheduleDailyNotifications() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final List<String> times = [
      "08:00", "09:00", "13:00", "16:00", "18:00",
      "18:45", "21:00", "22:00", "23:00", "00:30", "02:00"
    ];

    for (int i = 0; i < box.length; i++) {
      final item = box.getAt(i);
      if (item == null) continue;

      final split = times[i].split(':');
      final hour = int.parse(split[0]);
      final minute = int.parse(split[1]);

      final time = DateTime(today.year, today.month, today.day, hour, minute);

      NotificationService.scheduleNotification(
        id: i,
        title: '🕒 ${item.title}',
        body: 'It\'s time for ${item.timeRange}',
        scheduledTime: time.isBefore(now) ? time.add(const Duration(days: 1)) : time,
      );
    }
  }

  void toggleCompletion(int index) {
    final item = box.getAt(index);
    if (item != null) {
      item.isCompleted = !item.isCompleted;
      item.save();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🗓️ My Daily Routine'),
        centerTitle: true,
      ),
      body: ValueListenableBuilder(
        valueListenable: box.listenable(),
        builder: (context, Box<RoutineItem> routineBox, _) {
          if (routineBox.isEmpty) {
            return const Center(child: Text("No routine items found."));
          }

          return ListView.builder(
            itemCount: routineBox.length,
            itemBuilder: (context, index) {
              final item = routineBox.getAt(index);
              if (item == null) return const SizedBox();
              return RoutineTile(
                item: item,
                onToggle: () => toggleCompletion(index),
              );
            },
          );
        },
      ),
    );
  }
}

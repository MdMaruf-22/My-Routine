import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:routine_tracker/models/routine_item.dart';
import 'package:routine_tracker/services/notification_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Box<RoutineItem> box;
  bool isDarkMode = true;

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
    }

    scheduleDailyNotifications();
  }

  void scheduleDailyNotifications() async {
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

      await NotificationService.scheduleDailyNotification(
        id: i,
        title: '🕒 ${item.title}',
        body: 'It\'s time for ${item.timeRange}',
        hour: hour,
        minute: minute,
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

  void toggleTheme() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF0F4F8);
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final subtitleColor = isDarkMode ? Colors.white70 : Colors.black54;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          '✨ Daily Focus',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: textColor,
            letterSpacing: 0.5,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isDarkMode ? Icons.wb_sunny_outlined : Icons.nightlight_round,
              color: textColor,
            ),
            tooltip: isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode',
            onPressed: toggleTheme,
          ),
          IconButton(
            icon: Icon(Icons.notifications, color: textColor),
            onPressed: () async {
              await NotificationService.showImmediateTestNotification();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Immediate test notification sent')),
              );
            },
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: box.listenable(),
        builder: (context, Box<RoutineItem> routineBox, _) {
          if (routineBox.isEmpty) {
            return Center(
              child: Text(
                "No routine items found.",
                style: TextStyle(color: textColor),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            itemCount: routineBox.length,
            itemBuilder: (context, index) {
              final item = routineBox.getAt(index);
              if (item == null) return const SizedBox();

              return GestureDetector(
                onTap: () => toggleCompletion(index),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: item.isCompleted
                        ? (isDarkMode
                        ? const LinearGradient(colors: [Color(0xFF16A34A), Color(0xFF22C55E)])
                        : const LinearGradient(colors: [Color(0xFFBBF7D0), Color(0xFFA7F3D0)]))
                        : (isDarkMode
                        ? const LinearGradient(colors: [Color(0xFF334155), Color(0xFF1E293B)])
                        : const LinearGradient(colors: [Color(0xFFFFFFFF), Color(0xFFE0E7FF)])),
                    boxShadow: [
                      BoxShadow(
                        color: isDarkMode ? Colors.black.withOpacity(0.2) : Colors.grey.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.icon,
                        style: const TextStyle(fontSize: 30),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: item.isCompleted ? subtitleColor : textColor,
                                decoration: item.isCompleted ? TextDecoration.lineThrough : null,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              item.timeRange,
                              style: TextStyle(
                                color: subtitleColor,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        item.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                        color: item.isCompleted ? textColor : subtitleColor,
                        size: 24,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

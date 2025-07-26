import 'package:hive/hive.dart';

part 'routine_item.g.dart'; // This will be generated

@HiveType(typeId: 0)
class RoutineItem extends HiveObject {
  @HiveField(0)
  String timeRange;

  @HiveField(1)
  String title;

  @HiveField(2)
  String icon;

  @HiveField(3)
  bool isCompleted;

  RoutineItem({
    required this.timeRange,
    required this.title,
    required this.icon,
    this.isCompleted = false,
  });
}

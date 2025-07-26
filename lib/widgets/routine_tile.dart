import 'package:flutter/material.dart';
import 'package:routine_tracker/models/routine_item.dart';

class RoutineTile extends StatelessWidget {
  final RoutineItem item;
  final VoidCallback onToggle;

  const RoutineTile({
    super.key,
    required this.item,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Text(
          item.icon,
          style: const TextStyle(fontSize: 28),
        ),
        title: Text(
          item.title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            decoration: item.isCompleted ? TextDecoration.lineThrough : null,
            color: item.isCompleted ? Colors.grey : Colors.black87,
          ),
        ),
        subtitle: Text(item.timeRange),
        trailing: Checkbox(
          value: item.isCompleted,
          onChanged: (_) => onToggle(),
        ),
      ),
    );
  }
}

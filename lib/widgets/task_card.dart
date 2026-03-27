import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../services/task_dao.dart';
import '../utils/date_extensions.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final bool isBlocked;
  final VoidCallback onTaskTap;
  final VoidCallback onDelete;

  const TaskCard({
    super.key,
    required this.task,
    required this.isBlocked,
    required this.onTaskTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final taskDao = Provider.of<TaskDao>(context, listen: false);
    final blockingTask = task.blockedById != null
        ? taskDao.getTaskById(task.blockedById!)
        : null;

    Color cardColor;
    Color textColor;
    IconData? statusIcon;
    String statusText;

    switch (task.status) {
      case TaskStatus.todo:
        cardColor = Colors.blue.shade50;
        textColor = Colors.blue.shade900;
        statusIcon = Icons.radio_button_unchecked;
        statusText = 'To-Do';
        break;
      case TaskStatus.inProgress:
        cardColor = Colors.orange.shade50;
        textColor = Colors.orange.shade900;
        statusIcon = Icons.hourglass_empty;
        statusText = 'In Progress';
        break;
      case TaskStatus.done:
        cardColor = Colors.green.shade50;
        textColor = Colors.green.shade900;
        statusIcon = Icons.check_circle;
        statusText = 'Done';
        break;
    }

    // Apply blocked overlay
    if (isBlocked) {
      cardColor = Colors.grey.shade200;
      textColor = Colors.grey.shade600;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      color: cardColor,
      child: InkWell(
        onTap: isBlocked ? null : onTaskTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (isBlocked)
                    const Icon(Icons.lock, color: Colors.grey, size: 20)
                  else
                    Icon(statusIcon, color: textColor, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red.shade400),
                    onPressed: onDelete,
                    tooltip: 'Delete task',
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                task.dueDate.formattedDate,
                style: TextStyle(
                  color: textColor.withOpacity(0.8),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                task.description,
                style: TextStyle(
                  color: textColor.withOpacity(0.7),
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Chip(
                    label: Text(
                      statusText,
                      style: const TextStyle(fontSize: 12),
                    ),
                    backgroundColor: textColor.withOpacity(0.1),
                    labelStyle: TextStyle(color: textColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const Spacer(),
                  if (blockingTask != null)
                    Text(
                      'Blocked by: ${blockingTask.title}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
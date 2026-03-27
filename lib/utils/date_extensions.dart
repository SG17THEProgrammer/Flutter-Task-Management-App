import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

extension DateExtensions on DateTime {
  String get formattedDate {
    return DateFormat('MMM dd, yyyy').format(this);
  }

  String get formattedTime {
    return DateFormat('h:mm a').format(this);
  }

  bool isToday() {
    final now = DateTime.now();
    return day == now.day &&
           month == now.month &&
           year == now.year;
  }

  bool isOverdue() {
    return DateTime.now().isAfter(this);
  }

  String get relativeDateString {
    final now = DateTime.now();
    final difference = this.difference(now);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Tomorrow';
    } else if (difference.inDays == -1) {
      return 'Yesterday';
    } else if (difference.inDays > 0 && difference.inDays < 7) {
      return '${difference.inDays} days';
    } else if (difference.inDays < 0 && difference.inDays > -7) {
      return '${-difference.inDays} days ago';
    } else {
      return formattedDate;
    }
  }

  Color get statusColor {
    if (isOverdue()) {
      return Colors.red;
    }
    switch (this.compareTo(DateTime.now())) {
      case 0:
        return Colors.orange;
      case 1:
        return Colors.blue;
      default:
        return Colors.green;
    }
  }
}
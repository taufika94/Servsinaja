import 'package:flutter/material.dart';

class AppNotification {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final IconData icon;
  bool isRead;  // ← NON-FINAL (biar bisa diubah)

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    this.icon = Icons.notifications,
    this.isRead = false,
  });
}
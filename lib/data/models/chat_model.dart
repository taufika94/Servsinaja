import 'package:flutter/material.dart';

class ChatConversation {
  final String id;
  final String name;
  final String avatar;          // path asset, atau '' untuk fallback initial
  final String lastMessage;
  final DateTime lastMessageTime;
  final bool isOnline;
  bool isRead;

  ChatConversation({
    required this.id,
    required this.name,
    required this.avatar,
    required this.lastMessage,
    required this.lastMessageTime,
    this.isOnline = false,
    this.isRead = true,
  });
}
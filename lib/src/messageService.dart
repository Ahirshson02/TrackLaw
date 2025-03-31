import 'dart:async';

import 'package:tracklaw/api/firebaseAPI.dart';

class MessageService {
  static final MessageService _instance = MessageService._internal();
  
  factory MessageService() => _instance;
  
  MessageService._internal();
  
  final StreamController<ChatMessage> _messageController = StreamController<ChatMessage>.broadcast();
  
  Stream<ChatMessage> get messageStream => _messageController.stream;
  
  void sendMessage(ChatMessage message) {
    _messageController.add(message);
  }
  
  void dispose() {
    _messageController.close();
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';

// ChatMessage model
class ChatMessage {
  final String id;
  final String userId;
  final String billId;
  final String text;
  final bool isFromUser;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.userId,
    required this.billId,
    required this.text,
    required this.isFromUser,
    required this.timestamp,
  });

  // Convert ChatMessage object to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'billId': billId,
      'text': text,
      'isFromuser': isFromUser,
      'timestamp': timestamp,
    };
  }

  // Create ChatMessage object from Firestore document
  factory ChatMessage.fromFirestore(Map<String, dynamic> data) {
    return ChatMessage(
      id: data['id'],
      userId: data['userId'],
      billId: data['billId'],
      text: data['text'],
      isFromUser: data['isFromUser'],
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }
}

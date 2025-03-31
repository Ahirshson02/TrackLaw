import 'package:cloud_firestore/cloud_firestore.dart';
import 'congressAPI.dart';

class User {
  final String id;
  final String email;
  final DateTime createdAt;
  final List<String> followedBillIds;

  User({
    required this.id,
    required this.email,
    required this.createdAt,
    required this.followedBillIds,
  });

  // Convert User object to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'createdAt': createdAt,
      'followedBillIds': followedBillIds,
    };
  }

  // Create User object from Firestore document
  factory User.fromFirestore(Map<String, dynamic> data) {
    return User(
      id: data['id'],
      email: data['email'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      followedBillIds: List<String>.from(data['followedBillIds'] ?? []),
    );
  }
}

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

// Firebase Service class to handle all Firestore operations
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collections
  final CollectionReference _usersCollection;
  final CollectionReference _billsCollection;
  final CollectionReference _messagesCollection;

  FirestoreService()
      : _usersCollection = FirebaseFirestore.instance.collection('users'),
        _billsCollection = FirebaseFirestore.instance.collection('bills'),
        _messagesCollection = FirebaseFirestore.instance.collection('messages');

  // USER METHODS
  // Create or update a user
  Future<void> saveUser(User user) async {
    await _usersCollection.doc(user.id).set(user.toMap());
  }

  // Get a user by ID
  Future<User?> getUserById(String userId) async {
    final doc = await _usersCollection.doc(userId).get();
    if (doc.exists) {
      return User.fromFirestore(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  // Get a user by email
  Future<User?> getUserByEmail(String email) async {
    final querySnapshot =
        await _usersCollection.where('email', isEqualTo: email).limit(1).get();

    if (querySnapshot.docs.isNotEmpty) {
      return User.fromFirestore(
          querySnapshot.docs.first.data() as Map<String, dynamic>);
    }
    return null;
  }

  // Update user's followed bills
  Future<void> followBill(String userId, String billId) async {
    await _usersCollection.doc(userId).update({
      'followedBillIds': FieldValue.arrayUnion([billId])
    });
  }

  Future<void> unfollowBill(String userId, String billId) async {
    await _usersCollection.doc(userId).update({
      'followedBillIds': FieldValue.arrayRemove([billId])
    });
  }

  // BILL METHODS
  // Create or update a bill
  Future<void> saveBill(Bill bill) async {
    await _billsCollection.doc(bill.billId).set(bill.toJson());
  }

  // Get a bill by ID
  Future<Bill?> getBillById(String billId) async {
    final doc = await _billsCollection.doc(billId).get();
    if (doc.exists) {
      return Bill.fromJson(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  String getNewMessageID() {
    final id = _messagesCollection.doc().id;
    return id;
  }

  // Get bills followed by a user
  Future<List<Bill>> getFollowedBills(String userId) async {
    final userDoc = await _usersCollection.doc(userId).get();
    if (!userDoc.exists) return [];

    final userData = userDoc.data() as Map<String, dynamic>;
    final followedBillIds =
        List<String>.from(userData['followedBillIds'] ?? []);

    if (followedBillIds.isEmpty) return [];

    // Get bills in batches if there are many (Firestore has limits on "in" queries)
    List<Bill> results = [];

    // Process in batches of 10 (arbitrary, adjust as needed)
    for (int i = 0; i < followedBillIds.length; i += 10) {
      final end =
          (i + 10 < followedBillIds.length) ? i + 10 : followedBillIds.length;

      final batch = followedBillIds.sublist(i, end);

      final querySnapshot =
          await _billsCollection.where('id', whereIn: batch).get();

      results.addAll(querySnapshot.docs
          .map((doc) => Bill.fromJson(doc.data() as Map<String, dynamic>))
          .toList());
    }

    return results;
  }

  // CHAT MESSAGE METHODS
  // Create a new chat message
  Future<void> sendMessage(ChatMessage message) async {
    // If message ID is not set, generate one
    final messageId =
        message.id.isEmpty ? _messagesCollection.doc().id : message.id;

    await _messagesCollection.doc(messageId).set(message.toMap());
  }

  // Get chat messages for a specific bill
  Future<List<ChatMessage>> getMessagesForBill(String billId, String userId,
      {int limit = 50}) async {
    final querySnapshot = await _messagesCollection
        .where(
          'billId',
          isEqualTo: billId,
        )
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .get();

    return querySnapshot.docs
        .map((doc) =>
            ChatMessage.fromFirestore(doc.data() as Map<String, dynamic>))
        .toList();
  }

  // Stream chat messages for a specific bill (real-time updates) ------------ Delete?
  Stream<List<ChatMessage>> streamMessagesForBill(
      String billId, String userId) {
    return _messagesCollection
        .where('billId', isEqualTo: billId)
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                ChatMessage.fromFirestore(doc.data() as Map<String, dynamic>))
            .toList());
  }

  // USER-BILL RELATIONSHIP METHODS
  Future<void> recordUserBillInteraction(
      String userId, String billId, String type) async {
    // ------------------ delete?
    await _firestore.collection('user_bill_interactions').add({
      'userId': userId,
      'billId': billId,
      'type': type, // e.g., 'view', 'comment', 'like', etc.
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}

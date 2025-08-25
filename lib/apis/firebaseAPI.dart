import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:tracklaw/models/congress.dart';
import 'package:tracklaw/models/chatMessage.dart';


// class UserNotifier extends ChangeNotifier {
//   User? _user;
//   final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   get user => null;
  
//   void initializeUser() {
//     _auth.authStateChanges().listen((firebaseUser) async {
//       if (firebaseUser != null) {
//         // Load additional user data from Firestore
//         final userData = await _firestore
//             .collection('users')
//             .doc(firebaseUser.uid)
//             .get();
        
//         _user = User.fromFirebase(firebaseUser, userData.data());
//        //_user = User.fromFirebase(userData.data()!);
//         notifyListeners();
//       } else {
//         _user = null;
//         notifyListeners();
//       }
//     });
//   }
  
//   Future<void> updateUserLikes(String itemId) async {
//     _user?.likes.add(itemId);
//     notifyListeners();
    
//     // Sync to Firebase
//     await _firestore
//         .collection('users')
//         .doc(_user?.id)
//         .update({'likes': _user?.likes});
//   }
// }

class UserNotifier extends ChangeNotifier {
  User? _user;
  StreamSubscription<firebase_auth.User?>? _authSubscription;
  FirestoreService fs = FirestoreService();
  User? get user => _user;
  bool get isLoggedIn => _user != null;
  
  UserNotifier() {
    _initializeAuthListener();
  }
  
  void _initializeAuthListener() {
    _authSubscription = firebase_auth.FirebaseAuth.instance
        .authStateChanges()
        .listen((firebaseUser) async {
      if (firebaseUser != null) {
        print('User signed in: ${firebaseUser.email}');
        
        // Here you could fetch additional user data from Firestore
        final userData = await FirebaseFirestore.instance
            .collection('users')
            .doc(firebaseUser.uid)
            .get();
        final likesData = await FirebaseFirestore.instance.collection('likes').doc(firebaseUser.uid).get();

        _user = User.fromFirebase(firebaseUser, userData.data(), likesData.data());

      
        notifyListeners(); // This updates all widgets using context.watch
      } else {
        print('User signed out');
        _user = null;
        notifyListeners();
      }
    });
  }
  
  // Your app-specific methods
  void addLike(String itemId) {
    if (_user != null && !_user!.likes.contains(itemId)) {
      _user!.likes.add(itemId);
      notifyListeners();
      fs.followBill(_user!.id, itemId);
    }
  }
  
  void removeLike(String itemId) {
    if (_user != null) {
      _user!.likes.remove(itemId);
      notifyListeners();
      fs.unfollowBill(_user!.id, itemId);
    }
  }
  
  Future<void> signOut() async {
    await firebase_auth.FirebaseAuth.instance.signOut();
    // _user will automatically be set to null by the auth listener
  }
  
  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}

class User {
  final String id;
  final String email;
  final DateTime createdAt;
  List<String> likes; //Convert to List<bills>, and have a Bills collection?
  final DateTime lastActive;

  User({
    required this.id,
    required this.email,
    required this.createdAt,
    required this.likes,
    required this.lastActive,
  });

  // Convert User object to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'createdAt': createdAt,
      'followedBillIds': likes,
    };
  }

  // Create User object from Firestore document
  //  ADAPT THIS FACTORY MODEL
  factory User.fromFirebase(
    firebase_auth.User firebaseUser, 
    Map<String, dynamic>? firestoreData,
    Map<String, dynamic>? likeData
  ) {

    return User(
      id: firebaseUser.uid,                    // From Firebase Auth
      email: firebaseUser.email ?? '',        // From Firebase Auth
      likes: List<String>.from(likeData?['billID'] ?? []),           // From Firestore
      lastActive: (firestoreData?['lastActive'] as Timestamp?)?.toDate() 
                  ?? DateTime.now(),  // From Firestore
      createdAt: (firestoreData?['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // factory User.fromFirebase(Map<String, dynamic> data) {
  //   return User(
  //     id: data['id'],
  //     email: data['email'],
  //     createdAt: (data['createdAt'] as Timestamp).toDate(),
  //     likes: List<String>.from(data['followedBillIds'] ?? []),
  //     lastActive: (firestoreData?['lastActive'] as Timestamp?)?.toDate() 
  //                  ?? DateTime.now(),  // From Firestore
  //   );
  // }
}


// Firebase Service class to handle all Firestore operations
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collections
  final CollectionReference _usersCollection;
  final CollectionReference _billsCollection;
  final CollectionReference _messagesCollection;
  final CollectionReference _likesCollection;

  FirestoreService()
      : _usersCollection = FirebaseFirestore.instance.collection('users'),
        _billsCollection = FirebaseFirestore.instance.collection('bills'),
        _messagesCollection = FirebaseFirestore.instance.collection('messages'),
        _likesCollection = FirebaseFirestore.instance.collection('likes');

  // USER METHODS
  // Create or update a user

//SHOULDN'T NEED
  // Get a user by ID
  // Future<User?> getUserById(String userId) async {
  //   final doc = await _usersCollection.doc(userId).get();
  //   if (doc.exists) {
  //     return User.fromFirebase(doc.data() as Map<String, dynamic>);
  //   }
  //   return null;
  // }

  // // Get a user by email
  // Future<User?> getUserByEmail(String email) async {
  //   final querySnapshot =
  //       await _usersCollection.where('email', isEqualTo: email).limit(1).get();

  //   if (querySnapshot.docs.isNotEmpty) {
  //     return User.fromFirebase(
  //         querySnapshot.docs.first.data() as Map<String, dynamic>);
  //   }
  //   return null;
  // }

  // Update user's followed bills
  Future<void> followBill(String userId, String billId) async {
    // await _usersCollection.doc(userId).update({
    //   'followedBillIds': FieldValue.arrayUnion([billId])
    // });
    final likes = _likesCollection.doc(userId);
    //merge new billId into likes
    await likes.set({'billID': FieldValue.arrayUnion([billId])
    //don't overwrite previous likes
    }, SetOptions(merge: true));
  }

  Future<void> unfollowBill(String userId, String billId) async {
    // await _usersCollection.doc(userId).update({
    //   'followedBillIds': FieldValue.arrayRemove([billId])
    // });
      final likes = _likesCollection.doc(userId);
      //merge new billId into likes
      await likes.update({'billID': FieldValue.arrayRemove([billId])
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
    final messageId = message.id.isEmpty 
        ? _messagesCollection.doc().id 
        : message.id;
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

// ignore_for_file: dead_code

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:tracklaw/models/congress.dart';
import 'package:tracklaw/models/chatMessage.dart';
import 'package:tracklaw/models/pagedBills.dart';
import './../models/user.dart';


class UserNotifier extends ChangeNotifier {
  User? _user;
  StreamSubscription<firebase_auth.User?>? _authSubscription;
  FirestoreService fs = FirestoreService();
  User? get user => _user;
  bool get isLoggedIn => _user != null;
  List<Bill> currentBills = [];  //ties bills visible to user to an instance variable
  DocumentSnapshot? lastDoc;

  
  UserNotifier() {
    _initializeAuthListener();
  }
  
  void _initializeAuthListener() {
    _authSubscription = firebase_auth.FirebaseAuth.instance
        .authStateChanges()
        .listen((firebaseUser) async {
      if (firebaseUser != null) {
        print('User signed in: ${firebaseUser.email}');
        

        final userData = await FirebaseFirestore.instance
            .collection('users')
            .doc(firebaseUser.uid)
            .get();
        FirestoreService fs = FirestoreService();
        final likesData = await fs.getFollowedBills(firebaseUser.uid);


        _user = User.fromFirebase(firebaseUser, userData.data(), likesData);
        print("firebaseAPI - Printing like IDs");
        for(int i = 0; i < _user!.likes.length; i++){
         // print(_user!.likes[i].billId);
          print(likesData[i]);
        }
        PagedBills page = await getBills("updateDate"); //initialize bills for user feed
        currentBills.addAll(page.bills);
        lastDoc = page.lastDoc;
      
        notifyListeners(); // This updates all widgets using context.watch
      } else {
        print('User signed out');
        _user = null;
        notifyListeners();
      }
    });
  }
  
  // Your app-specific methods
  void addLike(Bill bill) {
    if (_user != null && !_user!.likes.contains(bill)) {
      _user!.likes.add(bill);
      
      fs.followBill(_user!.id, bill.billId);
      notifyListeners();
    }
  }
  
  void removeLike(Bill bill) {
    if (_user != null) {
      _user!.likes.remove(bill);
      fs.unfollowBill(_user!.id, bill.billId);
      notifyListeners();
    }
  }

//query a List<Bill> from firebase, using order for "where" and index for start - add to state managed list of bills
  Future<PagedBills> getBills(String order) async {
    print("In getBills");
    PagedBills page = await fs.getBillsFB(order, lastDoc);
    // currentBills.addAll(page.bills);
    // lastDoc = page.lastDoc!;
   // print("In getBills: ${currentBills[0].billId}");
    notifyListeners();
    return page;
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



  Future<PagedBills> getBillsFB(String order, DocumentSnapshot? lastDoc) async {
    var query = FirebaseFirestore.instance
        .collection("bills")
        .orderBy(order, descending: true)
        .limit(20);

    if (lastDoc != null) {
      query = query.startAfterDocument(lastDoc);
    }

    final snapshot = await query.get();

    final bills = snapshot.docs
        .map((d) => Bill.fromJson(d.data()))
        .toList();

    final newLastDoc = snapshot.docs.isNotEmpty ? snapshot.docs.last : lastDoc;
    print(bills.isEmpty ? "bills is empty in getbillFB" : "bills is NOT EMPTY in getBillsFb");
    if(newLastDoc == lastDoc){
      return PagedBills(bills, newLastDoc, false);
    }
    else {
      return PagedBills(bills, newLastDoc, true);
    }
  }

  // USER METHODS
  // Create or update a user

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

    // Get bills followed by a user -- adjust to use likes document id (user id) to query likes collection - store in user state/cache somehow?
  Future<List<Bill>> getFollowedBills(String userId) async {
    print("getting likes for userID: $userId");
    final likesDoc = await _likesCollection.doc(userId).get();
    if (!likesDoc.exists) return [];
    
    final billIds = likesDoc.data() as Map<String, dynamic>;
    final followedBillIds =
        List<String>.from(billIds['billID'] ?? []);
    if (followedBillIds.isEmpty){
      print("followedBillIds is empty");
      return [];
    } 
    print("followedBillIds: ${followedBillIds[0]}");

    // Get bills in batches
    List<Bill> bills = [];

    // Process in batches of 10 (arbitrary, adjust as needed)
    const batchSize = 10;
    for (var i = 0; i < followedBillIds.length; i += batchSize){
      final batch = followedBillIds.sublist(i, (i + batchSize > followedBillIds.length ? followedBillIds.length : i + batchSize));
      final snapshot = await _billsCollection.where(FieldPath.documentId, whereIn: batch).get();
      bills.addAll(snapshot.docs.map((d) => Bill.fromJson(d.data() as Map<String, dynamic>)));
    }
    
    return bills;
  }

  String getNewMessageID() {
    final id = _messagesCollection.doc().id;
    return id;
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

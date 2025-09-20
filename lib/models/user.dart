import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:tracklaw/models/congress.dart';
import 'package:tracklaw/models/user.dart';
import 'package:flutter/material.dart';
import 'dart:async';


class User {
  final String id;
  final String email;
  final DateTime createdAt;
  List<Bill> likes; //Convert to List<bills>, and have a Bills collection?
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
    List<Bill> likesData
  ) {
    return User(
      id: firebaseUser.uid,                    // From Firebase Auth
      email: firebaseUser.email ?? '',        // From Firebase Auth
      likes: likesData,           // From Firestore
      lastActive: (firestoreData?['lastActive'] as Timestamp?)?.toDate() 
                  ?? DateTime.now(),  // From Firestore
      createdAt: (firestoreData?['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
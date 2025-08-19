import 'dart:async';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Import Firebase
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import 'package:tracklaw/apis/firebaseAPI.dart';

import 'package:tracklaw/landingPage/loadingScreen.dart';
import 'package:tracklaw/landingPage/openingPage.dart';


void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Ensures Flutter is ready before Firebase initializes
  await dotenv.load(fileName: ".env");  //path to your .env file);
  await Firebase.initializeApp();
  
  runApp(ChangeNotifierProvider(
    create: (context) => UserNotifier(),
    child: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  //late StreamSubscription<firebase_auth.User?> user;
void initState() {
    super.initState();
    // user = firebase_auth.FirebaseAuth.instance
    //     .authStateChanges()
    //     .listen((firebaseUser) {  
    //   if (firebaseUser != null) {
    //     print('User signed in: ${firebaseUser.email}');
    //   } else {
    //     print('User signed out');
    //   }
    // });
  }
  void dispose(){
    //user.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: firebase_auth.FirebaseAuth.instance.currentUser == null ? WelcomePage.id : LoadingScreen.id,
      routes:{
        WelcomePage.id: (context) => WelcomePage(),
        LoadingScreen.id: (context) => LoadingScreen()
      },
      home: WelcomePage()
    );
  }
}

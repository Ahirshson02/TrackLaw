import 'package:flutter/material.dart';

import 'package:tracklaw/src/homescreen.dart';
import 'package:tracklaw/APIs/congressAPI.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:tracklaw/landingPage/login&signupPage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //make first API call here? to save time on homescreen
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: openingPage(),// Show a loading screen first
    );
  }
}

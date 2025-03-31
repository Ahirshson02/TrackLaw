import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tracklaw/landingPage/loadingScreen.dart';
import 'package:tracklaw/landingPage/openingPage.dart';

class auth extends StatelessWidget {
  const auth({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: FirebaseAuth.instance.signOut(), // Force logout
        builder: (context, snapshot) {
          return StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final user = FirebaseAuth.instance.currentUser;
                if (user != null && user.emailVerified) {
                  return LoadingScreen(); // ✅ Only verified users proceed
                } else {
                  return openingPage(); // ❌ Unverified users go to openingPage
                }
              } else {
                return openingPage();
              }
            },
          );
        },
      ),
    );
  }
}

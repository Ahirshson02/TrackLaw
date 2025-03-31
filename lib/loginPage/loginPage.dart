import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tracklaw/landingPage/loadingScreen.dart';
import 'package:tracklaw/registerPage/textField.dart';
import 'package:tracklaw/landingPage/Button.dart';

class LoginAccount extends StatefulWidget {
  const LoginAccount({Key? key}) : super(key: key);

  @override
  State<LoginAccount> createState() => _LoginAccount();
}

class _LoginAccount extends State<LoginAccount> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  Future<void> signIn() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // print("✅ Sign-in successful!");

      setState(() {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoadingScreen()),
        );
      });
    } on FirebaseAuthException catch (e) {
      print("❌ Error: ${e.message}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? "Login failed")),
      );
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Center(
            child: Column(
          children: [
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 100),
              child: Text(
                  'Welcome back to the fastest and easiest way to see whats going on.',
                  style: TextStyle(fontSize: 20)),
            ),
            SizedBox(height: 30),
            Mytext(
                controller: emailController,
                hintText: 'email',
                obscureText: false),
            //password
            SizedBox(height: 30),
            Mytext(
                controller: passwordController,
                hintText: 'password',
                obscureText: false),

            SizedBox(height: 70),
            Text('You can also register with the following',
                style: TextStyle(fontSize: 15, color: Colors.grey)),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                    child: Divider(
                  indent: 20,
                  endIndent: 20,
                  thickness: 0.5,
                  color: Colors.grey,
                ))
              ],
            ),

            SizedBox(height: 20),
            MyButton(onTap: () {
              signIn();
            })
          ],
        )),
      ),
    );
  }
}

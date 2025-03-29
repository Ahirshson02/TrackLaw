import 'package:flutter/material.dart';

class RegisterNewAccount extends StatefulWidget {
  const RegisterNewAccount({Key? key}) : super(key: key);

  @override
  State<RegisterNewAccount> createState() => _RegisterNewAccount();
}

class _RegisterNewAccount extends State<RegisterNewAccount> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register')),
      body: Center(
        child: Text('Welcome to the Registration Page!'),
      ),
    );
  }
}

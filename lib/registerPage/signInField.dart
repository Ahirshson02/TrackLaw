import 'package:flutter/material.dart';

class SignInField extends StatelessWidget {
  final controller;
  final String hintText;
  final bool obscureText;

  const SignInField(
      {super.key,
      required this.controller,
      required this.hintText,
      required this.obscureText});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 330,
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 9),
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey)),
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey)),
            hintText: hintText),
      ),
    );
  }
}

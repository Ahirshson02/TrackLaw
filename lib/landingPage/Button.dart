import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final Function()? onTap;
  const MyButton({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
          padding: EdgeInsets.all(20),
          margin: EdgeInsets.symmetric(horizontal: 60),
          decoration: BoxDecoration(
            color: Colors.blueGrey,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
              child: Text(
            "Sign in",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ))),
    );
  }
  static Function() navigateTo(BuildContext context, Widget page) {
  return () {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => page,
      ),
    );
  };
}
}

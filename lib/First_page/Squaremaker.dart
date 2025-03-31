import 'package:flutter/material.dart';

class Squaretile extends StatelessWidget {
  final String imagePath;
  const Squaretile({
    super.key,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Image.asset(
        imagePath,
        height: 60,
      ),
    );
  }
}

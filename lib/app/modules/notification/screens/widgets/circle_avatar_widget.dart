import 'package:flutter/material.dart';

class CircleLetterAvatar extends StatelessWidget {
  final String letter;
  final double radius;
  final Color backgroundColor;
  final Color textColor;

  const CircleLetterAvatar({
    super.key,
    required this.letter,
    this.radius = 20,
    this.backgroundColor = Colors.transparent,
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor,
      child: Text(
        letter,
        style: TextStyle(
          color: textColor,
          fontSize: radius,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

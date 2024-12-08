import 'package:flutter/material.dart';

class FooterText extends StatelessWidget {
  final String text;

  FooterText({required this.text, required TextStyle style});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 16.0,
        color: Color(0xFFECDBBA),
        fontFamily: 'Tektur',
      ),
      textAlign: TextAlign.center,
    );
  }
}
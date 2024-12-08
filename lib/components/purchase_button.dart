import 'package:flutter/material.dart';

class PurchaseButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const PurchaseButton({
    Key? key,
    required this.text,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromRGBO(200, 75, 49, 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 10,
          color: Color.fromRGBO(236, 219, 186, 1),
          fontFamily: 'Russo One',
        ),
      ),
    );
  }
}
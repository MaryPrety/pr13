import 'package:flutter/material.dart';

class BookCover extends StatelessWidget {
  final String imageUrl;

  const BookCover({Key? key, required this.imageUrl, required String imagePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: Image.network(
        imageUrl,
        fit: BoxFit.cover,
        width: 160,
        height: 240,
      ),
    );
  }
}
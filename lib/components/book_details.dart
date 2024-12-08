import 'package:flutter/material.dart';

class BookDetails extends StatelessWidget {
  final String title;
  final String description;
  final String price;

  const BookDetails({
    Key? key,
    required this.title,
    required this.description,
    required this.price,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            color: Color.fromRGBO(45, 66, 99, 1),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: const TextStyle(
            fontSize: 10,
            color: Color.fromRGBO(45, 66, 99, 1),
            fontFamily: 'Tektur',
          ),
        ),
        const SizedBox(height: 8),
        Text(
          price,
          style: const TextStyle(
            fontSize: 14,
            color: Color.fromRGBO(45, 66, 99, 1),
          ),
        ),
      ],
    );
  }
}
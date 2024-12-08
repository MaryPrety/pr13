import 'package:flutter/material.dart';

class AdditionalImages extends StatelessWidget {
  final List<String> imageUrls;

  const AdditionalImages({required this.imageUrls});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: imageUrls.map((url) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14.0),
            child: Image.asset(
              url,
              width: 50.0,
              height: 50.0,
              fit: BoxFit.cover,
            ),
          ),
        );
      }).toList(),
    );
  }
}
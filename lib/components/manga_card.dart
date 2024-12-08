import 'package:flutter/material.dart';

class MangaCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final String description;
  final String price;
  final VoidCallback onTap;
  final VoidCallback onAddToFavorite; // Новый параметр для добавления в избранное

  const MangaCard({
    Key? key,
    required this.imagePath,
    required this.title,
    required this.description,
    required this.price,
    required this.onTap,
    required this.onAddToFavorite, // Добавляем новый параметр
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    // Плавное уменьшение шрифта, учитывая ширину экрана
    final titleFontSize = (screenWidth * 0.06).clamp(20.0, 26.0);
    final descriptionFontSize = (screenWidth * 0.04).clamp(14.0, 20.0);
    final priceFontSize = (screenWidth * 0.05).clamp(18.0, 24.0);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: const Color(0xFFECDBBA),
          borderRadius: BorderRadius.circular(35),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Image.network(
                imagePath,
                fit: BoxFit.cover,
                width: isMobile ? screenWidth * 0.3 : 150,
                height: isMobile ? screenWidth * 0.45 : 225,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(child: Text('Ошибка загрузки изображения'));
                },
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: titleFontSize, // Плавное уменьшение шрифта заголовка
                      color: const Color(0xFF2D4263),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: descriptionFontSize, // Плавное уменьшение шрифта описания
                      color: const Color(0xFF2D4263),
                      fontFamily: 'Tektur',
                    ),
                    maxLines: 2, // Ограничение на количество строк
                    overflow: TextOverflow.ellipsis, // Троеточие при переполнении
                  ),
                  const SizedBox(height: 10),
                  Text(
                    price,
                    style: TextStyle(
                      fontSize: priceFontSize, // Плавное уменьшение шрифта цены
                      color: const Color(0xFF2D4263),
                    ),
                  ),
                  const SizedBox(height: 10),
                  IconButton(
                    icon: Icon(Icons.favorite_border), // Иконка избранного
                    onPressed: onAddToFavorite, // Вызов колбека при нажатии
                    tooltip: 'Добавить в избранное',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

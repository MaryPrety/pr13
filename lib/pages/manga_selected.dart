import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/manga_item.dart';
import 'manga_details_screen.dart';
import '../providers/favorite_provider.dart';
import '../providers/cart_provider.dart'; // Импортируем CartProvider

class MangaSelectedPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final favoriteProvider = Provider.of<FavoriteProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context); // Добавляем CartProvider
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Scaffold(
      backgroundColor: const Color(0xFF191919),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _buildHeader(context, isMobile, screenWidth),
            const SizedBox(height: 20),
            Expanded(
              child: favoriteProvider.favoriteItems.isEmpty
                  ? _buildEmptyFavoritesMessage()
                  : _buildFavoriteMangaGrid(context, favoriteProvider, cartProvider, isMobile, screenWidth),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isMobile, double screenWidth) {
    return Align(
      alignment: Alignment.topCenter,
      child: Text(
        'MANgo100',
        style: TextStyle(
          fontSize: isMobile ? 30.0 : 40.0,
          color: const Color(0xFFECDBBA),
          fontFamily: 'Tektur',
        ),
      ),
    );
  }

  Widget _buildEmptyFavoritesMessage() {
    return const Center(
      child: Text(
        'Список избранных товаров пуст',
        style: TextStyle(fontSize: 18, color: Color(0xFFECDBBA)),
      ),
    );
  }

  Widget _buildFavoriteMangaGrid(BuildContext context, FavoriteProvider favoriteProvider, CartProvider cartProvider, bool isMobile, double screenWidth) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isMobile ? 1 : 2, // Один столбец на мобильных устройствах, два на десктопах
        childAspectRatio: isMobile ? 1.6 : 2.3, // Соотношение ширины и высоты
        crossAxisSpacing: 20, // Расстояние между столбцами
        mainAxisSpacing: 10, // Расстояние между строками
      ),
      padding: const EdgeInsets.all(16),
      itemCount: favoriteProvider.favoriteItems.length,
      itemBuilder: (context, index) {
        final manga = favoriteProvider.favoriteItems[index];
        return _buildMangaCard(context, manga, index, favoriteProvider, cartProvider, screenWidth);
      },
    );
  }

  Widget _buildMangaCard(BuildContext context, MangaItem manga, int index, FavoriteProvider favoriteProvider, CartProvider cartProvider, double screenWidth) {
    final isMobile = screenWidth < 600;
    
    // Плавное уменьшение шрифта, учитывая ширину экрана
    final titleFontSize = (screenWidth * 0.06).clamp(14.0, 26.0);
    final descriptionFontSize = (screenWidth * 0.04).clamp(12.0, 20.0);
    final priceFontSize = (screenWidth * 0.05).clamp(12.0, 24.0);

    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MangaDetailsScreen(
              title: manga.title ?? '',
              price: manga.price ?? '',
              index: index,
              additionalImages: manga.additionalImages ?? [],
              description: manga.description ?? '',
              format: manga.format ?? '',
              publisher: manga.publisher ?? '',
              imagePath: manga.imagePath ?? '',
              chapters: manga.chapters ?? '',
              onDelete: () {
                favoriteProvider.removeFromFavorites(manga); // Логика удаления
              },
            ),
          ),
        );

        if (result != null && result is int) {
          favoriteProvider.removeFromFavorites(manga);
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: const Color(0xFFECDBBA),
          borderRadius: BorderRadius.circular(35),
        ),
        child: Stack(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start, // Для выравнивания сверху
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: Image.network(
                    manga.imagePath ?? '',
                    fit: BoxFit.cover,
                    width: isMobile ? screenWidth * 0.3 : 160,
                    height: isMobile ? screenWidth * 0.45 : 280,
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(child: Text('Ошибка загрузки изображения'));
                    },
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8.0), // Отступ для текста от верхнего края
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          manga.title ?? '',
                          style: TextStyle(
                            fontSize: titleFontSize, // Плавное уменьшение шрифта заголовка
                            color: const Color(0xFF2D4263),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          manga.description ?? '',
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
                          manga.price ?? '',
                          style: TextStyle(
                            fontSize: priceFontSize, // Плавное уменьшение шрифта цены
                            color: const Color(0xFF2D4263),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              top: 8,
              right: 8,
              child: _buildIconButton(
                icon: Icons.delete,
                onTap: () => favoriteProvider.removeFromFavorites(manga),
                screenWidth: screenWidth,
              ),
            ),
            Positioned(
              bottom: 8,
              right: 8,
              child: _buildIconButton(
                icon: cartProvider.cartItems.contains(manga) ? Icons.shopping_cart : Icons.add_shopping_cart,
                onTap: () => cartProvider.cartItems.contains(manga) ? cartProvider.removeFromCart(manga) : cartProvider.addToCart(manga),
                screenWidth: screenWidth,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Общий стиль для кнопок
  Widget _buildIconButton({required IconData icon, required VoidCallback onTap, required double screenWidth}) {
    final iconSize = (screenWidth * 0.06).clamp(16.0, 20.0); // Плавное уменьшение размера иконки
    final buttonSize = (screenWidth * 0.1).clamp(32.0, 40.0); // Плавное уменьшение размера кнопки

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: buttonSize,
        height: buttonSize,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15), // Закругляем углы
          color: const Color(0xFFC84B31),
        ),
        child: Icon(
          icon,
          color: const Color(0xFFECDBBA),
          size: iconSize,
        ),
      ),
    );
  }
}
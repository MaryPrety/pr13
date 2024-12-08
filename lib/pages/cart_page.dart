import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../providers/cart_provider.dart';
import '../models/manga_item.dart';
import 'manga_details_screen.dart'; // Импортируем страницу с описанием

class CartPage extends StatefulWidget {
  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<MangaItem> _dismissedItems = [];

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final cartItems = cartProvider.cartItems;

    return Scaffold(
      body: Container(
        color: const Color(0xFF191919), // Темно-черный фон
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              _buildHeader(context, true), // Добавляем заголовок
              Expanded(
                child: cartItems.isEmpty
                    ? Center(
                        child: Text(
                          'Не стесняйтесь выбрать мангу, чтобы потом здесь ее увидеть!',
                          style: TextStyle(
                            fontSize: 20.0,
                            color: Color(0xFFECDBBA),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : ListView.builder(
                        itemCount: cartItems.length,
                        itemBuilder: (context, index) {
                          final item = cartItems[index];
                          return _buildSlidableCartItemCard(context, item, cartProvider);
                        },
                      ),
              ),
              if (cartItems.isNotEmpty) _buildTotalPrice(cartProvider),
              if (cartItems.isNotEmpty) _buildActionButtons(context, cartProvider),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isMobile) {
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

  Widget _buildSlidableCartItemCard(BuildContext context, MangaItem item, CartProvider cartProvider) {
    return Slidable(
      key: Key(item.title ?? ''),
      endActionPane: ActionPane(
        motion: ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (context) {
              setState(() {
                _dismissedItems.add(item);
                cartProvider.removeFromCart(item);
              });
            },
            backgroundColor: Colors.transparent,
            foregroundColor: const Color(0xFFC84B31),
            icon: Icons.delete,
            label: 'Удалить',
          ),
        ],
      ),
      child: _buildCartItemCard(context, item, cartProvider),
    );
  }

  Widget _buildCartItemCard(BuildContext context, MangaItem item, CartProvider cartProvider) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MangaDetailsScreen(
              title: item.title ?? '',
              price: item.price ?? '',
              index: cartProvider.cartItems.indexOf(item), 
              additionalImages: item.additionalImages ?? [],
              description: item.description ?? '',
              format: item.format ?? '',
              publisher: item.publisher ?? '',
              imagePath: item.imagePath ?? '',
              chapters: item.chapters ?? '',
              onDelete: () => cartProvider.removeFromCart(item),
            ),
          ),
        );
      },
      child: AnimatedSwitcher(
        duration: Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(opacity: animation, child: child);
        },
        child: _dismissedItems.contains(item)
            ? _buildDeleteButton(context, item, cartProvider)
            : Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: const Color(0xFFECDBBA), 
                  borderRadius: BorderRadius.circular(35),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: Image.network(
                        item.imagePath ?? '',
                        fit: BoxFit.cover,
                        width: 160,
                        height: 200,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(child: Text('Ошибка загрузки изображения'));
                        },
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title ?? '',
                              style: const TextStyle(
                                fontSize: 26.0,
                                color: Color(0xFF2D4263),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              item.format ?? '',
                              style: const TextStyle(
                                fontSize: 20.0,
                                color: Color(0xFF2D4263),
                                fontFamily: 'Tektur',
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              '${item.price ?? ''} x ${cartProvider.getItemQuantity(item)} = ${int.tryParse(item.price?.replaceAll(' рублей', '') ?? '0') ?? 0 * cartProvider.getItemQuantity(item)} рублей',
                              style: const TextStyle(
                                fontSize: 24.0,
                                color: Color(0xFF2D4263),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                _buildIconButton(
                                  icon: Icons.remove,
                                  onTap: () {
                                    if (cartProvider.getItemQuantity(item) > 1) {
                                      cartProvider.decreaseQuantity(item);
                                    } else {
                                      setState(() {
                                        _dismissedItems.add(item);
                                        cartProvider.removeFromCart(item);
                                      });
                                    }
                                  },
                                ),
                                const SizedBox(width: 8), 
                                Text(
                                  '${cartProvider.getItemQuantity(item)}',
                                  style: const TextStyle(
                                    fontSize: 20.0,
                                    color: Color(0xFF2D4263),
                                  ),
                                ),
                                const SizedBox(width: 8), 
                                _buildIconButton(
                                  icon: Icons.add,
                                  onTap: () {
                                    cartProvider.increaseQuantity(item);
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildDeleteButton(BuildContext context, MangaItem item, CartProvider cartProvider) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFECDBBA),
        borderRadius: BorderRadius.circular(35),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _buildIconButton(
            icon: Icons.delete,
            onTap: () {
              setState(() {
                cartProvider.removeFromCart(item); // Удаление из корзины
                _dismissedItems.remove(item); // Удаление из списка скрытых элементов
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTotalPrice(CartProvider cartProvider) {
    int totalPrice = 0;
    for (var item in cartProvider.cartItems) {
      totalPrice += (int.tryParse(item.price?.replaceAll(' рублей', '') ?? '0') ?? 0) * cartProvider.getItemQuantity(item);
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      child: Text(
        'Итого: $totalPrice рублей',
        style: const TextStyle(
          fontSize: 24.0,
          color: Color(0xFFECDBBA),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Общий стиль для кнопок
  Widget _buildIconButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 24, // Размер кнопки
        height: 24, // Размер кнопки
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          color: const Color(0xFFC84B31),
          borderRadius: BorderRadius.circular(6), // Небольшое скругление углов
        ),
        child: Icon(
          icon,
          color: const Color(0xFFECDBBA),
          size: 18, // Размер иконки
        ),
      ),
    );
  }

  // Кнопка для заказа и удаления всех товаров
  Widget _buildActionButtons(BuildContext context, CartProvider cartProvider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween, // Выравнивание кнопок по краям
      children: [
        ElevatedButton(
          onPressed: () {
            cartProvider.clearCart(); // Удаление всех товаров из корзины
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFC84B31), // Красная кнопка для удаления всех товаров
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14), // Уменьшенное скругление
            ),
          ),
          child: const Icon(
            Icons.delete_forever, // Иконка мусорки
            color: Colors.white,
          ),
        ),
        ElevatedButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Заказ оформлен')),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFC84B31),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14), // Уменьшенное скругление
            ),
          ),
          child: const Icon(
            Icons.attach_money, // Иконка двух монет или купюр
            color: Color(0xFFECDBBA),
          ),
        ),
      ],
    );
  }
}
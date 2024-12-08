import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/manga_item.dart';
import 'manga_details_screen.dart';
import 'upload_new_volume_page.dart';
import '../providers/favorite_provider.dart';
import '../providers/cart_provider.dart'; // Импортируем CartProvider
import '../services/api_service.dart'; // Импортируем ApiService

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<MangaItem> productItems = [];
  List<MangaItem> filteredItems = [];
  bool isLoading = true;
  String searchQuery = '';
  String sortBy = 'title';
  String sortOrder = 'asc';
  String? selectedPublisher;
  double minPrice = 0;
  double maxPrice = 1000;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    try {
      final products = await ApiService().fetchProducts();
      setState(() {
        productItems = products;
        filteredItems = products;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching products: $e');
    }
  }

  // Обновление списка товаров на основе поискового запроса, сортировки и фильтров
  void _updateFilteredItems() {
    setState(() {
      filteredItems = productItems.where((item) {
        final titleMatch = item.title.toLowerCase().contains(searchQuery.toLowerCase());
        final descriptionMatch = item.description.toLowerCase().contains(searchQuery.toLowerCase());
        final priceMatch = double.parse(item.price.replaceAll(' рублей', '')) >= minPrice && double.parse(item.price.replaceAll(' рублей', '')) <= maxPrice;
        final publisherMatch = selectedPublisher == null || item.publisher == selectedPublisher;
        return (titleMatch || descriptionMatch) && priceMatch && publisherMatch;
      }).toList();

      // Сортировка
      filteredItems.sort((a, b) {
        if (sortBy == 'title') {
          return sortOrder == 'asc' ? a.title.compareTo(b.title) : b.title.compareTo(a.title);
        } else if (sortBy == 'price') {
          final priceA = double.parse(a.price.replaceAll(' рублей', ''));
          final priceB = double.parse(b.price.replaceAll(' рублей', ''));
          return sortOrder == 'asc' ? priceA.compareTo(priceB) : priceB.compareTo(priceA);
        }
        return 0;
      });
    });
  }

  // Обновление поискового запроса
  void _onSearchQueryChanged(String query) {
    setState(() {
      searchQuery = query;
    });
    _updateFilteredItems();
  }

  // Обновление сортировки
  void _onSortChanged(String sortBy, String sortOrder) {
    setState(() {
      this.sortBy = sortBy;
      this.sortOrder = sortOrder;
    });
    _updateFilteredItems();
  }

  // Обновление фильтров
  void _onFilterChanged(String? publisher, double minPrice, double maxPrice) {
    setState(() {
      selectedPublisher = publisher;
      this.minPrice = minPrice;
      this.maxPrice = maxPrice;
    });
    _updateFilteredItems();
  }

  // Переход на экран добавления нового тома манги
  void _navigateToAddProductScreen(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UploadNewVolumePage(
          onItemCreated: (MangaItem? item) {
            if (item != null) {
              setState(() {
                productItems.add(item);
                _updateFilteredItems();
              });
            }
          },
        ),
      ),
    );

    if (result != null) {
      setState(() {
        productItems.add(result);
        _updateFilteredItems();
      });
    }
  }

  // Управление избранными элементами
  void _toggleFavorite(BuildContext context, int index) {
    final provider = Provider.of<FavoriteProvider>(context, listen: false);
    final product = filteredItems[index];
    if (provider.favoriteItems.contains(product)) {
      provider.removeFromFavorites(product);
    } else {
      provider.addToFavorites(product);
    }
  }

  // Управление корзиной
  void _toggleCart(BuildContext context, int index) {
    final provider = Provider.of<CartProvider>(context, listen: false);
    final product = filteredItems[index];
    if (provider.cartItems.contains(product)) {
      provider.removeFromCart(product);
    } else {
      provider.addToCart(product);
    }
  }

  // Удаление элемента манги
  void _deleteMangaItem(int index) async {
    final product = filteredItems[index];
    try {
      await ApiService().deleteProduct(product.id);
      setState(() {
        productItems.removeWhere((item) => item.id == product.id);
        _updateFilteredItems();
      });
    } catch (e) {
      print('Error deleting product: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final favoriteProvider = Provider.of<FavoriteProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context); // Добавляем CartProvider

    return Scaffold(
      backgroundColor: const Color(0xFF191919),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  _buildHeader(context, isMobile),
                  const SizedBox(height: 20),
                  _buildSearchBar(),
                  const SizedBox(height: 10),
                  _buildSortAndFilterBar(),
                  const SizedBox(height: 20),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: isMobile ? 1 : 2, // Один столбец на мобильных устройствах, два на десктопах
                        childAspectRatio: isMobile ? 1.6 : 2.3, // Соотношение ширины и высоты
                        crossAxisSpacing: 20, // Расстояние между столбцами
                        mainAxisSpacing: 10, // Расстояние между строками
                      ),
                      itemCount: filteredItems.length,
                      itemBuilder: (context, index) {
                        final productItem = filteredItems[index];
                        return _buildMangaCard(context, productItem, index, favoriteProvider, cartProvider);
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // Шапка страницы
  Widget _buildHeader(BuildContext context, bool isMobile) {
    return Align(
      alignment: Alignment.topCenter,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'MANgo100',
            style: TextStyle(
              fontSize: isMobile ? 30.0 : 40.0,
              color: const Color(0xFFECDBBA),
              fontFamily: 'Tektur',
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => _navigateToAddProductScreen(context),
            child: Container(
              width: isMobile ? 24.0 : 40.0,
              height: isMobile ? 24.0 : 40.0,
              decoration: BoxDecoration(
                color: const Color(0xFFC84B31),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.add,
                color: const Color(0xFFECDBBA),
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Виджет для поисковой строки
  Widget _buildSearchBar() {
    return TextField(
      onChanged: _onSearchQueryChanged,
      decoration: InputDecoration(
        hintText: 'Поиск по названию или описанию',
        hintStyle: TextStyle(color: const Color(0xFFECDBBA)),
        prefixIcon: Icon(Icons.search, color: const Color(0xFFECDBBA)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: const Color(0xFFECDBBA)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: const Color(0xFFECDBBA)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: const Color(0xFFC84B31)),
        ),
        filled: true,
        fillColor: const Color(0xFF2D4263),
      ),
      style: TextStyle(color: const Color(0xFFECDBBA)),
    );
  }

  // Виджет для сортировки и фильтрации
  Widget _buildSortAndFilterBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        DropdownButton<String>(
          value: sortBy,
          onChanged: (String? newValue) {
            if (newValue != null) {
              _onSortChanged(newValue, sortOrder);
            }
          },
          items: <String>['title', 'price'].map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value == 'title' ? 'По алфавиту' : 'По цене',
                style: TextStyle(color: const Color(0xFFECDBBA)),
              ),
            );
          }).toList(),
          dropdownColor: const Color(0xFF2D4263),
          style: TextStyle(color: const Color(0xFFECDBBA)),
          icon: Icon(Icons.arrow_drop_down, color: const Color(0xFFECDBBA)),
          underline: Container(height: 1, color: const Color(0xFFECDBBA)),
        ),
        DropdownButton<String>(
          value: sortOrder,
          onChanged: (String? newValue) {
            if (newValue != null) {
              _onSortChanged(sortBy, newValue);
            }
          },
          items: <String>['asc', 'desc'].map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value == 'asc' ? 'От а до я' : 'От я до а',
                style: TextStyle(color: const Color(0xFFECDBBA)),
              ),
            );
          }).toList(),
          dropdownColor: const Color(0xFF2D4263),
          style: TextStyle(color: const Color(0xFFECDBBA)),
          icon: Icon(Icons.arrow_drop_down, color: const Color(0xFFECDBBA)),
          underline: Container(height: 1, color: const Color(0xFFECDBBA)),
        ),
        DropdownButton<String>(
          value: selectedPublisher,
          onChanged: (String? newValue) {
            _onFilterChanged(newValue, minPrice, maxPrice);
          },
          items: <String>['Терлецки комикс', 'Другое'].map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value,
                style: TextStyle(color: const Color(0xFFECDBBA)),
              ),
            );
          }).toList(),
          dropdownColor: const Color(0xFF2D4263),
          style: TextStyle(color: const Color(0xFFECDBBA)),
          icon: Icon(Icons.arrow_drop_down, color: const Color(0xFFECDBBA)),
          underline: Container(height: 1, color: const Color(0xFFECDBBA)),
        ),
        Row(
          children: [
            Text('Цена от:', style: TextStyle(color: const Color(0xFFECDBBA))),
            SizedBox(width: 10),
            DropdownButton<double>(
              value: minPrice,
              onChanged: (double? newValue) {
                if (newValue != null) {
                  _onFilterChanged(selectedPublisher, newValue, maxPrice);
                }
              },
              items: <double>[0, 100, 200, 300, 400, 500].map<DropdownMenuItem<double>>((double value) {
                return DropdownMenuItem<double>(
                  value: value,
                  child: Text(
                    '$value',
                    style: TextStyle(color: const Color(0xFFECDBBA)),
                  ),
                );
              }).toList(),
              dropdownColor: const Color(0xFF2D4263),
              style: TextStyle(color: const Color(0xFFECDBBA)),
              icon: Icon(Icons.arrow_drop_down, color: const Color(0xFFECDBBA)),
              underline: Container(height: 1, color: const Color(0xFFECDBBA)),
            ),
            SizedBox(width: 10),
            Text('до:', style: TextStyle(color: const Color(0xFFECDBBA))),
            SizedBox(width: 10),
            DropdownButton<double>(
              value: maxPrice,
              onChanged: (double? newValue) {
                if (newValue != null) {
                  _onFilterChanged(selectedPublisher, minPrice, newValue);
                }
              },
              items: <double>[100, 200, 300, 400, 500, 1000].map<DropdownMenuItem<double>>((double value) {
                return DropdownMenuItem<double>(
                  value: value,
                  child: Text(
                    '$value',
                    style: TextStyle(color: const Color(0xFFECDBBA)),
                  ),
                );
              }).toList(),
              dropdownColor: const Color(0xFF2D4263),
              style: TextStyle(color: const Color(0xFFECDBBA)),
              icon: Icon(Icons.arrow_drop_down, color: const Color(0xFFECDBBA)),
              underline: Container(height: 1, color: const Color(0xFFECDBBA)),
            ),
          ],
        ),
      ],
    );
  }

  // Карточка манги
  Widget _buildMangaCard(BuildContext context, MangaItem productItem, int index, FavoriteProvider favoriteProvider, CartProvider cartProvider) {
    final screenWidth = MediaQuery.of(context).size.width;
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
              title: productItem.title,
              price: productItem.price,
              index: index,
              additionalImages: productItem.additionalImages,
              description: productItem.description,
              format: productItem.format,
              publisher: productItem.publisher,
              imagePath: productItem.imagePath,
              chapters: productItem.chapters,
              onDelete: () => _deleteMangaItem(index), // Передаем функцию удаления
            ),
          ),
        );

        if (result != null && result is int) {
          _deleteMangaItem(result);
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
                    productItem.imagePath,
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
                          productItem.title,
                          style: TextStyle(
                            fontSize: titleFontSize, // Плавное уменьшение шрифта заголовка
                            color: const Color(0xFF2D4263),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          productItem.description, // Используем полное описание
                          style: TextStyle(
                            fontSize: descriptionFontSize, // Плавное уменьшение шрифта описания
                            color: const Color(0xFF2D4263),
                            fontFamily: 'Tektur',
                          ),
                          maxLines: 1, // Ограничение на количество строк (можно установить на 1)
                          overflow: TextOverflow.ellipsis, // Троеточие при переполнении
                        ),
                        const SizedBox(height: 10),
                        Text(
                          productItem.price,
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
                icon: favoriteProvider.favoriteItems.contains(productItem) ? Icons.favorite : Icons.favorite_border,
                onTap: () => _toggleFavorite(context, index),
              ),
            ),
            Positioned(
              bottom: 8,
              right: 8,
              child: _buildIconButton(
                icon: cartProvider.cartItems.contains(productItem) ? Icons.shopping_cart : Icons.add_shopping_cart,
                onTap: () => _toggleCart(context, index),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Общий стиль для кнопок
  Widget _buildIconButton({required IconData icon, required VoidCallback onTap}) {
    final screenWidth = MediaQuery.of(context).size.width;
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
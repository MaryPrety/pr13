import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../models/manga_item.dart';

class CartProvider with ChangeNotifier {
  List<MangaItem> _cartItems = [];
  Map<MangaItem, int> _itemQuantities = {};
  final Dio _dio = Dio(); // Инициализация Dio для работы с API
  final String _baseUrl = 'http://localhost:8080/mangaItems'; // Укажите URL вашего API

  List<MangaItem> get cartItems => _cartItems;

  Future<void> addToCart(MangaItem item) async {
    if (_cartItems.contains(item)) {
      _itemQuantities[item] = _itemQuantities[item]! + 1;
    } else {
      _cartItems.add(item);
      _itemQuantities[item] = 1;

      // Отправка запроса на сервер для добавления товара в корзину
      await _addItemToCartAPI(item);
    }
    notifyListeners();
  }

  Future<void> removeFromCart(MangaItem item) async {
    _cartItems.remove(item);
    _itemQuantities.remove(item);

    // Отправка запроса на сервер для удаления товара из корзины
    await _removeItemFromCartAPI(item);
    notifyListeners();
  }

  Future<void> increaseQuantity(MangaItem item) async {
    if (_cartItems.contains(item)) {
      _itemQuantities[item] = _itemQuantities[item]! + 1;

      // Обновление количества на сервере
      await _updateItemQuantityAPI(item, _itemQuantities[item]!);
      notifyListeners();
    }
  }

  Future<void> decreaseQuantity(MangaItem item) async {
    if (_cartItems.contains(item) && _itemQuantities[item]! > 1) {
      _itemQuantities[item] = _itemQuantities[item]! - 1;

      // Обновление количества на сервере
      await _updateItemQuantityAPI(item, _itemQuantities[item]!);
      notifyListeners();
    }
  }

  int getItemQuantity(MangaItem item) {
    return _itemQuantities[item] ?? 0;
  }

  // Метод для очистки корзины
  Future<void> clearCart() async {
    _cartItems.clear();
    _itemQuantities.clear();
    
    // Отправка запроса на сервер для очистки корзины, если требуется
    await _clearCartAPI();
    
    notifyListeners();
  }

  // Приватные методы для работы с API
  Future<void> _addItemToCartAPI(MangaItem item) async {
    try {
      await _dio.post('$_baseUrl/cart', data: {
        'itemId': item.id, // Убедитесь, что у вашего объекта есть id
        'quantity': 1,
      });
    } catch (e) {
      // Обработка ошибок
      print('Error adding item to cart: $e');
    }
  }

  Future<void> _removeItemFromCartAPI(MangaItem item) async {
    try {
      await _dio.delete('$_baseUrl/cart/${item.id}');
    } catch (e) {
      // Обработка ошибок
      print('Error removing item from cart: $e');
    }
  }

  Future<void> _updateItemQuantityAPI(MangaItem item, int quantity) async {
    try {
      await _dio.put('$_baseUrl/cart/${item.id}', data: {
        'quantity': quantity,
      });
    } catch (e) {
      // Обработка ошибок
      print('Error updating item quantity: $e');
    }
  }

  Future<void> _clearCartAPI() async {
    try {
      await _dio.delete('$_baseUrl/cart');
    } catch (e) {
      // Обработка ошибок
      print('Error clearing cart: $e');
    }
  }
}
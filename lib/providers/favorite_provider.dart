import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../models/manga_item.dart';

class FavoriteProvider with ChangeNotifier {
  List<MangaItem> _favoriteItems = [];
  final Dio _dio = Dio(); // Инициализация Dio для работы с API
  final String _baseUrl = 'http://localhost:8080/mangaItems'; // Укажите URL вашего API

  List<MangaItem> get favoriteItems => _favoriteItems;

  Future<void> addToFavorites(MangaItem item) async {
    if (!_favoriteItems.contains(item)) {
      _favoriteItems.add(item);
      
      // Отправка запроса на сервер для добавления товара в избранное
      await _addItemToFavoritesAPI(item);
      notifyListeners();
    }
  }

  Future<void> removeFromFavorites(MangaItem item) async {
    _favoriteItems.remove(item);
    
    // Отправка запроса на сервер для удаления товара из избранного
    await _removeItemFromFavoritesAPI(item);
    notifyListeners();
  }

  bool isFavorite(MangaItem item) {
    return _favoriteItems.contains(item);
  }

  // Приватные методы для работы с API
  Future<void> _addItemToFavoritesAPI(MangaItem item) async {
    try {
      await _dio.post('$_baseUrl/favorites', data: {
        'itemId': item.id, // Убедитесь, что у вашего объекта есть id
      });
    } catch (e) {
      // Обработка ошибок
      print('Error adding item to favorites: $e');
    }
  }

  Future<void> _removeItemFromFavoritesAPI(MangaItem item) async {
    try {
      await _dio.delete('$_baseUrl/favorites/${item.id}');
    } catch (e) {
      // Обработка ошибок
      print('Error removing item from favorites: $e');
    }
  }
}
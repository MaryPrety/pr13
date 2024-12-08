import 'package:dio/dio.dart';
import '../models/manga_item.dart';

class ApiService {
  final Dio _dio = Dio();
  static const String baseUrl = 'http://localhost:8080'; // Ваш серверный URL

  // Метод для получения всех манга-товаров
  Future<List<MangaItem>> fetchProducts() async {
    try {
      final response = await _dio.get('$baseUrl/mangaItems');
      if (response.statusCode == 200) {
        List<MangaItem> products = (response.data as List)
            .map((item) => MangaItem.fromJson(item))
            .toList();
        return products;
      } else {
        throw Exception('Failed to load products: ${response.statusCode} - ${response.data}');
      }
    } catch (e) {
      print('Error fetching products: $e');
      throw Exception('Error fetching products: $e');
    }
  }

  // Метод для изменения статуса манга-товара через PUT
  Future<void> changeProductStatus(MangaItem mangaItem) async {
    print("changeProductStatus function called");
    try {
      final response = await _dio.put(
        '$baseUrl/mangaItems/update/${mangaItem.id}',
        data: mangaItem.toJson(),
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      print(response.statusCode);
      if (response.statusCode == 200) {
        return;
      } else {
        throw Exception('Failed to change Product Status: ${response.statusCode} - ${response.data}');
      }
    } catch (e) {
      throw Exception('Error fetching change Product Status: $e');
    }
  }

  // Метод для создания нового манга-товара
  Future<MangaItem> createProduct(MangaItem item) async {
    try {
      final response = await _dio.post(
        '$baseUrl/mangaItems/create', // Путь для создания
        data: item.toJson(),
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
      if (response.statusCode == 201) {
        return MangaItem.fromJson(response.data);
      } else {
        throw Exception('Failed to create product: ${response.statusCode} - ${response.data}');
      }
    } catch (e) {
      throw Exception('Error creating product: $e');
    }
  }

  // Метод для удаления манга-товара
  Future<void> deleteProduct(int id) async {
    try {
      final response = await _dio.delete('$baseUrl/mangaItems/delete/$id'); // Путь для удаления
      if (response.statusCode != 204) {
        throw Exception('Failed to delete product: ${response.statusCode} - ${response.data}');
      }
    } catch (e) {
      throw Exception('Error deleting product: $e');
    }
  }
}
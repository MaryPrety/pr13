import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../models/manga_item.dart';
import '../services/api_service.dart';

// Константы для цветов и размеров
const Color primaryColor = Color(0xFFC84B31);
const Color secondaryColor = Color(0xFFECDBBA);
const Color textColor = Color(0xFF56423D);
const Color backgroundColor = Color(0xFF191919);

class UploadNewVolumePage extends StatefulWidget {
  final ValueChanged<MangaItem?> onItemCreated;

  const UploadNewVolumePage({Key? key, required this.onItemCreated}) : super(key: key);

  @override
  _UploadNewVolumePageState createState() => _UploadNewVolumePageState();
}

class _UploadNewVolumePageState extends State<UploadNewVolumePage> {
  final TextEditingController _volumeController = TextEditingController();
  final TextEditingController _chaptersController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _fullDescriptionController = TextEditingController();
  final TextEditingController _formatController = TextEditingController();
  final TextEditingController _publisherController = TextEditingController();
  final List<String> _imageLinks = [];
  bool _isSubmitting = false;

  final List<String> formatTexts = [
    'Твердый переплет\nФормат издания 19.6 x 12.5 см\nкол-во стр от 380 до 400',
    'Мягкий переплет\nФормат издания 18.0 x 11.0 см\nкол-во стр от 350 до 370',
    'Электронная версия\nФормат издания 19.6 x 12.5 см\nкол-во стр от 380 до 400',
  ];

  final List<String> publisherTexts = [
    'Издательство Терлецки Комикс',
    'Издательство Другое Комикс',
    'Издательство Еще Комикс',
    'Alt Graph',
  ];

  // Метод для добавления изображения
  void _addImage() {
    if (_imageLinks.length < 3) {
      showDialog(
        context: context,
        builder: (context) {
          TextEditingController _urlController = TextEditingController();
          return AlertDialog(
            title: const Text("Добавить изображение"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _urlController,
                  decoration: const InputDecoration(labelText: "Введите ссылку на изображение"),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Пример ссылки: https://example.com/image.jpg",
                  style: TextStyle(color: primaryColor, fontSize: 12),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  String url = _urlController.text.trim();
                  if (url.isNotEmpty && url.startsWith("http")) {
                    setState(() {
                      _imageLinks.add(url);
                      Navigator.of(context).pop();
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Введите корректную ссылку на изображение")),
                    );
                  }
                },
                child: const Text("Добавить"),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("Отмена"),
              ),
            ],
          );
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Максимум 3 изображения")),
      );
    }
  }

  // Метод валидации
  bool _validateInputs() {
    return _volumeController.text.isNotEmpty &&
           _chaptersController.text.isNotEmpty &&
           _priceController.text.isNotEmpty &&
           _fullDescriptionController.text.isNotEmpty &&
           _formatController.text.isNotEmpty &&
           _publisherController.text.isNotEmpty &&
           _imageLinks.length == 3;
  }

  // Метод отправки формы
  Future<void> _submit() async {
    if (_validateInputs()) {
      setState(() => _isSubmitting = true);
      final newMangaItem = MangaItem(
        id: 0, 
        imagePath: _imageLinks[0],
        title: _volumeController.text,
        description: _fullDescriptionController.text,
        price: _priceController.text,
        additionalImages: _imageLinks.sublist(1),
        format: _formatController.text,
        publisher: _publisherController.text,
        chapters: _chaptersController.text,
      );

      try {
        // Проверка на существование товара с тем же названием
        final existingProducts = await ApiService().fetchProducts();
        if (existingProducts.any((product) => product.title == newMangaItem.title)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Товар с таким названием уже существует")),
          );
          return;
        }

        // Создание товара
        final createdItem = await ApiService().createProduct(newMangaItem);
        widget.onItemCreated(createdItem); // Только вызываем onItemCreated
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка при создании товара: $error')),
        );
      } finally {
        setState(() => _isSubmitting = false);
        Navigator.pop(context); // Только закрываем экран без передачи данных
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Пожалуйста, заполните все поля и добавьте ровно 3 изображения")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text("Добавить новый том"),
        backgroundColor: primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isSubmitting
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      "MANgo100+",
                      style: TextStyle(color: primaryColor, fontSize: 36, fontFamily: 'Russo One'),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    _buildInputField('Какой том', _volumeController, hintText: 'Например, Том 1'),
                    const SizedBox(height: 15),
                    _buildInputField('Главы', _chaptersController, hintText: 'Например, № глав: 1-36 + дополнительные истории'),
                    const SizedBox(height: 15),
                    _buildInputField('Цена', _priceController, hintText: 'Например, 100 рублей', keyboardType: TextInputType.number),
                    const SizedBox(height: 15),
                    _buildDropdownField('Формат издания', _formatController, formatTexts),
                    const SizedBox(height: 15),
                    _buildDropdownField('Издательство', _publisherController, publisherTexts),
                    const SizedBox(height: 15),
                    _buildInputField('Описание', _fullDescriptionController, hintText: 'Напишите описание', maxLines: 5),
                    const SizedBox(height: 15),
                    _buildImageSelection(),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text("Добавить", style: TextStyle(fontSize: 20)),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, {String? hintText, int maxLines = 1, TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        filled: true,
        fillColor: secondaryColor,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildDropdownField(String label, TextEditingController controller, List<String> items) {
    return DropdownButtonFormField<String>(
      value: controller.text.isEmpty ? null : controller.text,
      onChanged: (value) {
        setState(() {
          controller.text = value ?? '';
        });
      },
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: secondaryColor,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
    );
  }

  Widget _buildImageSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Первая картинка пойдет на обложку, остальные две как вспомогательные.",
          style: TextStyle(color: textColor),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            for (int i = 0; i < _imageLinks.length; i++) ...[
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Stack(
                  children: [
                    Image.network(
                      _imageLinks[i],
                      height: 50,
                      width: 50,
                      fit: BoxFit.cover,
                    ),
                    Positioned.fill(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _imageLinks.removeAt(i);
                            });
                          },
                          child: const Center(
                            child: Icon(Icons.close, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            IconButton(
              icon: const Icon(Icons.add_a_photo, color: primaryColor),
              onPressed: _addImage,
            ),
          ],
        ),
      ],
    );
  }
}
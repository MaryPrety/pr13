class MangaItem {
  final int id;
  final String imagePath;
  final String title;
  final String description;
  final String price;
  final List<String> additionalImages;
  final String format;
  final String publisher;
  final String chapters;

  MangaItem({
    required this.id,
    required this.imagePath,
    required this.title,
    required this.description,
    required this.price,
    required this.additionalImages,
    required this.format,
    required this.publisher,
    required this.chapters,
  });

  factory MangaItem.fromJson(Map<String, dynamic> json) {
    return MangaItem(
      id: json['id'] is int ? json['id'] : 0,
      imagePath: json['image_path'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      price: json['price']?.toString() ?? '',
      additionalImages: json['additional_images'] != null 
          ? List<String>.from(json['additional_images'])
          : [],
      format: json['format'] ?? 'Не указан',
      publisher: json['publisher'] ?? 'Не указан',
      chapters: json['chapters']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image_path': imagePath,
      'title': title,
      'description': description,
      'price': price,
      'additional_images': additionalImages,
      'format': format.isNotEmpty ? format : 'Не указан',
      'publisher': publisher.isNotEmpty ? publisher : 'Не указан',
      'chapters': chapters,
    };
  }
}

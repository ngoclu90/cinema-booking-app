class NewsItem {
  final String id;
  final String title;
  final String description;
  final String dateLabel;
  final String category;
  final String imageUrl;

  const NewsItem({
    required this.id,
    required this.title,
    required this.description,
    required this.dateLabel,
    required this.category,
    required this.imageUrl,
  });

  factory NewsItem.fromJson(Map<String, dynamic> json) {
    return NewsItem(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      dateLabel: json['dateLabel']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dateLabel': dateLabel,
      'category': category,
      'imageUrl': imageUrl,
    };
  }
}

class NewsItem {
  final int id;
  final String title;
  final String slug;
  final String excerpt;
  final String content;
  final String category;
  final String coverUrl;
  final int published;
  final String? publishedAt;
  final String? createdAt;

  const NewsItem({
    required this.id,
    required this.title,
    required this.slug,
    required this.excerpt,
    required this.content,
    required this.category,
    required this.coverUrl,
    required this.published,
    this.publishedAt,
    this.createdAt,
  });

  factory NewsItem.fromJson(Map<String, dynamic> json) {
    return NewsItem(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      title: json['title']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      excerpt: json['excerpt']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      coverUrl: json['coverUrl']?.toString() ?? '',
      published: json['published'] is int
          ? json['published']
          : int.tryParse(json['published']?.toString() ?? '0') ?? 0,
      publishedAt: json['publishedAt']?.toString(),
      createdAt: json['createdAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'slug': slug,
    'excerpt': excerpt,
    'content': content,
    'category': category,
    'coverUrl': coverUrl,
    'published': published,
    'publishedAt': publishedAt,
    'createdAt': createdAt,
  };

  String get description => excerpt;

  String get imageUrl => coverUrl;

  String get dateLabel {
    if (publishedAt != null && publishedAt!.trim().isNotEmpty) {
      return publishedAt!.split('T').first;
    }
    if (createdAt != null && createdAt!.trim().isNotEmpty) {
      return createdAt!.split('T').first;
    }
    return 'Mới cập nhật';
  }
}
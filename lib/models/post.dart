import 'package:flutter/cupertino.dart';

class Post{
  final int id;
  final String title;
  final String slug;
  final String excerpt;
  final String content;
  final String category;
  final String coverUrl;
  final DateTime? publishedAt;
  const Post ({
    required this.id,
    required this.title,
    required this.slug,
    required this.excerpt,
    required this.content,
    required this.category,
    required this.coverUrl,
    required this.publishedAt,
  });
  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['title']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      excerpt: json['excerpt']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      coverUrl: json['coverUrl']?.toString() ?? '',
      publishedAt: json['publishedAt'] != null
          ? DateTime.tryParse(json['publishedAt'].toString())
          : null,
    );
  }

}
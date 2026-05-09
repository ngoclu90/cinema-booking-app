import 'package:flutter/material.dart';

class MoviePublicDto {
  final int id;
  final String title;
  final String? shortDescription;
  final String? description;
  final int durationMinutes;
  final String? genre;
  final String? language;
  final String? format;
  final String? director;
  final String? cast;
  final String? posterUrl;
  final String? bannerUrl;
  final String? trailerUrl;
  final String? ageRating;
  final DateTime? releaseDate;
  final String? status;

  MoviePublicDto({
    required this.id,
    required this.title,
    this.shortDescription,
    this.description,
    required this.durationMinutes,
    this.genre,
    this.language,
    this.format,
    this.director,
    this.cast,
    this.posterUrl,
    this.bannerUrl,
    this.trailerUrl,
    this.ageRating,
    this.releaseDate,
    this.status,
  });

  // GHI ĐÈ: Factory này phải khớp chính xác KEY trong JSON của Spring Boot
  factory MoviePublicDto.fromJson(Map<String, dynamic> json) {
    return MoviePublicDto(
      id: json['id'] as int? ?? 0,
      title: json['title'] ?? '',
      shortDescription: json['shortDescription'],
      description: json['description'],
      durationMinutes: json['durationMinutes'] as int? ?? 0,
      genre: json['genre']?.toString(),
      language: json['language'],
      format: json['format'],
      director: json['director'],
      cast: json['cast'],
      posterUrl: json['posterUrl'],
      bannerUrl: json['bannerUrl'],
      trailerUrl: json['trailerUrl'],
      ageRating: json['agerating'], // Backend đặt là 'agerating'
      releaseDate: json['releaseDate'] != null
          ? DateTime.tryParse(json['releaseDate'].toString())
          : null,
      status: json['status']?.toString(),
    );
  }

  // CÁC TIỆN ÍCH DÀNH CHO UI (Helper Getters)

  // Format thời lượng: 120 -> "2h 00m"
  String get durationFormatted {
    final hours = durationMinutes ~/ 60;
    final minutes = durationMinutes % 60;
    return '${hours}h ${minutes.toString().padLeft(2, '0')}m';
  }

  // Tự tạo màu chủ đạo giả lập nếu backend không trả về
  Color get accentColor => _getCategoryColor(genre ?? '');

  Color _getCategoryColor(String genre) {
    if (genre.contains('ACTION')) return Colors.redAccent;
    if (genre.contains('COMEDY')) return Colors.orangeAccent;
    return const Color(0xFFE12636); // Mặc định
  }
}
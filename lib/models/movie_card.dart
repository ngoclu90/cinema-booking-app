import 'package:flutter/material.dart';
import 'movie.dart';

/*
 * Lớp MovieCardDto:
 * Ánh xạ chính xác cấu trúc DTO 'MovieCardtos' từ Spring Boot Backend.
 * Dùng để hiển thị danh sách phim rút gọn ở màn hình Trang chủ (Home) và Danh sách (Browse).
 */
class MovieCardDto {
  final int id;
  final String title;
  final int durationMinutes;
  final String? genre;
  final String? posterUrl;
  final String? status;
  final DateTime? releaseDate;

  MovieCardDto({
    required this.id,
    required this.title,
    required this.durationMinutes,
    this.genre,
    this.posterUrl,
    this.status,
    this.releaseDate,
  });

  /*
   * Helper: Chuyển đổi thời lượng sang định dạng hiển thị (Ví dụ: 166 -> "2h 46m")
   */
  String get durationFormatted {
    final hours = durationMinutes ~/ 60;
    final minutes = durationMinutes % 60;
    return '${hours}h ${minutes.toString().padLeft(2, '0')}m';
  }

  /*
   * Helper: Ánh xạ nhanh (Map) sang MoviePublicDto để truyền dữ liệu mượt mà
   * sang màn hình Chi tiết (MovieDetailScreen) mà không bị lệch kiểu dữ liệu.
   */
  MoviePublicDto toPublicDto() {
    return MoviePublicDto(
      id: id,
      title: title,
      durationMinutes: durationMinutes,
      genre: genre,
      posterUrl: posterUrl,
      status: status,
      releaseDate: releaseDate,
    );
  }

  factory MovieCardDto.fromJson(Map<String, dynamic> json) {
    return MovieCardDto(
      id: json['id'] as int? ?? 0,
      title: json['title']?.toString() ?? '',
      durationMinutes: json['durationMinutes'] as int? ?? 0,
      genre: json['genre']?.toString(),
      posterUrl: json['posterUrl']?.toString(),
      status: json['status']?.toString(),
      releaseDate: json['releaseDate'] != null
          ? DateTime.tryParse(json['releaseDate'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'durationMinutes': durationMinutes,
      'genre': genre,
      'posterUrl': posterUrl,
      'status': status,
      'releaseDate': releaseDate?.toIso8601String(),
    };
  }
}
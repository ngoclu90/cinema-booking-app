import 'package:flutter/material.dart';

import 'showtime.dart';

class Movie {
  final String id;
  final String title;
  final String genre;
  final String duration;
  final double rating;
  final String description;
  final String detailLabel;
  final String headline;
  final String director;
  final String language;
  final String releaseDate;
  final String bookingHint;
  final int accentValue;
  final List<String> tags;
  final List<String> formats;
  final List<Showtime> showtimes;
  final String status;

  Color get accent => Color(accentValue);

  const Movie({
    required this.id,
    required this.title,
    required this.genre,
    required this.duration,
    required this.rating,
    required this.description,
    required this.detailLabel,
    required this.headline,
    required this.director,
    required this.language,
    required this.releaseDate,
    required this.bookingHint,
    required this.accentValue,
    required this.tags,
    required this.formats,
    required this.showtimes,
    required this.status,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      genre: json['genre']?.toString() ?? '',
      duration: json['duration']?.toString() ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      description: json['description']?.toString() ?? '',
      detailLabel: json['detailLabel']?.toString() ?? '',
      headline: json['headline']?.toString() ?? '',
      director: json['director']?.toString() ?? '',
      language: json['language']?.toString() ?? '',
      releaseDate: json['releaseDate']?.toString() ?? '',
      bookingHint: json['bookingHint']?.toString() ?? '',
      accentValue: (json['accentValue'] as num?)?.toInt() ?? 0xFFE12636,
      tags: _stringList(json['tags']),
      formats: _stringList(json['formats']),
      showtimes: (json['showtimes'] as List<dynamic>? ?? const [])
          .map(
            (showtime) =>
                Showtime.fromJson(Map<String, dynamic>.from(showtime as Map)),
          )
          .toList(growable: false),
      status: json['status']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'genre': genre,
      'duration': duration,
      'rating': rating,
      'description': description,
      'detailLabel': detailLabel,
      'headline': headline,
      'director': director,
      'language': language,
      'releaseDate': releaseDate,
      'bookingHint': bookingHint,
      'accentValue': accentValue,
      'tags': tags,
      'formats': formats,
      'showtimes': showtimes
          .map((showtime) => showtime.toJson())
          .toList(growable: false),
      'status': status,
    };
  }

  static List<String> _stringList(dynamic value) {
    return (value as List<dynamic>? ?? const [])
        .map((item) => item.toString())
        .toList(growable: false);
  }
}

import 'package:flutter/material.dart';

class Cinema {
  final String id;
  final String name;
  final String address;
  final String status;
  final String distance;
  final int halls;
  final String phone;
  final String landmark;
  final String operatingHours;
  final int accentValue;
  final List<String> facilities;

  Color get accent => Color(accentValue);

  const Cinema({
    required this.id,
    required this.name,
    required this.address,
    required this.status,
    required this.distance,
    required this.halls,
    required this.phone,
    required this.landmark,
    required this.operatingHours,
    required this.accentValue,
    required this.facilities,
  });

  factory Cinema.fromJson(Map<String, dynamic> json) {
    return Cinema(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      distance: json['distance']?.toString() ?? '',
      halls: (json['halls'] as num?)?.toInt() ?? 0,
      phone: json['phone']?.toString() ?? '',
      landmark: json['landmark']?.toString() ?? '',
      operatingHours: json['operatingHours']?.toString() ?? '',
      accentValue: (json['accentValue'] as num?)?.toInt() ?? 0xFFE12636,
      facilities: (json['facilities'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList(growable: false),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'status': status,
      'distance': distance,
      'halls': halls,
      'phone': phone,
      'landmark': landmark,
      'operatingHours': operatingHours,
      'accentValue': accentValue,
      'facilities': facilities,
    };
  }
}

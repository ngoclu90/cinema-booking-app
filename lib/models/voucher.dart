class Voucher {
  final String id;
  final String title;
  final String description;
  final String expiryLabel;
  final String category;
  final String code;
  final String imageUrl;

  const Voucher({
    required this.id,
    required this.title,
    required this.description,
    required this.expiryLabel,
    required this.category,
    required this.code,
    required this.imageUrl,
  });

  factory Voucher.fromJson(Map<String, dynamic> json) {
    return Voucher(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      expiryLabel: json['expiryLabel']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'expiryLabel': expiryLabel,
      'category': category,
      'code': code,
      'imageUrl': imageUrl,
    };
  }
}

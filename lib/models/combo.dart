class ComboItem {
  final int id;
  final int productId;
  final String productName;
  final int quantity;
  final int price;
  final String imageUrl;

  const ComboItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
    required this.imageUrl,
  });

  factory ComboItem.fromJson(Map<String, dynamic> json) {
    return ComboItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      productId: (json['productId'] as num?)?.toInt() ?? 0,
      productName: json['productName']?.toString() ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      price: (json['price'] as num?)?.toInt() ?? 0,
      imageUrl: (json['imageUrl'] ?? json['image_url'])?.toString() ?? '',
    );
  }
}

class Combo {
  final int id;
  final String name;
  final String description;
  final int price;
  final String imageUrl;
  final int stock;
  final bool isActive;
  final String type;
  final List<ComboItem> itemList;

  const Combo({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.stock,
    required this.isActive,
    required this.type,
    required this.itemList,
  });

  factory Combo.fromJson(Map<String, dynamic> json) {
    final rawItems = json['itemList'] as List<dynamic>? ?? const [];
    return Combo(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      price: (json['price'] as num?)?.toInt() ?? 0,
      imageUrl: json['imageUrl']?.toString() ?? '',
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      isActive: (json['isActive'] as num?)?.toInt() == 1,
      type: json['type']?.toString() ?? '',
      itemList: rawItems
          .map((item) => ComboItem.fromJson(item as Map<String, dynamic>))
          .toList(growable: false),
    );
  }
}

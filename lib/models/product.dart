class Product {
  final int id;
  final int empresaId;
  final String name;
  final String? description;
  final double price;
  final int stock;
  final bool isActive;
  final double? avgRating;
  final int reviewsCount;

  Product({
    required this.id,
    required this.empresaId,
    required this.name,
    this.description,
    required this.price,
    required this.stock,
    required this.isActive,
    this.avgRating,
    required this.reviewsCount,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      empresaId: json['empresaId'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      price: (json['price'] as num).toDouble(),
      stock: json['stock'] as int,
      isActive: json['isActive'] as bool,
      avgRating: json['avgRating'] != null ? (json['avgRating'] as num).toDouble() : null,
      reviewsCount: json['reviewsCount'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'empresaId': empresaId,
      'name': name,
      'description': description,
      'price': price,
      'stock': stock,
      'isActive': isActive,
      'avgRating': avgRating,
      'reviewsCount': reviewsCount,
    };
  }
}

class ProductCreateDto {
  final String name;
  final String? description;
  final double price;
  final int stock;

  ProductCreateDto({
    required this.name,
    this.description,
    required this.price,
    required this.stock,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'stock': stock,
    };
  }
}

class ProductUpdateDto {
  final String name;
  final String? description;
  final double price;
  final int stock;
  final bool? isActive;

  ProductUpdateDto({
    required this.name,
    this.description,
    required this.price,
    required this.stock,
    this.isActive,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'stock': stock,
      'isActive': isActive,
    };
  }
}

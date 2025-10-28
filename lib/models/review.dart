class Review {
  final int id;
  final int clienteId;
  final int productId;
  final int rating;
  final String? comment;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.clienteId,
    required this.productId,
    required this.rating,
    this.comment,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] as int,
      clienteId: json['clienteId'] as int,
      productId: json['productId'] as int,
      rating: json['rating'] as int,
      comment: json['comment'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

class CreateReviewDto {
  final int rating;
  final String? comment;

  CreateReviewDto({
    required this.rating,
    this.comment,
  });

  Map<String, dynamic> toJson() {
    return {
      'rating': rating,
      'comment': comment,
    };
  }
}

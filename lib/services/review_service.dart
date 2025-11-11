import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:javier/models/review.dart';

class ReviewService {
  final String baseUrl;

  ReviewService({required this.baseUrl});

  // Obtener todas las reseñas de un producto
  Future<List<Review>> getReviews(int productId) async {
    final url = Uri.parse('$baseUrl/api/reviews/product/$productId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List jsonList = json.decode(response.body) as List;
      return jsonList
          .map((e) => Review.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Error al obtener las reseñas (${response.statusCode})');
    }
  }

  // Crear una reseña
  Future<bool> createReview(int productId, CreateReviewDto dto, String token) async {
    if (token.isEmpty) throw Exception('Token inválido o vacío');

    final url = Uri.parse('$baseUrl/api/reviews/product/$productId');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(dto.toJson()),
    );

    if (response.statusCode == 201) {
      return true;
    } else {
      print('Error al crear reseña: ${response.body}');
      return false;
    }
  }
}

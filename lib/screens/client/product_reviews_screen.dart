import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:javier/models/review.dart';
import '../../services/review_service.dart';

class ProductReviewsScreen extends StatefulWidget {
  final int productId;
  final String productName;

  const ProductReviewsScreen({
    super.key,
    required this.productId,
    required this.productName,
  });

  @override
  State<ProductReviewsScreen> createState() => _ProductReviewsScreenState();
}

class _ProductReviewsScreenState extends State<ProductReviewsScreen> {
  final ReviewService reviewService =
      ReviewService(baseUrl: 'https://app-251029165220.azurewebsites.net');
  final TextEditingController _commentController = TextEditingController();
  int _rating = 0;
  bool _loading = true;
  List<Review> _reviews = [];

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    try {
      final data = await reviewService.getReviews(widget.productId);
      setState(() {
        _reviews = data;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar reseñas: $e')),
      );
    }
  }

  Future<void> _submitReview() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona una calificación')),
      );
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes iniciar sesión para opinar.')),
      );
      return;
    }

    final dto = CreateReviewDto(
      rating: _rating,
      comment: _commentController.text.trim().isEmpty
          ? null
          : _commentController.text.trim(),
    );

    bool ok = await reviewService.createReview(widget.productId, dto, token);

    if (ok) {
      _commentController.clear();
      setState(() => _rating = 0);
      _loadReviews();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reseña enviada con éxito ✅')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al enviar reseña ❌')),
      );
    }
  }

  Widget _buildStarRating() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (i) {
        return IconButton(
          icon: Icon(
            i < _rating ? Icons.star : Icons.star_border,
            color: Colors.amber,
            size: 32,
          ),
          onPressed: () => setState(() => _rating = i + 1),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Opiniones: ${widget.productName}')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: _reviews.isEmpty
                      ? const Center(
                          child: Text('No hay reseñas aún. ¡Sé el primero!'))
                      : ListView.builder(
                          itemCount: _reviews.length,
                          itemBuilder: (context, i) {
                            final r = _reviews[i];
                            return ListTile(
                              title: Text(
                                '⭐ ${r.rating}/5',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (r.comment != null)
                                    Text(r.comment!,
                                        style:
                                            const TextStyle(color: Colors.grey)),
                                  Text(
                                    'Fecha: ${r.createdAt.toLocal()}'
                                        .split(' ')[0],
                                    style:
                                        const TextStyle(color: Colors.black54),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      const Text('Deja tu calificación:',
                          style: TextStyle(fontSize: 16)),
                      _buildStarRating(),
                      TextField(
                        controller: _commentController,
                        decoration: const InputDecoration(
                          hintText: 'Escribe un comentario (opcional)',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.send),
                        label: const Text('Enviar reseña'),
                        onPressed: _submitReview,
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../../providers/product_provider.dart';
import '../../providers/cart_provider.dart';
import '../../models/product.dart';
import '../../models/review.dart';
import '../../services/api_service.dart';

class ProductDetailScreen extends StatefulWidget {
  final int productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  Product? _product;
  List<Review> _reviews = [];
  bool _isLoading = true;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  Future<void> _loadProduct() async {
    setState(() => _isLoading = true);
    try {
      final apiService = ApiService();
      final product = await apiService.getProductById(widget.productId);
      final reviews = await apiService.getProductReviews(widget.productId);
      
      setState(() {
        _product = product;
        _reviews = reviews;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _addToCart() {
    if (_product != null && _quantity <= _product!.stock) {
      context.read<CartProvider>().addItem(_product!, _quantity);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Producto agregado al carrito'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Producto'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _product == null
              ? const Center(child: Text('Producto no encontrado'))
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 250,
                        color: Colors.grey[200],
                        child: const Icon(
                          Icons.shopping_bag,
                          size: 120,
                          color: Colors.grey,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _product!.name,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '\$${_product!.price.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple,
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (_product!.avgRating != null)
                              Row(
                                children: [
                                  RatingBarIndicator(
                                    rating: _product!.avgRating!,
                                    itemBuilder: (context, index) => const Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                    ),
                                    itemCount: 5,
                                    itemSize: 20.0,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${_product!.avgRating!.toStringAsFixed(1)} (${_product!.reviewsCount} reseñas)',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                            const SizedBox(height: 16),
                            Text(
                              'Stock disponible: ${_product!.stock}',
                              style: TextStyle(
                                fontSize: 16,
                                color: _product!.stock > 0 ? Colors.green : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Descripción',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _product!.description ?? 'Sin descripción',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 24),
                            if (_product!.stock > 0) ...[
                              Row(
                                children: [
                                  const Text(
                                    'Cantidad:',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  IconButton(
                                    onPressed: () {
                                      if (_quantity > 1) {
                                        setState(() => _quantity--);
                                      }
                                    },
                                    icon: const Icon(Icons.remove_circle_outline),
                                  ),
                                  Text(
                                    '$_quantity',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      if (_quantity < _product!.stock) {
                                        setState(() => _quantity++);
                                      }
                                    },
                                    icon: const Icon(Icons.add_circle_outline),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton.icon(
                                  onPressed: _addToCart,
                                  icon: const Icon(Icons.shopping_cart),
                                  label: const Text('Agregar al Carrito'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.deepPurple,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(height: 32),
                            const Text(
                              'Reseñas',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            if (_reviews.isEmpty)
                              const Text('No hay reseñas aún')
                            else
                              ..._reviews.map((review) => Card(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              RatingBarIndicator(
                                                rating: review.rating.toDouble(),
                                                itemBuilder: (context, index) => const Icon(
                                                  Icons.star,
                                                  color: Colors.amber,
                                                ),
                                                itemCount: 5,
                                                itemSize: 16.0,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                review.createdAt.toString().substring(0, 10),
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                          if (review.comment != null) ...[
                                            const SizedBox(height: 8),
                                            Text(review.comment!),
                                          ],
                                        ],
                                      ),
                                    ),
                                  )),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}

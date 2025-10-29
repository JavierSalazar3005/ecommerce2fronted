import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/auth_response.dart';
import '../models/product.dart';
import '../models/order.dart';
import '../models/review.dart';
import '../models/role.dart';
import '../models/order_status.dart';

class ApiService {
  // URL base SIN barra final
  static const String baseUrl = 'https://app-251028002251.azurewebsites.net';

  String? _token;

  void setToken(String? token) {
    _token = token;
  }

  Map<String, String> _getHeaders({bool includeAuth = true}) {
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (includeAuth && _token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  // ---------- Helpers ----------
  bool _isOk(int code) => code >= 200 && code < 300;

  // AUTH ENDPOINTS
  Future<AuthResponse> register({
    required String email,
    required String password,
    required Role role,
    String? companyName,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/Auth/register'),
      headers: _getHeaders(includeAuth: false),
      body: jsonEncode({
        'email': email,
        'password': password,
        'role': role.value,
        'companyName': companyName,
      }),
    );

    if (_isOk(response.statusCode)) {
      return AuthResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(
        'Error al registrar (${response.statusCode}): ${response.body}',
      );
    }
  }

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/Auth/login'),
      headers: _getHeaders(includeAuth: false),
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (_isOk(response.statusCode)) {
      return AuthResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(
        'Error al iniciar sesión (${response.statusCode}): ${response.body}',
      );
    }
  }

  // CATALOG ENDPOINTS (Public)
  Future<List<Product>> getProducts({
    int? empresaId,
    double? precioMin,
    double? precioMax,
    String? query,
  }) async {
    final queryParams = <String, String>{};
    if (empresaId != null) queryParams['empresaId'] = empresaId.toString();
    if (precioMin != null) queryParams['precioMin'] = precioMin.toString();
    if (precioMax != null) queryParams['precioMax'] = precioMax.toString();
    if (query != null) queryParams['q'] = query;

    final uri = Uri.parse(
      '$baseUrl/api/Catalog/products',
    ).replace(queryParameters: queryParams);

    final response = await http.get(
      uri,
      headers: _getHeaders(includeAuth: false),
    );

    if (_isOk(response.statusCode)) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception(
        'Error al obtener productos (${response.statusCode}): ${response.body}',
      );
    }
  }

  Future<Product> getProductById(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/Catalog/products/$id'),
      headers: _getHeaders(includeAuth: false),
    );

    if (_isOk(response.statusCode)) {
      return Product.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(
        'Error al obtener producto (${response.statusCode}): ${response.body}',
      );
    }
  }

  // EMPRESA PRODUCTS ENDPOINTS
  Future<List<Product>> getEmpresaProducts() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/empresa/products'),
      headers: _getHeaders(),
    );

    if (_isOk(response.statusCode)) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception(
        'Error al obtener productos (${response.statusCode}): ${response.body}',
      );
    }
  }

  Future<Product> createProduct(ProductCreateDto product) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/empresa/products'),
      headers: _getHeaders(),
      body: jsonEncode(product.toJson()),
    );

    if (_isOk(response.statusCode)) {
      if (response.body.isNotEmpty) {
        return Product.fromJson(jsonDecode(response.body));
      } else {
        // Si tu API devolviera 201/204 sin body
        throw Exception(
          'Producto creado correctamente pero la respuesta llegó vacía (status ${response.statusCode}).',
        );
      }
    } else {
      throw Exception(
        'Error al crear producto (${response.statusCode}): ${response.body}',
      );
    }
  }

  Future<void> updateProduct(int id, ProductUpdateDto product) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/empresa/products/$id'),
      headers: _getHeaders(),
      body: jsonEncode(product.toJson()),
    );

    if (!_isOk(response.statusCode)) {
      throw Exception(
        'Error al actualizar producto (${response.statusCode}): ${response.body}',
      );
    }
  }

  Future<void> deleteProduct(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/api/empresa/products/$id'),
      headers: _getHeaders(),
    );

    if (!_isOk(response.statusCode)) {
      throw Exception(
        'Error al eliminar producto (${response.statusCode}): ${response.body}',
      );
    }
  }

  Future<void> activateProduct(int id) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/api/empresa/products/$id/activar'),
      headers: _getHeaders(),
    );

    if (!_isOk(response.statusCode)) {
      throw Exception(
        'Error al activar producto (${response.statusCode}): ${response.body}',
      );
    }
  }

  Future<void> deactivateProduct(int id) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/api/empresa/products/$id/desactivar'),
      headers: _getHeaders(),
    );

    if (!_isOk(response.statusCode)) {
      throw Exception(
        'Error al desactivar producto (${response.statusCode}): ${response.body}',
      );
    }
  }

  // ORDERS ENDPOINTS
  Future<Order> createOrder(CreateOrderDto order) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/pedidos'),
      headers: _getHeaders(),
      body: jsonEncode(order.toJson()),
    );

    if (_isOk(response.statusCode)) {
      return Order.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(
        'Error al crear pedido (${response.statusCode}): ${response.body}',
      );
    }
  }

  // services/api_service.dart
  Future<List<Order>> getMyOrders({int? empresaId, OrderStatus? status}) async {
    final queryParams = <String, String>{};
    if (empresaId != null) queryParams['empresaId'] = empresaId.toString();
    if (status != null) queryParams['status'] = status.value.toString(); // 0..3

    final uri = Uri.parse(
      '$baseUrl/api/pedidos/mios',
    ).replace(queryParameters: queryParams.isEmpty ? null : queryParams);

    final response = await http.get(uri, headers: _getHeaders());

    if (_isOk(response.statusCode)) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Order.fromJson(json)).toList();
    } else {
      throw Exception(
        'Error al obtener pedidos (${response.statusCode}): ${response.body}',
      );
    }
  }

  Future<Order> getOrderById(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/pedidos/$id'),
      headers: _getHeaders(),
    );

    if (_isOk(response.statusCode)) {
      return Order.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(
        'Error al obtener pedido (${response.statusCode}): ${response.body}',
      );
    }
  }

  // EMPRESA ORDERS ENDPOINTS
  Future<List<Order>> getEmpresaOrders() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/empresa/pedidos'),
      headers: _getHeaders(),
    );

    if (_isOk(response.statusCode)) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Order.fromJson(json)).toList();
    } else {
      throw Exception(
        'Error al obtener pedidos (${response.statusCode}): ${response.body}',
      );
    }
  }

  Future<Order> updateOrderStatus(int id, OrderStatus status) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/api/empresa/pedidos/$id/estado'),
      headers: _getHeaders(),
      body: jsonEncode(UpdateOrderStatusDto(status: status).toJson()),
    );

    if (_isOk(response.statusCode)) {
      return Order.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(
        'Error al actualizar estado del pedido (${response.statusCode}): ${response.body}',
      );
    }
  }

  // REVIEWS ENDPOINTS
  Future<List<Review>> getProductReviews(int productId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/productos/$productId/reseñas'),
      headers: _getHeaders(includeAuth: false),
    );

    if (_isOk(response.statusCode)) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Review.fromJson(json)).toList();
    } else {
      throw Exception(
        'Error al obtener reseñas (${response.statusCode}): ${response.body}',
      );
    }
  }

  Future<Review> createReview(int productId, CreateReviewDto review) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/productos/$productId/reseñas'),
      headers: _getHeaders(),
      body: jsonEncode(review.toJson()),
    );

    if (_isOk(response.statusCode)) {
      return Review.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(
        'Error al crear reseña (${response.statusCode}): ${response.body}',
      );
    }
  }
}

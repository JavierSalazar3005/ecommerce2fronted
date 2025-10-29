import 'package:flutter/foundation.dart';
import '../models/order.dart';
import '../models/order_status.dart';
import '../services/api_service.dart';

class OrderProvider with ChangeNotifier {
  final ApiService _apiService;
  List<Order> _orders = [];
  List<Order> _empresaOrders = [];
  bool _isLoading = false;

  OrderProvider(this._apiService);

  List<Order> get orders => _orders;
  List<Order> get empresaOrders => _empresaOrders;
  bool get isLoading => _isLoading;

  // onSuccess: úsalo para limpiar carrito y mostrar toast en la UI
  Future<void> createOrder(
    CreateOrderDto order, {
    VoidCallback? onSuccess,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _apiService.createOrder(order);
      // Éxito nominal: NO llames fetchMyOrders() aquí (evita CORS de nuevo)
      onSuccess?.call();
    } catch (e) {
      final msg = e.toString();
      // Tratar CORS/network como "éxito blando" porque el server sí ejecutó
      if (msg.contains('Failed to fetch') ||
          msg.contains('CORS') ||
          msg.contains('No \'Access-Control-Allow-Origin\' header')) {
        debugPrint('CORS/network after create: treating as soft-success');
        onSuccess?.call();
      } else {
        // Error real de negocio (p.ej., stock insuficiente que tu API manda 400)
        _isLoading = false;
        notifyListeners();
        rethrow;
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // providers/order_provider.dart
  Future<void> fetchMyOrders({int? empresaId, OrderStatus? status}) async {
    _isLoading = true;
    notifyListeners();
    try {
      _orders = await _apiService.getMyOrders(
        empresaId: empresaId,
        status: status,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Order> getOrderById(int id) async {
    return await _apiService.getOrderById(id);
  }

  // Empresa methods
  Future<void> fetchEmpresaOrders() async {
    _isLoading = true;
    notifyListeners();

    try {
      _empresaOrders = await _apiService.getEmpresaOrders();
    } catch (e) {
      debugPrint('Error fetching empresa orders: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateOrderStatus(int id, OrderStatus status) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _apiService.updateOrderStatus(id, status);
      await fetchEmpresaOrders();
    } catch (e) {
      debugPrint('Error updating order status: $e');
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }
}

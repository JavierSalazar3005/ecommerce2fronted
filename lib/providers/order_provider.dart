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

  Future<void> createOrder(CreateOrderDto order) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _apiService.createOrder(order);
      await fetchMyOrders();
    } catch (e) {
      debugPrint('Error creating order: $e');
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> fetchMyOrders() async {
    _isLoading = true;
    notifyListeners();

    try {
      _orders = await _apiService.getMyOrders();
    } catch (e) {
      debugPrint('Error fetching orders: $e');
      rethrow;
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

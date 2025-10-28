import 'package:flutter/foundation.dart';
import '../models/cart_item.dart';
import '../models/product.dart';

class CartProvider with ChangeNotifier {
  final Map<int, CartItem> _items = {};

  Map<int, CartItem> get items => {..._items};

  int get itemCount => _items.length;

  double get totalAmount {
    double total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.subtotal;
    });
    return total;
  }

  void addItem(Product product, int quantity) {
    if (_items.containsKey(product.id)) {
      _items[product.id]!.quantity += quantity;
    } else {
      _items[product.id] = CartItem(
        product: product,
        quantity: quantity,
      );
    }
    notifyListeners();
  }

  void removeItem(int productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void updateQuantity(int productId, int quantity) {
    if (_items.containsKey(productId)) {
      if (quantity > 0) {
        _items[productId]!.quantity = quantity;
      } else {
        _items.remove(productId);
      }
      notifyListeners();
    }
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }

  List<CartItem> getItemsByEmpresa(int empresaId) {
    return _items.values
        .where((item) => item.product.empresaId == empresaId)
        .toList();
  }

  Map<int, List<CartItem>> getItemsGroupedByEmpresa() {
    final Map<int, List<CartItem>> grouped = {};
    
    for (var item in _items.values) {
      final empresaId = item.product.empresaId;
      if (!grouped.containsKey(empresaId)) {
        grouped[empresaId] = [];
      }
      grouped[empresaId]!.add(item);
    }
    
    return grouped;
  }
}

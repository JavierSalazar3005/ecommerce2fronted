import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../services/api_service.dart';

class ProductProvider with ChangeNotifier {
  final ApiService _apiService;
  
  List<Product> _products = [];
  List<Product> _empresaProducts = [];
  bool _isLoading = false;

  ProductProvider(this._apiService);

  List<Product> get products => _products;
  List<Product> get empresaProducts => _empresaProducts;
  bool get isLoading => _isLoading;

  // Catalog methods (public)
  Future<void> fetchProducts({
    int? empresaId,
    double? precioMin,
    double? precioMax,
    String? query,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      _products = await _apiService.getProducts(
        empresaId: empresaId,
        precioMin: precioMin,
        precioMax: precioMax,
        query: query,
      );
    } catch (e) {
      debugPrint('Error fetching products: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Product> getProductById(int id) async {
    return await _apiService.getProductById(id);
  }

  // Empresa methods
  Future<void> fetchEmpresaProducts() async {
    _isLoading = true;
    notifyListeners();

    try {
      _empresaProducts = await _apiService.getEmpresaProducts();
    } catch (e) {
      debugPrint('Error fetching empresa products: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createProduct(ProductCreateDto product) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _apiService.createProduct(product);
      await fetchEmpresaProducts();
    } catch (e) {
      debugPrint('Error creating product: $e');
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateProduct(int id, ProductUpdateDto product) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _apiService.updateProduct(id, product);
      await fetchEmpresaProducts();
    } catch (e) {
      debugPrint('Error updating product: $e');
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteProduct(int id) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _apiService.deleteProduct(id);
      await fetchEmpresaProducts();
    } catch (e) {
      debugPrint('Error deleting product: $e');
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> toggleProductStatus(int id, bool isActive) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (isActive) {
        await _apiService.deactivateProduct(id);
      } else {
        await _apiService.activateProduct(id);
      }
      await fetchEmpresaProducts();
    } catch (e) {
      debugPrint('Error toggling product status: $e');
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }
}

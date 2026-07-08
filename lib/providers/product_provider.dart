import 'package:flutter/foundation.dart';

import '../database/database_helper.dart';
import '../models/cart_item.dart';
import '../models/product.dart';

class ProductProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;
  final List<Product> _products = [];
  bool _isLoading = false;

  final List<Product> _seedProducts = [
    Product(
      id: null,
      name: 'Indomie Goreng',
      sellingPrice: 3500,
      costPrice: 2800,
      stock: 40,
      unit: 'pcs',
    ),
    Product(
      id: null,
      name: 'Aqua 600ml',
      sellingPrice: 4000,
      costPrice: 3100,
      stock: 24,
      unit: 'botol',
    ),
    Product(
      id: null,
      name: 'Telur Ayam',
      sellingPrice: 2000,
      costPrice: 1600,
      stock: 30,
      unit: 'pcs',
    ),
  ];

  ProductProvider() {
    loadProducts();
  }

  List<Product> get products => List.unmodifiable(_products);
  bool get isLoading => _isLoading;

  Future<void> loadProducts() async {
    _isLoading = true;
    notifyListeners();
    try {
      final products = await _db.getProducts();
      if (products.isEmpty) {
        // If running on a real platform (not web), insert seed products to DB
        // first so returned products have valid IDs. On web, sqflite is
        // unavailable so we expose in-memory seed products instead.
        if (!kIsWeb) {
          for (final seed in _seedProducts) {
            await _db.insertProduct(seed);
          }
          final fresh = await _db.getProducts();
          _products
            ..clear()
            ..addAll(fresh);
        } else {
          _products
            ..clear()
            ..addAll(_seedProducts);
        }
      } else {
        _products
          ..clear()
          ..addAll(products);
      }
    } catch (_) {
      _products
        ..clear()
        ..addAll(_seedProducts);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<Product> search(String query) {
    if (query.isEmpty) {
      return products;
    }
    final filter = query.toLowerCase();
    return products.where((product) {
      return product.name.toLowerCase().contains(filter) ||
          product.unit.toLowerCase().contains(filter);
    }).toList();
  }

  Future<void> addProduct(Product product) async {
    if (kIsWeb) {
      _products.add(product);
      notifyListeners();
      return;
    }

    try {
      await _db.insertProduct(product);
      await loadProducts();
    } catch (_) {
      _products.add(product);
      notifyListeners();
    }
  }

  Future<void> updateProduct(Product product) async {
    if (kIsWeb) {
      final index = _products.indexWhere((item) => item.id == product.id);
      if (index != -1) {
        _products[index] = product;
        notifyListeners();
      }
      return;
    }

    try {
      await _db.updateProduct(product);
      await loadProducts();
    } catch (_) {
      final index = _products.indexWhere((item) => item.id == product.id);
      if (index != -1) {
        _products[index] = product;
        notifyListeners();
      }
    }
  }

  Future<void> updateProductImage(int productId, String imagePath) async {
    final product = products.firstWhere(
      (item) => item.id == productId,
      orElse: () => throw StateError('Product not found'),
    );

    final updatedProduct = Product(
      id: product.id,
      name: product.name,
      sellingPrice: product.sellingPrice,
      costPrice: product.costPrice,
      stock: product.stock,
      unit: product.unit,
      category: product.category,
      imagePath: imagePath,
    );

    await updateProduct(updatedProduct);
  }

  Future<void> deleteProduct(int id) async {
    if (kIsWeb) {
      _products.removeWhere((item) => item.id == id);
      notifyListeners();
      return;
    }

    try {
      await _db.deleteProduct(id);
      await loadProducts();
    } catch (_) {
      _products.removeWhere((item) => item.id == id);
      notifyListeners();
    }
  }

  Future<void> restockProduct(int productId, int amount) async {
    final product = products.firstWhere(
      (item) => item.id == productId,
      orElse: () => throw StateError('Product not found'),
    );
    final newStock = product.stock + amount;

    if (kIsWeb) {
      final index = _products.indexWhere((item) => item.id == productId);
      if (index != -1) {
        _products[index] = Product(
          id: product.id,
          name: product.name,
          sellingPrice: product.sellingPrice,
          costPrice: product.costPrice,
          stock: newStock,
          unit: product.unit,
        );
        notifyListeners();
      }
      return;
    }

    try {
      await _db.updateProductStock(productId, newStock);
      await loadProducts();
    } catch (_) {
      final index = _products.indexWhere((item) => item.id == productId);
      if (index != -1) {
        _products[index] = Product(
          id: product.id,
          name: product.name,
          sellingPrice: product.sellingPrice,
          costPrice: product.costPrice,
          stock: newStock,
          unit: product.unit,
        );
        notifyListeners();
      }
    }
  }

  Future<bool> checkoutCart(List<CartItem> cartItems) async {
    if (cartItems.isEmpty) return false;
    final total = cartItems.fold<int>(
      0,
      (sum, item) => sum + item.product.sellingPrice * item.quantity,
    );
    final profit = cartItems.fold<int>(
      0,
      (sum, item) =>
          sum +
          (item.product.sellingPrice - item.product.costPrice) * item.quantity,
    );
    final createdAt = DateTime.now().toIso8601String();
    final transactionId = await _db.insertTransaction({
      'total': total,
      'profit': profit,
      'created_at': createdAt,
    });

    for (final item in cartItems) {
      final updatedStock = item.product.stock - item.quantity;
      await _db.insertTransactionItem({
        'transaction_id': transactionId,
        'product_id': item.product.id!,
        'quantity': item.quantity,
        'subtotal': item.product.sellingPrice * item.quantity,
      });
      await _db.updateProductStock(item.product.id!, updatedStock);
    }

    await loadProducts();
    return true;
  }

  Future<int> revenueToday() async {
    return await _db.getRevenueToday();
  }

  Future<int> profitToday() async {
    return await _db.getProfitToday();
  }

  Future<int> transactionCountToday() async {
    return await _db.getTransactionCountToday();
  }

  Future<List<Product>> lowStockProducts(int threshold) async {
    return await _db.getLowStockProducts(threshold);
  }
}

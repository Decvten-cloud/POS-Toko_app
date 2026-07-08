import 'dart:math';

import 'package:flutter/material.dart';

import '../models/cart_item.dart';
import '../providers/product_provider.dart';

class CartProvider extends ChangeNotifier {
  final Map<int, CartItem> _items = {};

  List<CartItem> get items => _items.values.toList();
  int get count => _items.length;
  bool get isEmpty => _items.isEmpty;

  int get total => _items.values.fold(0, (sum, item) => sum + item.product.sellingPrice * item.quantity);

  void addProduct(product) {
    if (product.id == null) return;
    if (_items.containsKey(product.id)) {
      final item = _items[product.id]!;
      if (item.quantity < product.stock) {
        item.quantity += 1;
      }
    } else if (product.stock > 0) {
      _items[product.id!] = CartItem(product: product, quantity: 1);
    }
    notifyListeners();
  }

  void decreaseQuantity(int productId) {
    if (!_items.containsKey(productId)) return;
    final item = _items[productId]!;
    item.quantity = max(1, item.quantity - 1);
    if (item.quantity <= 0) {
      _items.remove(productId);
    }
    notifyListeners();
  }

  void increaseQuantity(int productId) {
    if (!_items.containsKey(productId)) return;
    final item = _items[productId]!;
    if (item.quantity < item.product.stock) {
      item.quantity += 1;
      notifyListeners();
    }
  }

  void removeItem(int productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  Future<bool> checkout(ProductProvider productProvider) async {
    if (isEmpty) return false;
    for (final item in items) {
      final product = productProvider.products.firstWhere((element) => element.id == item.product.id, orElse: () => item.product);
      if (item.quantity > product.stock) {
        return false;
      }
    }
    final success = await productProvider.checkoutCart(items);
    if (success) {
      clearCart();
    }
    return success;
  }
}

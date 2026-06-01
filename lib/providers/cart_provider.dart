import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/models/cart_model.dart';
import '../data/models/cart_item_model.dart';
import '../data/services/cart_service.dart';

class CartProvider extends ChangeNotifier {
  final CartService _cartService = CartService();

  CartModel? _cart;
  StreamSubscription? _cartSubscription;
  bool _isLoading = false;
  String? _error;

  CartModel? get cart => _cart;
  bool get isLoading => _isLoading;
  String? get error => _error;

  CartProvider() {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      _cartSubscription?.cancel();
      if (user != null) {
        _cartSubscription = _cartService.getCart(user.uid).listen((data) {
          _cart = data;
          notifyListeners();
        });
      } else {
        _cart = null;
        notifyListeners();
      }
    });
  }

  Future<void> addItem(CartItemModel item) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    _setLoading(true);
    await _cartService.addItem(user.uid, item);
    _setLoading(false);
  }

  Future<void> removeItem(String sku) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    _setLoading(true);
    await _cartService.removeItem(user.uid, sku);
    _setLoading(false);
  }

  Future<void> updateQuantity(String sku, int quantity) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    if (quantity <= 0) {
      await removeItem(sku);
      return;
    }
    _setLoading(true);
    await _cartService.updateQuantity(user.uid, sku, quantity);
    _setLoading(false);
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _cartSubscription?.cancel();
    super.dispose();
  }
}

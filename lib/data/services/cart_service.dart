import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/cart_model.dart';
import '../models/cart_item_model.dart';

class CartService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<CartModel> getCart(String userId) {
    return _firestore.collection('carts').doc(userId).snapshots().map((doc) {
      if (doc.exists) {
        return CartModel.fromFirestore(doc);
      }
      return CartModel(
        items: [],
        descuentoAplicado: 0,
        subtotal: 0,
        total: 0,
      );
    });
  }

  Future<void> addItem(String userId, CartItemModel newItem) async {
    final cartRef = _firestore.collection('carts').doc(userId);
    
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(cartRef);
      List<dynamic> currentItemsMap = [];
      
      if (snapshot.exists) {
        currentItemsMap = snapshot.data()?['items'] as List<dynamic>? ?? [];
      }

      final items = currentItemsMap
          .map((i) => CartItemModel.fromMap(i as Map<String, dynamic>))
          .toList();

      final existingIndex = items.indexWhere((item) => item.sku == newItem.sku);

      if (existingIndex >= 0) {
        final existingItem = items[existingIndex];
        items[existingIndex] = CartItemModel(
          prodId: existingItem.prodId,
          sku: existingItem.sku,
          nombreSnapshot: existingItem.nombreSnapshot,
          precioSnapshot: existingItem.precioSnapshot,
          talla: existingItem.talla,
          color: existingItem.color,
          colorHex: existingItem.colorHex,
          cantidad: existingItem.cantidad + newItem.cantidad,
          imagenUrl: existingItem.imagenUrl,
        );
      } else {
        items.add(newItem);
      }

      double subtotal = 0;
      for (var i in items) {
        subtotal += i.precioSnapshot * i.cantidad;
      }
      
      // We don't recalculate the coupon here perfectly without the coupon model, 
      // but in the provider we will update it.
      transaction.set(cartRef, {
        'items': items.map((i) => i.toMap()).toList(),
        'subtotal': subtotal,
        // Let provider handle the new total and discount when items change.
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    });
  }

  Future<void> removeItem(String userId, String sku) async {
    final cartRef = _firestore.collection('carts').doc(userId);
    final snapshot = await cartRef.get();
    if (!snapshot.exists) return;

    final itemsMap = snapshot.data()?['items'] as List<dynamic>? ?? [];
    final items = itemsMap
        .map((i) => CartItemModel.fromMap(i as Map<String, dynamic>))
        .toList();

    items.removeWhere((item) => item.sku == sku);

    double subtotal = 0;
    for (var i in items) {
      subtotal += i.precioSnapshot * i.cantidad;
    }

    await cartRef.update({
      'items': items.map((i) => i.toMap()).toList(),
      'subtotal': subtotal,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateQuantity(String userId, String sku, int quantity) async {
    final cartRef = _firestore.collection('carts').doc(userId);
    final snapshot = await cartRef.get();
    if (!snapshot.exists) return;

    final itemsMap = snapshot.data()?['items'] as List<dynamic>? ?? [];
    final items = itemsMap
        .map((i) => CartItemModel.fromMap(i as Map<String, dynamic>))
        .toList();

    final idx = items.indexWhere((item) => item.sku == sku);
    if (idx >= 0) {
      final existingItem = items[idx];
      items[idx] = CartItemModel(
        prodId: existingItem.prodId,
        sku: existingItem.sku,
        nombreSnapshot: existingItem.nombreSnapshot,
        precioSnapshot: existingItem.precioSnapshot,
        talla: existingItem.talla,
        color: existingItem.color,
        colorHex: existingItem.colorHex,
        cantidad: quantity,
        imagenUrl: existingItem.imagenUrl,
      );
    }

    double subtotal = 0;
    for (var i in items) {
      subtotal += i.precioSnapshot * i.cantidad;
    }

    await cartRef.update({
      'items': items.map((i) => i.toMap()).toList(),
      'subtotal': subtotal,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> clearCart(String userId) async {
    await _firestore.collection('carts').doc(userId).set({
      'items': [],
      'cuponAplicado': null,
      'descuentoAplicado': 0,
      'subtotal': 0,
      'total': 0,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}

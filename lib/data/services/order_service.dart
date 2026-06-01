import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/cart_item_model.dart';
import '../models/order_model.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> confirmOrder({
    required String userId,
    required List<CartItemModel> items,
    required Map<String, dynamic> direccionEnvio,
    required String metodoPago,
    required double subtotal,
    required double descuento,
    required String? cuponUsado,
  }) async {
    if (items.isEmpty) {
      throw Exception('El carrito está vacío');
    }

    for (final item in items) {
      final prodSnap =
          await _firestore.collection('products').doc(item.prodId).get();

      if (!prodSnap.exists) {
        throw Exception('Producto "${item.nombreSnapshot}" no encontrado');
      }

      final data = prodSnap.data();
      if (data == null) {
        throw Exception('Datos corruptos: "${item.nombreSnapshot}"');
      }

      final variantsRaw = data['variants'];
      if (variantsRaw != null && variantsRaw is List && variantsRaw.isNotEmpty) {
        final variants = List<Map<String, dynamic>>.from(variantsRaw);
        final idx = variants.indexWhere((v) => v['sku'] == item.sku);
        if (idx != -1) {
          final stock = variants[idx]['stock'] ?? 0;
          if ((stock as int) < item.cantidad) {
            throw Exception(
              'Stock insuficiente para "${item.nombreSnapshot}" (talla ${item.talla}). Disponible: $stock',
            );
          }
        }
      } else {
        final globalStock = data['stock'] ?? 0;
        if ((globalStock as int) < item.cantidad) {
          throw Exception(
            'Stock insuficiente para "${item.nombreSnapshot}". Disponible: $globalStock',
          );
        }
      }
    }

    String orderId;
    final orderRef = _firestore.collection('orders').doc();
    orderId = orderRef.id;

    await orderRef.set({
      'orderId': orderId,
      'userId': userId,
      'items': items.map((i) => i.toOrderMap()).toList(),
      'subtotal': subtotal,
      'descuentoAplicado': descuento,
      'cuponUsado': cuponUsado,
      'envioCosto': 0.0,
      'total': subtotal - descuento,
      'estado': 'pendiente',
      'direccionEnvio': direccionEnvio,
      'metodoPago': metodoPago,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    for (final item in items) {
      try {
        final prodRef = _firestore.collection('products').doc(item.prodId);
        final prodSnap = await prodRef.get();
        final data = prodSnap.data();

        if (data != null) {
          final variantsRaw = data['variants'];
          if (variantsRaw != null && variantsRaw is List && variantsRaw.isNotEmpty) {
            final variants = List<Map<String, dynamic>>.from(variantsRaw);
            final idx = variants.indexWhere((v) => v['sku'] == item.sku);
            if (idx != -1) {
              variants[idx]['stock'] = (variants[idx]['stock'] ?? 0) - item.cantidad;
              await prodRef.update({
                'variants': variants,
                'updatedAt': FieldValue.serverTimestamp(),
              });
            } else {
              await prodRef.update({
                'stock': FieldValue.increment(-item.cantidad),
                'updatedAt': FieldValue.serverTimestamp(),
              });
            }
          } else {
            await prodRef.update({
              'stock': FieldValue.increment(-item.cantidad),
              'updatedAt': FieldValue.serverTimestamp(),
            });
          }
        }
      } on FirebaseException catch (err) {
        print('WARN: stock not decremented for "${item.nombreSnapshot}": ${err.message}');
      }
    }

    try {
      await _firestore.collection('carts').doc(userId).set({
        'items': [],
        'cuponAplicado': null,
        'descuentoAplicado': 0,
        'subtotal': 0,
        'total': 0,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (err) {
      print('WARN: cart not cleared: ${err.message}');
    }

    if (cuponUsado != null && cuponUsado.isNotEmpty) {
      try {
        final couponRef = _firestore.collection('coupons').doc(cuponUsado);
        final couponSnap = await couponRef.get();
        if (couponSnap.exists) {
          await couponRef.update({'usedCount': FieldValue.increment(1)});
        }
      } on FirebaseException catch (err) {
        print('WARN: coupon not updated: ${err.message}');
      }
    }

    return orderId;
  }

  Stream<List<OrderModel>> getUserOrders(String userId) {
    return _firestore
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final orders = snapshot.docs.map((doc) => OrderModel.fromFirestore(doc)).toList();
      orders.sort((a, b) =>
          (b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0))
              .compareTo(a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0)));
      return orders;
    });
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    await _firestore.collection('orders').doc(orderId).update({
      'estado': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<OrderModel>> getAllOrders({String? status}) {
    Query query = _firestore.collection('orders');
    if (status != null && status.isNotEmpty && status != 'todos') {
      query = query.where('estado', isEqualTo: status);
    }
    return query.snapshots().map((snapshot) {
      final orders = snapshot.docs.map((doc) => OrderModel.fromFirestore(doc)).toList();
      orders.sort((a, b) =>
          (b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0))
              .compareTo(a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0)));
      return orders;
    });
  }
}

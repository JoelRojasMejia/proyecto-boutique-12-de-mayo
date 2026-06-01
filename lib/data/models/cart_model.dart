import 'package:cloud_firestore/cloud_firestore.dart';
import 'cart_item_model.dart';

class CartModel {
  final List<CartItemModel> items;
  final String? cuponAplicado;
  final double descuentoAplicado;
  final double subtotal;
  final double total;
  final DateTime? updatedAt;

  CartModel({
    required this.items,
    this.cuponAplicado,
    required this.descuentoAplicado,
    required this.subtotal,
    required this.total,
    this.updatedAt,
  });

  factory CartModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>? ?? {};
    return CartModel(
      items: (data['items'] as List<dynamic>? ?? [])
          .map((item) => CartItemModel.fromMap(item as Map<String, dynamic>))
          .toList(),
      cuponAplicado: data['cuponAplicado'],
      descuentoAplicado: (data['descuentoAplicado'] ?? 0).toDouble(),
      subtotal: (data['subtotal'] ?? 0).toDouble(),
      total: (data['total'] ?? 0).toDouble(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'items': items.map((item) => item.toMap()).toList(),
      if (cuponAplicado != null) 'cuponAplicado': cuponAplicado,
      'descuentoAplicado': descuentoAplicado,
      'subtotal': subtotal,
      'total': total,
      if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
    };
  }
}

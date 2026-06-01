import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class OrderItem {
  final String prodId;
  final String sku;
  final String nombre;
  final double precioUnitario;
  final int cantidad;
  final String talla;
  final String color;
  final String imagenUrl;

  OrderItem({
    required this.prodId,
    required this.sku,
    required this.nombre,
    required this.precioUnitario,
    required this.cantidad,
    required this.talla,
    required this.color,
    required this.imagenUrl,
  });

  factory OrderItem.fromMap(Map<String, dynamic> data) {
    return OrderItem(
      prodId: data['prodId'] ?? '',
      sku: data['sku'] ?? '',
      nombre: data['nombre'] ?? '',
      precioUnitario: (data['precioUnitario'] ?? 0).toDouble(),
      cantidad: data['cantidad'] ?? 0,
      talla: data['talla'] ?? '',
      color: data['color'] ?? '',
      imagenUrl: data['imagenUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'prodId': prodId,
      'sku': sku,
      'nombre': nombre,
      'precioUnitario': precioUnitario,
      'cantidad': cantidad,
      'talla': talla,
      'color': color,
      'imagenUrl': imagenUrl,
    };
  }
}

class OrderModel {
  final String orderId;
  final String userId;
  final List<OrderItem> items;
  final double subtotal;
  final double descuentoAplicado;
  final String? cuponUsado;
  final double envioCosto;
  final double total;
  final String estado;
  final Map<String, dynamic> direccionEnvio;
  final String metodoPago;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  OrderModel({
    required this.orderId,
    required this.userId,
    required this.items,
    required this.subtotal,
    required this.descuentoAplicado,
    this.cuponUsado,
    required this.envioCosto,
    required this.total,
    required this.estado,
    required this.direccionEnvio,
    required this.metodoPago,
    this.createdAt,
    this.updatedAt,
  });

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>? ?? {};
    return OrderModel(
      orderId: data['orderId'] ?? doc.id,
      userId: data['userId'] ?? '',
      items: (data['items'] as List<dynamic>? ?? [])
          .map((item) => OrderItem.fromMap(item as Map<String, dynamic>))
          .toList(),
      subtotal: (data['subtotal'] ?? 0).toDouble(),
      descuentoAplicado: (data['descuentoAplicado'] ?? 0).toDouble(),
      cuponUsado: data['cuponUsado'],
      envioCosto: (data['envioCosto'] ?? 0).toDouble(),
      total: (data['total'] ?? 0).toDouble(),
      estado: data['estado'] ?? 'pendiente',
      direccionEnvio: data['direccionEnvio'] as Map<String, dynamic>? ?? {},
      metodoPago: data['metodoPago'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'userId': userId,
      'items': items.map((item) => item.toMap()).toList(),
      'subtotal': subtotal,
      'descuentoAplicado': descuentoAplicado,
      if (cuponUsado != null) 'cuponUsado': cuponUsado,
      'envioCosto': envioCosto,
      'total': total,
      'estado': estado,
      'direccionEnvio': direccionEnvio,
      'metodoPago': metodoPago,
      if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
      if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
    };
  }

  Color get statusColor {
    switch (estado.toLowerCase()) {
      case 'procesando':
        return AppColors.warning;
      case 'enviado':
        return AppColors.info;
      case 'entregado':
        return AppColors.success;
      case 'cancelado':
        return AppColors.error;
      case 'pendiente':
      default:
        return AppColors.textSecondary;
    }
  }

  String get statusLabel {
    switch (estado.toLowerCase()) {
      case 'procesando':
        return 'Procesando';
      case 'enviado':
        return 'Enviado';
      case 'entregado':
        return 'Entregado';
      case 'cancelado':
        return 'Cancelado';
      case 'pendiente':
      default:
        return 'Pendiente';
    }
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

class ProductVariant {
  final String talla;
  final String color;
  final String colorHex;
  final int stock;
  final String sku;

  ProductVariant({
    required this.talla,
    required this.color,
    required this.colorHex,
    required this.stock,
    required this.sku,
  });

  factory ProductVariant.fromMap(Map<String, dynamic> data) {
    return ProductVariant(
      talla: data['talla'] ?? '',
      color: data['color'] ?? '',
      colorHex: data['colorHex'] ?? '',
      stock: data['stock'] ?? 0,
      sku: data['sku'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'talla': talla,
      'color': color,
      'colorHex': colorHex,
      'stock': stock,
      'sku': sku,
    };
  }
}

class ProductModel {
  final String id;
  final String nombre;
  final String descripcion;
  final double precio;
  final double? discountPrice;
  final int stock;
  final String categoriaId;
  final String categoriaNombre;
  final String? marcaId;
  final String? marcaNombre;
  final List<String> imagenes;
  final double rating;
  final int reviewCount;
  final bool isPremium;
  final bool isActive;
  final List<ProductVariant> variants;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ProductModel({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.precio,
    this.discountPrice,
    required this.stock,
    required this.categoriaId,
    required this.categoriaNombre,
    this.marcaId,
    this.marcaNombre,
    required this.imagenes,
    required this.rating,
    required this.reviewCount,
    required this.isPremium,
    required this.isActive,
    required this.variants,
    this.createdAt,
    this.updatedAt,
  });

  factory ProductModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>? ?? {};
    return ProductModel(
      id: doc.id,
      nombre: data['nombre'] ?? '',
      descripcion: data['descripcion'] ?? '',
      precio: (data['precio'] ?? 0).toDouble(),
      discountPrice: data['discountPrice'] != null ? (data['discountPrice'] as num).toDouble() : null,
      stock: data['stock'] ?? 0,
      categoriaId: data['categoriaId'] ?? '',
      categoriaNombre: data['categoriaNombre'] ?? '',
      marcaId: data['marcaId'],
      marcaNombre: data['marcaNombre'],
      imagenes: List<String>.from(data['imagenes'] ?? []),
      rating: (data['rating'] ?? 0).toDouble(),
      reviewCount: data['reviewCount'] ?? 0,
      isPremium: data['isPremium'] ?? false,
      isActive: data['isActive'] ?? true,
      variants: (data['variants'] as List<dynamic>? ?? [])
          .map((v) => ProductVariant.fromMap(v as Map<String, dynamic>))
          .toList(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
      'precio': precio,
      if (discountPrice != null) 'discountPrice': discountPrice,
      'stock': stock,
      'categoriaId': categoriaId,
      'categoriaNombre': categoriaNombre,
      if (marcaId != null) 'marcaId': marcaId,
      if (marcaNombre != null) 'marcaNombre': marcaNombre,
      'imagenes': imagenes,
      'rating': rating,
      'reviewCount': reviewCount,
      'isPremium': isPremium,
      'isActive': isActive,
      'variants': variants.map((v) => v.toMap()).toList(),
      if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
      if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
    };
  }

  bool get hasDiscount => discountPrice != null && discountPrice! < precio;

  List<String> get availableSizes {
    return variants.where((v) => v.stock > 0).map((v) => v.talla).toSet().toList();
  }

  List<String> get availableColors {
    return variants.where((v) => v.stock > 0).map((v) => v.colorHex).toSet().toList();
  }
}

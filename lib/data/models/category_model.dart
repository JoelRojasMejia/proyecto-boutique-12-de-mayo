import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryModel {
  final String catId;
  final String nombre;
  final String slug;
  final String iconUrl;
  final int displayOrder;
  final int productCount;

  CategoryModel({
    required this.catId,
    required this.nombre,
    required this.slug,
    required this.iconUrl,
    required this.displayOrder,
    required this.productCount,
  });

  factory CategoryModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>? ?? {};
    return CategoryModel(
      catId: doc.id,
      nombre: data['nombre'] ?? '',
      slug: data['slug'] ?? '',
      iconUrl: data['iconUrl'] ?? '',
      displayOrder: data['displayOrder'] ?? 0,
      productCount: data['productCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'slug': slug,
      'iconUrl': iconUrl,
      'displayOrder': displayOrder,
      'productCount': productCount,
    };
  }
}

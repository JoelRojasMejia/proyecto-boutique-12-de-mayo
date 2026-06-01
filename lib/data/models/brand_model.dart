import 'package:cloud_firestore/cloud_firestore.dart';

class BrandModel {
  final String brandId;
  final String nombre;
  final String logoUrl;
  final String descripcion;

  BrandModel({
    required this.brandId,
    required this.nombre,
    required this.logoUrl,
    required this.descripcion,
  });

  factory BrandModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>? ?? {};
    return BrandModel(
      brandId: doc.id,
      nombre: data['nombre'] ?? '',
      logoUrl: data['logoUrl'] ?? '',
      descripcion: data['descripcion'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'logoUrl': logoUrl,
      'descripcion': descripcion,
    };
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String nombre;
  final String rol;
  final String? telefono;
  final String? fotoUrl;
  final int? edad;
  final String? ciudad;
  final List<String> wishlist;
  final DateTime? createdAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.nombre,
    required this.rol,
    this.telefono,
    this.fotoUrl,
    this.edad,
    this.ciudad,
    this.wishlist = const [],
    this.createdAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>? ?? {};
    return UserModel(
      uid: data['uid'] ?? doc.id,
      email: data['email'] ?? '',
      nombre: data['nombre'] ?? '',
      rol: data['rol'] ?? 'customer',
      telefono: data['telefono'],
      fotoUrl: data['fotoUrl'],
      edad: data['edad'],
      ciudad: data['ciudad'],
      wishlist: List<String>.from(data['wishlist'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'nombre': nombre,
      'rol': rol,
      'telefono': telefono,
      'fotoUrl': fotoUrl,
      'edad': edad,
      'ciudad': ciudad,
      'wishlist': wishlist,
      if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
    };
  }

  UserModel copyWith({
    String? email,
    String? nombre,
    String? rol,
    String? telefono,
    String? fotoUrl,
    int? edad,
    String? ciudad,
    List<String>? wishlist,
  }) {
    return UserModel(
      uid: uid,
      email: email ?? this.email,
      nombre: nombre ?? this.nombre,
      rol: rol ?? this.rol,
      telefono: telefono ?? this.telefono,
      fotoUrl: fotoUrl ?? this.fotoUrl,
      edad: edad ?? this.edad,
      ciudad: ciudad ?? this.ciudad,
      wishlist: wishlist ?? this.wishlist,
      createdAt: createdAt,
    );
  }
}

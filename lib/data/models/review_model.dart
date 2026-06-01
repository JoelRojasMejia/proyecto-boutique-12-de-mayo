import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  final String revId;
  final String userId;
  final String nombreCliente;
  final double rating;
  final String comentario;
  final bool verifiedPurchase;
  final DateTime? createdAt;

  ReviewModel({
    required this.revId,
    required this.userId,
    required this.nombreCliente,
    required this.rating,
    required this.comentario,
    required this.verifiedPurchase,
    this.createdAt,
  });

  factory ReviewModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>? ?? {};
    return ReviewModel(
      revId: doc.id,
      userId: data['userId'] ?? '',
      nombreCliente: data['nombreCliente'] ?? '',
      rating: (data['rating'] ?? 0).toDouble(),
      comentario: data['comentario'] ?? '',
      verifiedPurchase: data['verifiedPurchase'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'nombreCliente': nombreCliente,
      'rating': rating,
      'comentario': comentario,
      'verifiedPurchase': verifiedPurchase,
      if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
    };
  }
}

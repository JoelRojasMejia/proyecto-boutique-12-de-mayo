import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/review_model.dart';

class ReviewService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<ReviewModel>> getProductReviews(String prodId, {int limit = 10}) {
    return _firestore
        .collection('products')
        .doc(prodId)
        .collection('userReviews')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ReviewModel.fromFirestore(doc))
          .toList();
    });
  }

  Future<void> addReview(String prodId, ReviewModel review) async {
    final productRef = _firestore.collection('products').doc(prodId);
    final reviewsRef = productRef.collection('userReviews');

    await _firestore.runTransaction((transaction) async {
      // 1. Añadir la reseña
      transaction.set(reviewsRef.doc(review.revId), review.toMap());

      // 2. Actualizar promedios en producto (simulado o simplificado)
      // En una app real, se lee el producto y se actualiza el rating promedio y count.
      final prodSnap = await transaction.get(productRef);
      if (prodSnap.exists) {
        final currentCount = prodSnap.data()?['reviewCount'] as int? ?? 0;
        final currentRating = (prodSnap.data()?['rating'] as num?)?.toDouble() ?? 0.0;

        final newCount = currentCount + 1;
        final newRating = ((currentRating * currentCount) + review.rating) / newCount;

        transaction.update(productRef, {
          'reviewCount': newCount,
          'rating': newRating,
        });
      }
    });
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

class FavoritesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<String>> getFavorites(String userId) {
    return _firestore.collection('users').doc(userId).snapshots().map((doc) {
      if (doc.exists) {
        return List<String>.from(doc.data()?['wishlist'] ?? []);
      }
      return [];
    });
  }

  Future<void> toggleFavorite(String userId, String prodId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (!doc.exists) return;

    List<String> wishlist = List<String>.from(doc.data()?['wishlist'] ?? []);

    if (wishlist.contains(prodId)) {
      wishlist.remove(prodId);
    } else {
      wishlist.add(prodId);
    }

    await _firestore.collection('users').doc(userId).update({
      'wishlist': wishlist,
    });
  }

  Future<bool> isFavorite(String userId, String prodId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (doc.exists) {
      List<String> wishlist = List<String>.from(doc.data()?['wishlist'] ?? []);
      return wishlist.contains(prodId);
    }
    return false;
  }
}

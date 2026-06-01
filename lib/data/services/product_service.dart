import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<ProductModel>> getProducts({String? categoryId}) {
    Query query = _firestore
        .collection('products')
        .where('isActive', isEqualTo: true);

    if (categoryId != null && categoryId.isNotEmpty) {
      query = query.where('categoriaId', isEqualTo: categoryId);
    }

    return query.snapshots().map((snapshot) {
      final products = snapshot.docs
          .map((doc) => ProductModel.fromFirestore(doc))
          .toList();
      products.sort((a, b) => (b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0))
          .compareTo(a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0)));
      return products;
    });
  }

  Stream<List<ProductModel>> getPremiumProducts() {
    return _firestore
        .collection('products')
        .where('isPremium', isEqualTo: true)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      final products = snapshot.docs
          .map((doc) => ProductModel.fromFirestore(doc))
          .toList();
      products.sort((a, b) => b.precio.compareTo(a.precio));
      return products;
    });
  }

  Future<ProductModel?> getProductById(String id) async {
    final doc = await _firestore.collection('products').doc(id).get();
    if (doc.exists) {
      return ProductModel.fromFirestore(doc);
    }
    return null;
  }

  Future<List<ProductModel>> searchProducts(String query) async {
    // Basic search simulation in Firestore (limited without Algolia)
    // Here we return all active products and filter in client if needed, or filter exactly.
    // For MVP, we'll fetch all and filter in Dart if query is complex.
    final snapshot = await _firestore
        .collection('products')
        .where('isActive', isEqualTo: true)
        .get();

    final allProducts = snapshot.docs.map((doc) => ProductModel.fromFirestore(doc)).toList();
    final lowercaseQuery = query.toLowerCase();

    return allProducts.where((p) {
      return p.nombre.toLowerCase().contains(lowercaseQuery) ||
          p.descripcion.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  // ─── ADMIN CRUD ──────────────────────────────────────────────

  Future<void> createProduct(ProductModel product) async {
    await _firestore.collection('products').add(product.toMap());
  }

  Future<void> updateProduct(String id, Map<String, dynamic> data) async {
    data['updatedAt'] = FieldValue.serverTimestamp();
    await _firestore.collection('products').doc(id).update(data);
  }

  Future<void> deactivateProduct(String id) async {
    await updateProduct(id, {'isActive': false});
  }
}

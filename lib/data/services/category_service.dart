import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category_model.dart';

class CategoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<CategoryModel>> getCategories() {
    return _firestore
        .collection('categories')
        .orderBy('displayOrder', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => CategoryModel.fromFirestore(doc))
          .toList();
    });
  }

  // ─── ADMIN CRUD ──────────────────────────────────────────────

  Future<void> createCategory(CategoryModel category) async {
    await _firestore.collection('categories').add(category.toMap());
  }

  Future<void> updateCategory(String catId, Map<String, dynamic> data) async {
    final catRef = _firestore.collection('categories').doc(catId);

    // Si se actualiza el nombre, hacer batch write para denormalización
    if (data.containsKey('nombre')) {
      final newName = data['nombre'] as String;
      final batch = _firestore.batch();

      batch.update(catRef, data);

      final products = await _firestore
          .collection('products')
          .where('categoriaId', isEqualTo: catId)
          .get();

      for (final doc in products.docs) {
        batch.update(doc.reference, {'categoriaNombre': newName});
      }

      await batch.commit();
    } else {
      await catRef.update(data);
    }
  }

  Future<void> deleteCategory(String catId) async {
    // Podríamos requerir que no tenga productos asociados primero.
    await _firestore.collection('categories').doc(catId).delete();
  }
}

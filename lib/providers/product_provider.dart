import 'package:flutter/material.dart';
import '../data/models/product_model.dart';
import '../data/models/category_model.dart';
import '../data/services/product_service.dart';
import '../data/services/category_service.dart';
import '../utils/seeder.dart';

class ProductProvider extends ChangeNotifier {
  final ProductService _productService = ProductService();
  final CategoryService _categoryService = CategoryService();

  List<ProductModel> _products = [];
  List<ProductModel> _premiumProducts = [];
  List<CategoryModel> _categories = [];
  bool _isLoading = false;

  List<ProductModel> get products => _products;
  List<ProductModel> get premiumProducts => _premiumProducts;
  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;

  ProductProvider() {
    _initStreams();
  }

  void _initStreams() {
    _setLoading(true);
    _productService.getProducts().listen(
      (data) async {
        _products = data;
        if (_products.isEmpty) {
          debugPrint('No products found in Firestore. Auto-seeding database...');
          try {
            await DatabaseSeeder.seed();
            debugPrint('Auto-seeding completed.');
          } catch (e) {
            debugPrint('Auto-seeding failed: $e');
            _setLoading(false);
          }
        } else {
          _setLoading(false);
        }
      },
      onError: (error) {
        debugPrint('Error fetching products: $error');
        _setLoading(false);
      },
    );

    _productService.getPremiumProducts().listen(
      (data) {
        _premiumProducts = data;
        notifyListeners();
      },
      onError: (error) {
        debugPrint('Error fetching premium products: $error');
      },
    );

    _categoryService.getCategories().listen(
      (data) {
        _categories = data;
        notifyListeners();
      },
      onError: (error) {
        debugPrint('Error fetching categories: $error');
      },
    );
  }

  List<ProductModel> getProductsByCategory(String categoryId) {
    return _products.where((p) => p.categoriaId == categoryId).toList();
  }

  Future<List<ProductModel>> search(String query) async {
    return await _productService.searchProducts(query);
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}

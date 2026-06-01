import 'dart:async';
import 'package:flutter/material.dart';
import '../data/models/product_model.dart';
import '../data/models/category_model.dart';
import '../data/models/brand_model.dart';
import '../data/models/order_model.dart';
import '../data/models/coupon_model.dart';
import '../data/models/user_model.dart';
import '../data/models/banner_model.dart';
import '../data/services/product_service.dart';
import '../data/services/category_service.dart';
import '../data/services/order_service.dart';
import '../data/services/admin_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminProvider extends ChangeNotifier {
  final ProductService _productService = ProductService();
  final CategoryService _categoryService = CategoryService();
  final OrderService _orderService = OrderService();
  final AdminService _adminService = AdminService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<ProductModel> _allProducts = [];
  List<CategoryModel> _categories = [];
  List<OrderModel> _orders = [];
  List<UserModel> _customers = [];
  List<BannerModel> _banners = [];
  bool _isLoading = false;
  String? _error;

  List<ProductModel> get allProducts => _allProducts;
  List<CategoryModel> get categories => _categories;
  List<OrderModel> get orders => _orders;
  List<UserModel> get customers => _customers;
  List<BannerModel> get banners => _banners;
  bool get isLoading => _isLoading;
  String? get error => _error;

  final List<StreamSubscription> _subscriptions = [];

  void initStreams() {
    // Products (including inactive for admin)
    _subscriptions.add(
      _firestore.collection('products').orderBy('createdAt', descending: true).snapshots().listen((snap) {
        _allProducts = snap.docs.map((d) => ProductModel.fromFirestore(d)).toList();
        notifyListeners();
      }),
    );

    _subscriptions.add(
      _categoryService.getCategories().listen((data) {
        _categories = data;
        notifyListeners();
      }),
    );

    _subscriptions.add(
      _orderService.getAllOrders().listen((data) {
        _orders = data;
        notifyListeners();
      }),
    );

    _subscriptions.add(
      _adminService.getAllCustomers().listen((data) {
        _customers = data;
        notifyListeners();
      }),
    );

    _subscriptions.add(
      _adminService.getBanners().listen((data) {
        _banners = data;
        notifyListeners();
      }),
    );
  }

  // ── Products CRUD ────────────────────────────────────────────

  Future<void> createProduct(ProductModel product) async {
    _setLoading(true);
    try {
      await _productService.createProduct(product);
    } catch (e) {
      _error = e.toString();
    }
    _setLoading(false);
  }

  Future<void> updateProduct(String id, Map<String, dynamic> data) async {
    _setLoading(true);
    try {
      await _productService.updateProduct(id, data);
    } catch (e) {
      _error = e.toString();
    }
    _setLoading(false);
  }

  Future<void> deactivateProduct(String id) async {
    await _productService.deactivateProduct(id);
  }

  // ── Categories CRUD ──────────────────────────────────────────

  Future<void> createCategory(CategoryModel category) async {
    _setLoading(true);
    try {
      await _categoryService.createCategory(category);
    } catch (e) {
      _error = e.toString();
    }
    _setLoading(false);
  }

  Future<void> updateCategory(String catId, Map<String, dynamic> data) async {
    _setLoading(true);
    try {
      await _categoryService.updateCategory(catId, data);
    } catch (e) {
      _error = e.toString();
    }
    _setLoading(false);
  }

  // ── Orders ───────────────────────────────────────────────────

  Future<void> updateOrderStatus(String orderId, String status) async {
    await _orderService.updateOrderStatus(orderId, status);
  }

  // ── Coupons ──────────────────────────────────────────────────

  Future<void> createCoupon(CouponModel coupon) async {
    _setLoading(true);
    try {
      await _firestore.collection('coupons').doc(coupon.code).set(coupon.toMap());
    } catch (e) {
      _error = e.toString();
    }
    _setLoading(false);
  }

  Stream<List<CouponModel>> getCouponsStream() {
    return _firestore.collection('coupons').snapshots().map((snap) {
      return snap.docs.map((d) => CouponModel.fromFirestore(d)).toList();
    });
  }

  Future<void> toggleCouponActive(String code, bool isActive) async {
    await _firestore.collection('coupons').doc(code).update({'isActive': isActive});
  }

  // ── Brands ───────────────────────────────────────────────────

  Stream<List<BrandModel>> getBrandsStream() {
    return _firestore.collection('brands').snapshots().map((snap) {
      return snap.docs.map((d) => BrandModel.fromFirestore(d)).toList();
    });
  }

  Future<void> createBrand(BrandModel brand) async {
    _setLoading(true);
    try {
      await _firestore.collection('brands').add(brand.toMap());
    } catch (e) {
      _error = e.toString();
    }
    _setLoading(false);
  }

  // ── Banners ──────────────────────────────────────────────────

  Future<void> createBanner(BannerModel banner) async {
    await _adminService.createBanner(banner);
  }

  Future<void> toggleBannerActive(String id, bool isActive) async {
    await _adminService.updateBanner(id, {'isActive': isActive});
  }

  Future<void> deleteBanner(String id) async {
    await _adminService.deleteBanner(id);
  }

  // ── Stats ────────────────────────────────────────────────────

  int get totalProducts => _allProducts.length;
  int get totalOrders => _orders.length;
  int get pendingOrders => _orders.where((o) => o.estado == 'pendiente').length;
  int get totalCustomers => _customers.length;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    super.dispose();
  }
}

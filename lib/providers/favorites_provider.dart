import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/services/favorites_service.dart';

class FavoritesProvider extends ChangeNotifier {
  final FavoritesService _favoritesService = FavoritesService();

  List<String> _favoriteProductIds = [];
  StreamSubscription? _sub;

  List<String> get favoriteProductIds => _favoriteProductIds;

  FavoritesProvider() {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      _sub?.cancel();
      if (user != null) {
        _sub = _favoritesService.getFavorites(user.uid).listen((data) {
          _favoriteProductIds = data;
          notifyListeners();
        });
      } else {
        _favoriteProductIds = [];
        notifyListeners();
      }
    });
  }

  Future<void> toggleFavorite(String prodId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Optimistic update
      if (_favoriteProductIds.contains(prodId)) {
        _favoriteProductIds.remove(prodId);
      } else {
        _favoriteProductIds.add(prodId);
      }
      notifyListeners();

      await _favoritesService.toggleFavorite(user.uid, prodId);
    }
  }

  bool isFavorite(String prodId) {
    return _favoriteProductIds.contains(prodId);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/models/user_model.dart';
import '../data/services/auth_service.dart';
import '../data/services/user_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();

  User? _firebaseUser;
  UserModel? _userModel;
  String _role = 'customer';
  bool _isLoading = false;
  String? _error;

  bool get isAuthenticated => _firebaseUser != null;
  bool get isAdmin => _role == 'admin';
  bool get isLoading => _isLoading;
  String get role => _role;
  UserModel? get userModel => _userModel;
  String? get error => _error;

  AuthProvider() {
    initialize();
  }

  void initialize() {
    _authService.authStateChanges.listen((User? user) async {
      _firebaseUser = user;
      if (user != null) {
        await _fetchUserDetails(user.uid);
      } else {
        _userModel = null;
        _role = 'customer';
      }
      notifyListeners();
    });
  }

  Future<void> _fetchUserDetails(String uid) async {
    try {
      _userModel = await _userService.getUserDocument(uid);
      _role = _userModel?.rol ?? 'customer';
    } catch (e) {
      _error = e.toString();
    }
  }

  Future<bool> signIn(String email, String password) async {
    _setLoading(true);
    _error = null;
    try {
      await _authService.signInWithEmail(email, password);
      // _fetchUserDetails is called in authStateChanges listener
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _error = e.message ?? 'Error de autenticación';
      _setLoading(false);
      return false;
    } catch (e) {
      _error = 'Error inesperado: $e';
      _setLoading(false);
      return false;
    }
  }

  Future<bool> register(String email, String password, String nombre) async {
    _setLoading(true);
    _error = null;
    try {
      final credential = await _authService.registerWithEmail(email, password);
      if (credential.user != null) {
        await _userService.createUserDocument(credential.user!.uid, email, nombre);
        // User is automatically signed in, authStateChanges handles the rest
      }
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _error = e.message ?? 'Error en el registro';
      _setLoading(false);
      return false;
    } catch (e) {
      _error = 'Error inesperado: $e';
      _setLoading(false);
      return false;
    }
  }

  Future<void> signOut() async {
    _setLoading(true);
    try {
      await _authService.signOut();
      _userModel = null;
      _role = 'customer';
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';

// Auth screens
import 'features/auth/login_selector_screen.dart';
import 'features/auth/customer_login_screen.dart';
import 'features/auth/register_screen.dart';
import 'features/auth/admin_login_screen.dart';

// Client screens
import 'features/home/home_screen.dart';
import 'features/products/products_screen.dart';
import 'features/products/product_detail_screen.dart';
import 'features/cart/cart_screen.dart';
import 'features/checkout/checkout_screen.dart';
import 'features/orders/order_history_screen.dart';
import 'features/profile/profile_screen.dart';
import 'features/profile/favorites_screen.dart';
import 'features/categories/categories_screen.dart';

// Admin screens
import 'features/admin/admin_dashboard_screen.dart';
import 'features/admin/admin_products_screen.dart';
import 'features/admin/admin_categories_screen.dart';
import 'features/admin/admin_brands_screen.dart';
import 'features/admin/admin_orders_screen.dart';
import 'features/admin/admin_coupons_screen.dart';
import 'features/admin/admin_customers_screen.dart';
import 'features/admin/admin_banners_screen.dart';

class AztroBoutiqueApp extends StatefulWidget {
  const AztroBoutiqueApp({super.key});

  @override
  State<AztroBoutiqueApp> createState() => _AztroBoutiqueAppState();
}

class _AztroBoutiqueAppState extends State<AztroBoutiqueApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    final authProvider = context.read<AuthProvider>();

    _router = GoRouter(
      initialLocation: '/',
      refreshListenable: authProvider,
      redirect: (context, state) {
        final isAuth = authProvider.isAuthenticated;
        final isAdmin = authProvider.isAdmin;

        final isAuthRoute = state.matchedLocation == '/' ||
            state.matchedLocation.startsWith('/auth') ||
            state.matchedLocation == '/admin/login';

        final isAdminRoute = state.matchedLocation.startsWith('/admin') &&
            state.matchedLocation != '/admin/login';

        if (!isAuth && !isAuthRoute) return '/';
        if (isAuth && isAuthRoute) return isAdmin ? '/admin/dashboard' : '/home';
        if (isAuth && !isAdmin && isAdminRoute) return '/home';

        return null;
      },
      routes: [
        // ── AUTH ──────────────────────────────────────────────────
        GoRoute(path: '/', builder: (_, __) => const LoginSelectorScreen()),
        GoRoute(path: '/auth/login', builder: (_, __) => const CustomerLoginScreen()),
        GoRoute(path: '/auth/register', builder: (_, __) => const RegisterScreen()),
        GoRoute(path: '/admin/login', builder: (_, __) => const AdminLoginScreen()),

        // ── CLIENT ───────────────────────────────────────────────
        GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
        GoRoute(
          path: '/products',
          builder: (_, state) => ProductsScreen(
            initialCategoryId: state.uri.queryParameters['category'],
          ),
        ),
        GoRoute(
          path: '/products/:id',
          builder: (_, state) => ProductDetailScreen(productId: state.pathParameters['id']!),
        ),
        GoRoute(path: '/categories', builder: (_, __) => const CategoriesScreen()),
        GoRoute(path: '/cart', builder: (_, __) => const CartScreen()),
        GoRoute(path: '/checkout', builder: (_, __) => const CheckoutScreen()),
        GoRoute(path: '/orders', builder: (_, __) => const OrderHistoryScreen()),
        GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
        GoRoute(path: '/favorites', builder: (_, __) => const FavoritesScreen()),

        // ── ADMIN ────────────────────────────────────────────────
        GoRoute(path: '/admin/dashboard', builder: (_, __) => const AdminDashboardScreen()),
        GoRoute(path: '/admin/products', builder: (_, __) => const AdminProductsScreen()),
        GoRoute(path: '/admin/categories', builder: (_, __) => const AdminCategoriesScreen()),
        GoRoute(path: '/admin/brands', builder: (_, __) => const AdminBrandsScreen()),
        GoRoute(path: '/admin/orders', builder: (_, __) => const AdminOrdersScreen()),
        GoRoute(path: '/admin/coupons', builder: (_, __) => const AdminCouponsScreen()),
        GoRoute(path: '/admin/customers', builder: (_, __) => const AdminCustomersScreen()),
        GoRoute(path: '/admin/banners', builder: (_, __) => const AdminBannersScreen()),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Aztro Boutique',
      theme: AppTheme.lightTheme,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import 'logout_dialog.dart';

class AdminDrawer extends StatelessWidget {
  const AdminDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: AppColors.primary),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Icon(Icons.admin_panel_settings, color: AppColors.textOnDark, size: 48),
                const SizedBox(height: 8),
                Text(
                  'Aztro Boutique',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.textOnDark),
                ),
                Text(
                  'Panel de Administración',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textOnDark),
                ),
              ],
            ),
          ),
          _drawerTile(context, Icons.dashboard, 'Dashboard', () => context.go('/admin/dashboard')),
          _drawerTile(context, Icons.inventory_2_outlined, 'Productos', () => context.go('/admin/products')),
          _drawerTile(context, Icons.category_outlined, 'Categorías', () => context.go('/admin/categories')),
          _drawerTile(context, Icons.store_outlined, 'Marcas', () => context.go('/admin/brands')),
          _drawerTile(context, Icons.receipt_long_outlined, 'Pedidos', () => context.go('/admin/orders')),
          _drawerTile(context, Icons.local_offer_outlined, 'Cupones', () => context.go('/admin/coupons')),
          _drawerTile(context, Icons.people_outline, 'Clientes', () => context.go('/admin/customers')),
          _drawerTile(context, Icons.image_outlined, 'Banners', () => context.go('/admin/banners')),
          const Divider(),
          _drawerTile(context, Icons.logout, 'Cerrar Sesión', () {
            Navigator.of(context).pop();
            showDialog(context: context, builder: (_) => const LogoutDialog());
          }),
        ],
      ),
    );
  }

  ListTile _drawerTile(BuildContext context, IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        Navigator.of(context).pop();
        onTap();
      },
    );
  }
}

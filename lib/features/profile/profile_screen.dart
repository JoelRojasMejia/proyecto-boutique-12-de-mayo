import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../shared/widgets/custom_bottom_nav_bar.dart';
import '../../shared/widgets/logout_dialog.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.userModel;

    return Scaffold(
      appBar: AppBar(title: const Text('Mi Perfil')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            CircleAvatar(
              radius: 48,
              backgroundColor: AppColors.primaryLight,
              child: Text(
                (user?.nombre.isNotEmpty == true) ? user!.nombre[0].toUpperCase() : '?',
                style: const TextStyle(fontSize: 36, color: AppColors.textOnDark),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              user?.nombre ?? 'Usuario',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 4),
            Text(
              user?.email ?? '',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 32),
            _ProfileTile(
              icon: Icons.shopping_bag_outlined,
              title: 'Mis Pedidos',
              onTap: () => context.push('/orders'),
            ),
            _ProfileTile(
              icon: Icons.favorite_border,
              title: 'Mis Favoritos',
              onTap: () => context.push('/favorites'),
            ),
            _ProfileTile(
              icon: Icons.location_on_outlined,
              title: 'Direcciones',
              onTap: () {},
            ),
            _ProfileTile(
              icon: Icons.settings_outlined,
              title: 'Configuración',
              onTap: () {},
            ),
            const SizedBox(height: 16),
            _ProfileTile(
              icon: Icons.logout,
              title: 'Cerrar sesión',
              color: AppColors.error,
              onTap: () {
                showDialog(
                  context: context,
                  builder: (ctx) => const LogoutDialog(),
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 4),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? color;

  const _ProfileTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color ?? AppColors.textPrimary),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: color),
      ),
      trailing: Icon(Icons.chevron_right, color: color ?? AppColors.textDisabled),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}

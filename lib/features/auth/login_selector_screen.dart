import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../utils/seeder.dart';
import '../../core/constants/app_colors.dart';

class LoginSelectorScreen extends StatelessWidget {
  const LoginSelectorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Aztro Boutique',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 16),
                // BOTON TEMPORAL PARA SEEDER
                TextButton.icon(
                  onPressed: () async {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Generando datos... por favor espera')),
                    );
                    await DatabaseSeeder.seed();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Datos generados con éxito. Refresca o entra a la app.')),
                      );
                    }
                  },
                  icon: const Icon(Icons.data_array),
                  label: const Text('GENERAR DATOS DE PRUEBA'),
                  style: TextButton.styleFrom(foregroundColor: Colors.orange),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => context.push('/auth/login'),
                  icon: const Icon(Icons.shopping_bag_outlined),
                  label: const Text('INICIAR SESIÓN COMO CLIENTE'),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () => context.push('/admin/login'),
                  icon: const Icon(Icons.admin_panel_settings_outlined),
                  label: const Text('INICIAR SESIÓN COMO ADMINISTRADOR'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/banner_model.dart';
import '../../providers/admin_provider.dart';
import '../../shared/widgets/admin_drawer.dart';

class AdminBannersScreen extends StatelessWidget {
  const AdminBannersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();
    final banners = admin.banners;

    return Scaffold(
      appBar: AppBar(title: const Text('Gestión de Banners')),
      drawer: const AdminDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(context),
        child: const Icon(Icons.add),
      ),
      body: banners.isEmpty
          ? const Center(child: Text('No hay banners creados'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: banners.length,
              itemBuilder: (context, index) {
                final banner = banners[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text('Banner #${banner.displayOrder}', style: Theme.of(context).textTheme.titleMedium),
                    subtitle: Text('Redirige a: ${banner.redirectUrl}', style: Theme.of(context).textTheme.bodySmall),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Switch(
                          value: banner.isActive,
                          activeTrackColor: AppColors.success,
                          onChanged: (val) => admin.toggleBannerActive(banner.bannerId, val),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: AppColors.error),
                          onPressed: () => admin.deleteBanner(banner.bannerId),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _showForm(BuildContext context) {
    final imageCtrl = TextEditingController();
    final redirectCtrl = TextEditingController();
    final orderCtrl = TextEditingController(text: '1');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nuevo Banner'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: imageCtrl, decoration: const InputDecoration(labelText: 'URL de imagen')),
              const SizedBox(height: 8),
              TextField(controller: redirectCtrl, decoration: const InputDecoration(labelText: 'URL de redirección')),
              const SizedBox(height: 8),
              TextField(controller: orderCtrl, decoration: const InputDecoration(labelText: 'Orden'), keyboardType: TextInputType.number),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              context.read<AdminProvider>().createBanner(BannerModel(
                bannerId: '',
                imageUrl: imageCtrl.text.trim(),
                redirectUrl: redirectCtrl.text.trim(),
                isActive: true,
                displayOrder: int.tryParse(orderCtrl.text) ?? 1,
              ));
              Navigator.pop(ctx);
            },
            child: const Text('Crear'),
          ),
        ],
      ),
    );
  }
}

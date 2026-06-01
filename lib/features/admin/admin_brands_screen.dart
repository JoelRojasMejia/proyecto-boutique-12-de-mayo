import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/brand_model.dart';
import '../../providers/admin_provider.dart';
import '../../shared/widgets/admin_drawer.dart';

class AdminBrandsScreen extends StatelessWidget {
  const AdminBrandsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final admin = context.read<AdminProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Gestión de Marcas')),
      drawer: const AdminDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(context),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<BrandModel>>(
        stream: admin.getBrandsStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final brands = snapshot.data!;
          if (brands.isEmpty) return const Center(child: Text('No hay marcas creadas'));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: brands.length,
            itemBuilder: (context, index) {
              final brand = brands[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(brand.nombre, style: Theme.of(context).textTheme.titleMedium),
                  subtitle: Text(brand.descripcion, style: Theme.of(context).textTheme.bodySmall, maxLines: 2),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showForm(BuildContext context) {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final logoCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nueva Marca'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nombre')),
              const SizedBox(height: 8),
              TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Descripción'), maxLines: 2),
              const SizedBox(height: 8),
              TextField(controller: logoCtrl, decoration: const InputDecoration(labelText: 'Logo URL')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              context.read<AdminProvider>().createBrand(BrandModel(
                brandId: '',
                nombre: nameCtrl.text.trim(),
                descripcion: descCtrl.text.trim(),
                logoUrl: logoCtrl.text.trim(),
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

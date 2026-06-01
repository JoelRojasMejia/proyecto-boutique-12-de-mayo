import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/category_model.dart';
import '../../providers/admin_provider.dart';
import '../../shared/widgets/admin_drawer.dart';

class AdminCategoriesScreen extends StatelessWidget {
  const AdminCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();
    final categories = admin.categories;

    return Scaffold(
      appBar: AppBar(title: const Text('Gestión de Categorías')),
      drawer: const AdminDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(context, null),
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(child: Text('${cat.displayOrder}')),
              title: Text(cat.nombre, style: Theme.of(context).textTheme.titleMedium),
              subtitle: Text('${cat.productCount} productos · slug: ${cat.slug}', style: Theme.of(context).textTheme.bodySmall),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _showForm(context, cat),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showForm(BuildContext context, CategoryModel? category) {
    final nameCtrl = TextEditingController(text: category?.nombre ?? '');
    final slugCtrl = TextEditingController(text: category?.slug ?? '');
    final orderCtrl = TextEditingController(text: category?.displayOrder.toString() ?? '0');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(category == null ? 'Nueva Categoría' : 'Editar Categoría'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nombre')),
              const SizedBox(height: 8),
              TextField(controller: slugCtrl, decoration: const InputDecoration(labelText: 'Slug')),
              const SizedBox(height: 8),
              TextField(controller: orderCtrl, decoration: const InputDecoration(labelText: 'Orden'), keyboardType: TextInputType.number),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              final admin = context.read<AdminProvider>();
              final data = {
                'nombre': nameCtrl.text.trim(),
                'slug': slugCtrl.text.trim(),
                'displayOrder': int.tryParse(orderCtrl.text) ?? 0,
              };
              if (category == null) {
                admin.createCategory(CategoryModel(
                  catId: '',
                  nombre: data['nombre'] as String,
                  slug: data['slug'] as String,
                  iconUrl: '',
                  displayOrder: data['displayOrder'] as int,
                  productCount: 0,
                ));
              } else {
                admin.updateCategory(category.catId, data);
              }
              Navigator.pop(ctx);
            },
            child: Text(category == null ? 'Crear' : 'Guardar'),
          ),
        ],
      ),
    );
  }
}

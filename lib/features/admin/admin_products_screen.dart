import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/product_model.dart';
import '../../providers/admin_provider.dart';
import '../../shared/widgets/admin_drawer.dart';

class AdminProductsScreen extends StatelessWidget {
  const AdminProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();
    final products = admin.allProducts;
    final categories = admin.categories;
    final formatCurrency = NumberFormat.currency(locale: 'es_MX', symbol: '\$');

    return Scaffold(
      appBar: AppBar(title: const Text('Gestión de Productos')),
      drawer: const AdminDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showProductForm(context, null, categories),
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              title: Text(product.nombre, style: Theme.of(context).textTheme.titleMedium),
              subtitle: Text(
                '${product.categoriaNombre} · ${formatCurrency.format(product.precio)} · Stock: ${product.stock}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: product.isActive ? AppColors.successLight : AppColors.errorLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      product.isActive ? 'Activo' : 'Inactivo',
                      style: TextStyle(
                        fontSize: 11,
                        color: product.isActive ? AppColors.success : AppColors.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (val) {
                      if (val == 'edit') {
                        _showProductForm(context, product, categories);
                      } else if (val == 'delete') {
                        _confirmDeactivate(context, product);
                      }
                    },
                    itemBuilder: (_) => [
                      const PopupMenuItem(value: 'edit', child: Text('Editar')),
                      const PopupMenuItem(value: 'delete', child: Text('Desactivar')),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _confirmDeactivate(BuildContext context, ProductModel product) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Desactivar Producto'),
        content: Text('¿Desactivar "${product.nombre}"? Ya no será visible en el catálogo.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              context.read<AdminProvider>().deactivateProduct(product.id);
              Navigator.pop(ctx);
            },
            child: const Text('Desactivar'),
          ),
        ],
      ),
    );
  }

  void _showProductForm(BuildContext context, ProductModel? product, List<dynamic> categories) {
    final nameCtrl = TextEditingController(text: product?.nombre ?? '');
    final descCtrl = TextEditingController(text: product?.descripcion ?? '');
    final priceCtrl = TextEditingController(text: product?.precio.toString() ?? '');
    final stockCtrl = TextEditingController(text: product?.stock.toString() ?? '0');
    final imageCtrl = TextEditingController(text: product?.imagenes.join(', ') ?? '');
    bool isPremium = product?.isPremium ?? false;
    String? selectedCategoryId = product?.categoriaId;
    if (selectedCategoryId != null && selectedCategoryId.isEmpty) selectedCategoryId = null;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(product == null ? 'Nuevo Producto' : 'Editar Producto'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nombre')),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Categoría'),
                  value: selectedCategoryId,
                  items: categories.map((cat) {
                    return DropdownMenuItem<String>(
                      value: cat.catId,
                      child: Text(cat.nombre),
                    );
                  }).toList(),
                  onChanged: (val) => setDialogState(() => selectedCategoryId = val),
                ),
                const SizedBox(height: 8),
                TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Descripción'), maxLines: 3),
                const SizedBox(height: 8),
                TextField(controller: priceCtrl, decoration: const InputDecoration(labelText: 'Precio'), keyboardType: TextInputType.number),
                const SizedBox(height: 8),
                TextField(controller: stockCtrl, decoration: const InputDecoration(labelText: 'Stock Total'), keyboardType: TextInputType.number),
                const SizedBox(height: 8),
                TextField(controller: imageCtrl, decoration: const InputDecoration(labelText: 'URLs de imágenes (separadas por coma)')),
                const SizedBox(height: 8),
                SwitchListTile(
                  title: const Text('Premium'),
                  value: isPremium,
                  onChanged: (v) => setDialogState(() => isPremium = v),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () {
                String catNombre = '';
                if (selectedCategoryId != null) {
                  final cat = categories.firstWhere((c) => c.catId == selectedCategoryId, orElse: () => null);
                  if (cat != null) catNombre = cat.nombre;
                }

                final data = {
                  'nombre': nameCtrl.text.trim(),
                  'descripcion': descCtrl.text.trim(),
                  'precio': double.tryParse(priceCtrl.text) ?? 0,
                  'stock': int.tryParse(stockCtrl.text) ?? 0,
                  'imagenes': imageCtrl.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
                  'isPremium': isPremium,
                  'isActive': true,
                  'categoriaId': selectedCategoryId ?? '',
                  'categoriaNombre': catNombre,
                };

                final admin = context.read<AdminProvider>();
                if (product == null) {
                  data['rating'] = 0.0;
                  data['reviewCount'] = 0;
                  data['variants'] = [];
                  admin.createProduct(ProductModel(
                    id: '',
                    nombre: data['nombre'] as String,
                    descripcion: data['descripcion'] as String,
                    precio: data['precio'] as double,
                    stock: data['stock'] as int,
                    categoriaId: data['categoriaId'] as String,
                    categoriaNombre: data['categoriaNombre'] as String,
                    imagenes: data['imagenes'] as List<String>,
                    rating: 0,
                    reviewCount: 0,
                    isPremium: isPremium,
                    isActive: true,
                    variants: [],
                  ));
                } else {
                  admin.updateProduct(product.id, data);
                }
                Navigator.pop(ctx);
              },
              child: Text(product == null ? 'Crear' : 'Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}

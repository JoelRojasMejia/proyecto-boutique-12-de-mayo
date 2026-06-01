import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/coupon_model.dart';
import '../../providers/admin_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../shared/widgets/admin_drawer.dart';

class AdminCouponsScreen extends StatelessWidget {
  const AdminCouponsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final admin = context.read<AdminProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Gestión de Cupones')),
      drawer: const AdminDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCouponForm(context),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<CouponModel>>(
        stream: admin.getCouponsStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final coupons = snapshot.data!;
          if (coupons.isEmpty) return const Center(child: Text('No hay cupones creados'));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: coupons.length,
            itemBuilder: (context, index) {
              final coupon = coupons[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(coupon.code, style: Theme.of(context).textTheme.titleMedium),
                  subtitle: Text(
                    '${coupon.type == 'percentage' ? '${coupon.value.toInt()}%' : '\$${coupon.value}'} · '
                    'Min: \$${coupon.minPurchase} · '
                    'Usos: ${coupon.usedCount}/${coupon.maxUses}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  trailing: Switch(
                    value: coupon.isActive,
                    activeTrackColor: AppColors.success,
                    onChanged: (val) => admin.toggleCouponActive(coupon.code, val),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showCouponForm(BuildContext context) {
    final codeCtrl = TextEditingController();
    final valueCtrl = TextEditingController();
    final minPurchaseCtrl = TextEditingController(text: '0');
    final maxUsesCtrl = TextEditingController(text: '100');
    String type = 'percentage';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Nuevo Cupón'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: codeCtrl, decoration: const InputDecoration(labelText: 'Código'), textCapitalization: TextCapitalization.characters),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: type,
                  items: const [
                    DropdownMenuItem(value: 'percentage', child: Text('Porcentaje (%)')),
                    DropdownMenuItem(value: 'fixed', child: Text('Monto fijo (\$)')),
                  ],
                  onChanged: (v) => setDialogState(() => type = v!),
                  decoration: const InputDecoration(labelText: 'Tipo'),
                ),
                const SizedBox(height: 8),
                TextField(controller: valueCtrl, decoration: const InputDecoration(labelText: 'Valor'), keyboardType: TextInputType.number),
                const SizedBox(height: 8),
                TextField(controller: minPurchaseCtrl, decoration: const InputDecoration(labelText: 'Compra mínima'), keyboardType: TextInputType.number),
                const SizedBox(height: 8),
                TextField(controller: maxUsesCtrl, decoration: const InputDecoration(labelText: 'Máximo de usos'), keyboardType: TextInputType.number),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () {
                final coupon = CouponModel(
                  code: codeCtrl.text.trim().toUpperCase(),
                  type: type,
                  value: double.tryParse(valueCtrl.text) ?? 0,
                  minPurchase: double.tryParse(minPurchaseCtrl.text) ?? 0,
                  maxUses: int.tryParse(maxUsesCtrl.text) ?? 100,
                  usedCount: 0,
                  expiresAt: DateTime.now().add(const Duration(days: 30)),
                  isActive: true,
                );
                context.read<AdminProvider>().createCoupon(coupon);
                Navigator.pop(ctx);
              },
              child: const Text('Crear'),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/admin_provider.dart';
import '../../shared/widgets/admin_drawer.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().initStreams();
    });
  }

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel Admin'),
      ),
      drawer: const AdminDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Resumen General', style: Theme.of(context).textTheme.headlineLarge),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: _StatCard(icon: Icons.inventory_2, label: 'Productos', value: '${admin.totalProducts}', color: AppColors.primary)),
                const SizedBox(width: 16),
                Expanded(child: _StatCard(icon: Icons.receipt_long, label: 'Pedidos', value: '${admin.totalOrders}', color: AppColors.info)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _StatCard(icon: Icons.pending_actions, label: 'Pendientes', value: '${admin.pendingOrders}', color: AppColors.warning)),
                const SizedBox(width: 16),
                Expanded(child: _StatCard(icon: Icons.people, label: 'Clientes', value: '${admin.totalCustomers}', color: AppColors.success)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 12),
            Text(value, style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: color)),
            const SizedBox(height: 4),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

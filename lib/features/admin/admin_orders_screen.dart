import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/admin_provider.dart';
import '../../shared/widgets/admin_drawer.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  String _selectedFilter = 'todos';

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();
    final formatCurrency = NumberFormat.currency(locale: 'es_MX', symbol: '\$');
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    final filteredOrders = _selectedFilter == 'todos'
        ? admin.orders
        : admin.orders.where((o) => o.estado == _selectedFilter).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Gestión de Pedidos')),
      drawer: const AdminDrawer(),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: ['todos', 'pendiente', 'procesando', 'enviado', 'entregado', 'cancelado'].map((status) {
                final selected = _selectedFilter == status;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(status[0].toUpperCase() + status.substring(1)),
                    selected: selected,
                    onSelected: (_) => setState(() => _selectedFilter = status),
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: filteredOrders.length,
              itemBuilder: (context, index) {
                final order = filteredOrders[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('#${order.orderId.substring(0, 8)}', style: Theme.of(context).textTheme.titleMedium),
                            Text(formatCurrency.format(order.total), style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.primary)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        if (order.createdAt != null)
                          Text(dateFormat.format(order.createdAt!), style: Theme.of(context).textTheme.bodySmall),
                        const SizedBox(height: 8),
                        Text('${order.items.length} artículo(s)', style: Theme.of(context).textTheme.bodySmall),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Text('Estado:', style: Theme.of(context).textTheme.bodyMedium),
                            const SizedBox(width: 8),
                            Expanded(
                              child: DropdownButton<String>(
                                value: order.estado,
                                isExpanded: true,
                                underline: Container(),
                                items: ['pendiente', 'procesando', 'enviado', 'entregado', 'cancelado']
                                    .map((s) => DropdownMenuItem(value: s, child: Text(s[0].toUpperCase() + s.substring(1))))
                                    .toList(),
                                onChanged: (newStatus) {
                                  if (newStatus != null && newStatus != order.estado) {
                                    admin.updateOrderStatus(order.orderId, newStatus);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

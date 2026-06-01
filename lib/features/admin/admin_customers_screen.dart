import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';
import '../../shared/widgets/admin_drawer.dart';

class AdminCustomersScreen extends StatelessWidget {
  const AdminCustomersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();
    final customers = admin.customers;
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Scaffold(
      appBar: AppBar(title: const Text('Clientes')),
      drawer: const AdminDrawer(),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: customers.length,
        itemBuilder: (context, index) {
          final customer = customers[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                child: Text(customer.nombre.isNotEmpty ? customer.nombre[0].toUpperCase() : '?'),
              ),
              title: Text(customer.nombre, style: Theme.of(context).textTheme.titleMedium),
              subtitle: Text(
                '${customer.email} · Rol: ${customer.rol}'
                '${customer.createdAt != null ? ' · ${dateFormat.format(customer.createdAt!)}' : ''}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          );
        },
      ),
    );
  }
}

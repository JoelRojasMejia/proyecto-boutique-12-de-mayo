import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class LogoutDialog extends StatelessWidget {
  const LogoutDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('🚪 Cerrar sesión', textAlign: TextAlign.center),
      content: const Text(
        '¿Estás seguro de que deseas cerrar sesión?',
        textAlign: TextAlign.center,
      ),
      actionsAlignment: MainAxisAlignment.spaceEvenly,
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () async {
            await context.read<AuthProvider>().signOut();
            if (context.mounted) {
              Navigator.of(context).pop();
              context.go('/');
            }
          },
          child: const Text('Sí, salir'),
        ),
      ],
    );
  }
}

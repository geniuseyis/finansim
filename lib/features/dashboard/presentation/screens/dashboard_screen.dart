import 'package:flutter/material.dart';

/// Uygulamanın ana ekranı (geçici iskelet).
///
/// Faz 5'te gerçek bakiye, gelir/gider özeti ve grafiklerle doldurulacak.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Finans Takip')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              size: 72,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text('Hoş geldin 👋', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              'Dashboard Faz 5\'te hazır olacak.',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

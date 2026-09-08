import 'package:flutter/material.dart';

import 'package:flutter_tcc/core/widgets/app_empty_state.dart';

class WalletPage extends StatelessWidget {
  const WalletPage({super.key});

  @override
  Widget build(BuildContext context) {
    const empty = AppEmptyState(
      icon: Icons.account_balance_wallet_outlined,
      title: 'Carteira',
      description:
          'Seus ganhos e repasses aparecerão aqui quando esta área estiver pronta.',
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Carteira')),
      body: empty,
    );
  }
}

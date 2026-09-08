import 'package:flutter/material.dart';

import 'package:flutter_tcc/core/widgets/app_empty_state.dart';

class CertificatesPage extends StatelessWidget {
  const CertificatesPage({super.key});

  @override
  Widget build(BuildContext context) {
    const empty = AppEmptyState(
      icon: Icons.workspace_premium_outlined,
      title: 'Certificados',
      description:
          'Seus certificados aparecerão aqui quando esta área estiver pronta.',
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Certificados')),
      body: empty,
    );
  }
}

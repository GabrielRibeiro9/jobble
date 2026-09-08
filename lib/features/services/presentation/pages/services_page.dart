import 'package:flutter/material.dart';

import 'package:flutter_tcc/core/widgets/app_empty_state.dart';

class ServicesPage extends StatelessWidget {
  const ServicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    const empty = AppEmptyState(
      icon: Icons.handyman_outlined,
      title: 'Serviços',
      description:
          'Seus serviços aparecerão aqui quando esta área estiver pronta.',
    );

    return empty;
  }
}

import 'package:flutter/material.dart';

import 'package:flutter_tcc/core/widgets/app_empty_state.dart';

class ReviewsPage extends StatelessWidget {
  const ReviewsPage({super.key});

  @override
  Widget build(BuildContext context) {
    const empty = AppEmptyState(
      icon: Icons.star_outline_rounded,
      title: 'Avaliações',
      description:
          'As avaliações dos seus clientes aparecerão aqui quando esta área estiver pronta.',
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Avaliações')),
      body: empty,
    );
  }
}

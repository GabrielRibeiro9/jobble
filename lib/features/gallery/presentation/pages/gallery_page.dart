import 'package:flutter/material.dart';

import 'package:flutter_tcc/core/widgets/app_empty_state.dart';

class GalleryPage extends StatelessWidget {
  const GalleryPage({super.key});

  @override
  Widget build(BuildContext context) {
    const empty = AppEmptyState(
      icon: Icons.photo_library_outlined,
      title: 'Galeria',
      description:
          'Suas fotos de trabalho aparecerão aqui quando esta área estiver pronta.',
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Galeria')),
      body: empty,
    );
  }
}

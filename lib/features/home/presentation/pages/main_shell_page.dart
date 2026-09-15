import 'package:flutter/material.dart';
import 'package:flutter_tcc/core/theme/app_colors.dart';
import 'package:flutter_tcc/core/theme/app_typography.dart';
import 'package:flutter_tcc/core/widgets/main_bottom_nav_bar.dart';
import 'package:flutter_tcc/features/bids/presentation/pages/jobs_page.dart';
import 'package:flutter_tcc/features/contracts/presentation/pages/contracts_list_page.dart';
import 'package:flutter_tcc/features/home/presentation/pages/dashboard_page.dart';
import 'package:flutter_tcc/features/home/presentation/pages/settings_center_page.dart';
import 'package:flutter_tcc/features/profile/presentation/pages/profile_page.dart';

/// Casca do app profissional: Início, Serviços, Contratos, Ajustes e Perfil.
///
/// As mensagens saíram das abas: viraram um botão na home, onde ficam as
/// pendências que elas anunciam.
class MainShellPage extends StatefulWidget {
  final int initialTab;

  const MainShellPage({super.key, this.initialTab = 0});

  @override
  State<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends State<MainShellPage> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTab;
  }

  void _select(int index) {
    if (index != _currentIndex) setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: [
              HomeDashboardPage(onOpenTab: _select),
              const JobsPage(),
              const ContractsListPage(embedded: true),
              const SettingsCenterPage(),
              const ProfilePage(),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: MainBottomNavBar(
              currentIndex: _currentIndex,
              onItemSelected: _select,
            ),
          ),
        ],
      ),
    );
  }

  /// Título e descritor por aba — o descritor em itálico sob o título é a
  /// assinatura das telas de topo do sistema. A home traz o próprio
  /// cabeçalho, então nessa aba não há AppBar.
  static const _titles = <int, (String, String)>{
    1: ('Serviços', 'Seus trabalhos, do chamado à conclusão.'),
    2: ('Contratos', 'O que foi combinado com cada cliente.'),
    3: ('Configurações', 'Ajuste como você trabalha no Jobble.'),
    4: ('Perfil', 'Como os clientes veem você.'),
  };

  PreferredSizeWidget? _buildAppBar() {
    final entry = _titles[_currentIndex];
    if (entry == null) return null;
    final (title, descriptor) = entry;

    return AppBar(
      toolbarHeight: 68,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, style: AppTypography.h2),
          const SizedBox(height: 2),
          Text(
            descriptor,
            style: AppTypography.descriptor.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

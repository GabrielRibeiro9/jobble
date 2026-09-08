import 'package:flutter/material.dart';
import 'package:flutter_tcc/core/widgets/main_bottom_nav_bar.dart';
import 'package:flutter_tcc/features/home/presentation/pages/home_page.dart';
import 'package:flutter_tcc/features/schedule/presentation/pages/schedule_page.dart';
import 'package:flutter_tcc/features/home/presentation/pages/inbox_page.dart';
import 'package:flutter_tcc/features/home/presentation/pages/settings_center_page.dart';
import 'package:flutter_tcc/features/profile/presentation/pages/profile_page.dart';

class MainShellPage extends StatefulWidget {
  final int initialTab;

  const MainShellPage({super.key, this.initialTab = 0});

  @override
  State<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends State<MainShellPage> {
  late int _currentIndex;

  final List<Widget> _pages = const [
    HomePage(),
    SchedulePage(),
    InboxPage(),
    SettingsCenterPage(),
    ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTab;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: _pages,
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: MainBottomNavBar(
              currentIndex: _currentIndex,
              onItemSelected: (index) {
                if (index != _currentIndex) {
                  setState(() => _currentIndex = index);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Título por aba. A Home traz o próprio cabeçalho sobre o mapa, então
  /// nessa aba não há AppBar.
  static const _titles = <int, String>{
    1: 'Agenda',
    2: 'Mensagens',
    3: 'Configurações',
    4: 'Perfil',
  };

  PreferredSizeWidget? _buildAppBar() {
    final title = _titles[_currentIndex];
    if (title == null) return null;
    return AppBar(title: Text(title));
  }
}

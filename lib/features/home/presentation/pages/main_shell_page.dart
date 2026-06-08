import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_tcc/core/widgets/main_bottom_nav_bar.dart';
import 'package:flutter_tcc/core/theme/app_colors.dart';
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
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: _buildAppBar(colors),
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

  PreferredSizeWidget? _buildAppBar(AppColorsTheme colors) {
    switch (_currentIndex) {
      case 1:
        return AppBar(
          backgroundColor: colors.surface,
          elevation: 0,
          centerTitle: true,
          title: Text(
            'Minha Agenda',
            style: TextStyle(
              color: colors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Divider(
              height: 1,
              thickness: 1,
              color: colors.border.withValues(alpha: 0.5),
            ),
          ),
        );
      case 2:
        return AppBar(
          backgroundColor: colors.surface,
          elevation: 0,
          centerTitle: true,
          title: Text(
            'Notificações',
            style: TextStyle(
              color: colors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Divider(
              height: 1,
              thickness: 1,
              color: colors.border.withValues(alpha: 0.5),
            ),
          ),
        );
      case 3:
        return AppBar(
          backgroundColor: colors.background,
          elevation: 0,
          actions: [
            IconButton(
              icon: Icon(LucideIcons.bell, color: colors.textPrimary),
              onPressed: () {},
            ),
          ],
        );
      default:
        return null;
    }
  }
}

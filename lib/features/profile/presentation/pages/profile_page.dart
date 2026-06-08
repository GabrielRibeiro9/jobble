import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tcc/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_tcc/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_tcc/core/theme/app_colors.dart';
import 'package:flutter_tcc/core/widgets/profile_avatar.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _userName = 'Rafael Pereira';
  String _userSpecialty = 'Eletricista Residencial';
  String _userRegion = 'São Paulo, SP';

  @override
  Widget build(BuildContext context) {
    final portfolioItems = _getMockPortfolio();

    return CustomScrollView(
      slivers: [
        // App Bar com header do perfil
        SliverAppBar(
          expandedHeight: 300,
          pinned: true,
          backgroundColor: context.colors.surface,
          actions: [
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: context.colors.surface.withValues(alpha: 0.8),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.settings,
                  color: context.colors.textPrimary,
                  size: 20,
                ),
              ),
              onPressed: () => _showSettingsSheet(context),
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(background: _buildProfileHeader()),
        ),

        // Grid de portfólio
        SliverPadding(
          padding: const EdgeInsets.all(2),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 2,
              mainAxisSpacing: 2,
            ),
            delegate: SliverChildBuilderDelegate((context, index) {
              return GestureDetector(
                onTap: () => _showPortfolioDetail(portfolioItems[index]),
                child: Image.asset(
                  portfolioItems[index].imagePath,
                  fit: BoxFit.cover,
                ),
              );
            }, childCount: portfolioItems.length),
          ),
        ),
      ],
    );
  }

  // ─── HEADER ──────────────────────────────────────────────────────

  Widget _buildProfileHeader() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        String? avatarUrl;
        String name = 'Usuário';
        String email = '';

        if (state is AuthSuccess && state.user != null) {
          avatarUrl = state.user!.avatarUrl;
          name = state.user!.name ?? 'Usuário';
          email = state.user!.email;
        }

        return Container(
          color: context.colors.background,
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 32),
                // Avatar com botão de câmera
                Stack(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: const BoxDecoration(shape: BoxShape.circle),
                      child: ProfileAvatar(
                        size: 96,
                        imageUrl: avatarUrl,
                        fallbackName: name,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () => _showChangePhotoDialog(),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: context.colors.textPrimary,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.camera_alt,
                            color: context.colors.background,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  name,
                  style: TextStyle(
                    color: context.colors.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: context.colors.surface,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    email,
                    style: TextStyle(
                      color: context.colors.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.location_on,
                      color: context.colors.textSecondary,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _userRegion,
                      style: TextStyle(
                        color: context.colors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ─── PORTFÓLIO ───────────────────────────────────────────────────

  void _showPortfolioDetail(_PortfolioItem item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.colors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle
                  Center(
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 12),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: context.colors.textSecondary.withValues(
                          alpha: 0.3,
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  // Foto
                  ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          item.imagePath,
                          width: double.infinity,
                          height: 250,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: TextStyle(
                            color: context.colors.textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          item.date,
                          style: TextStyle(
                            color: context.colors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          item.description,
                          style: TextStyle(
                            color: context.colors.textSecondary,
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ─── SETTINGS SHEET ──────────────────────────────────────────────

  void _showSettingsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: context.colors.textSecondary.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Configurações do Perfil',
                  style: TextStyle(
                    color: context.colors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                _buildSettingsItem(
                  Icons.camera_alt,
                  'Alterar foto de perfil',
                  context.colors.textPrimary.withValues(alpha: 0.1),
                  () {
                    Navigator.pop(context);
                    _showChangePhotoDialog();
                  },
                ),
                _buildSettingsItem(
                  Icons.person,
                  'Editar nome e especialidade',
                  context.colors.textPrimary.withValues(alpha: 0.1),
                  () {
                    Navigator.pop(context);
                    _showEditNameDialog();
                  },
                ),
                _buildSettingsItem(
                  Icons.location_on,
                  'Alterar região de atuação',
                  context.colors.textPrimary.withValues(alpha: 0.1),
                  () {
                    Navigator.pop(context);
                    _showEditRegionDialog();
                  },
                ),
                _buildSettingsItem(
                  Icons.add_photo_alternate,
                  'Adicionar ao portfólio',
                  context.colors.textPrimary.withValues(alpha: 0.1),
                  () {
                    Navigator.pop(context);
                    _showAddPortfolioSnackbar();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSettingsItem(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: context.colors.textPrimary, size: 22),
      ),
      title: Text(
        label,
        style: TextStyle(color: context.colors.textPrimary, fontSize: 15),
      ),
      trailing: Icon(Icons.chevron_right, color: context.colors.textSecondary),
      onTap: onTap,
    );
  }

  // ─── DIALOGS ─────────────────────────────────────────────────────

  void _showChangePhotoDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: context.colors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Alterar Foto',
            style: TextStyle(color: context.colors.textPrimary),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt, color: Colors.blueAccent),
                title: Text(
                  'Tirar foto',
                  style: TextStyle(color: context.colors.textPrimary),
                ),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(this.context).showSnackBar(
                    const SnackBar(
                      content: Text('Câmera será integrada com o backend'),
                      backgroundColor: Colors.blueAccent,
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library, color: Colors.greenAccent),
                title: Text(
                  'Escolher da galeria',
                  style: TextStyle(color: context.colors.textPrimary),
                ),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(this.context).showSnackBar(
                    SnackBar(
                      content: Text('Galeria será integrada com o backend'),
                      backgroundColor: Colors.blueAccent,
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditNameDialog() {
    final nameController = TextEditingController(text: _userName);
    final specialtyController = TextEditingController(text: _userSpecialty);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: context.colors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Editar Perfil',
            style: TextStyle(color: context.colors.textPrimary),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                style: TextStyle(color: context.colors.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Nome',
                  labelStyle: TextStyle(color: context.colors.textSecondary),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: context.colors.borderLight),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.blueAccent),
                  ),
                ),
              ),
              SizedBox(height: 12),
              TextField(
                controller: specialtyController,
                style: TextStyle(color: context.colors.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Especialidade',
                  labelStyle: TextStyle(color: context.colors.textSecondary),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: context.colors.borderLight),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.blueAccent),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancelar',
                style: TextStyle(color: context.colors.textSecondary),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _userName = nameController.text;
                  _userSpecialty = specialtyController.text;
                });
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text('Salvar', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showEditRegionDialog() {
    final regionController = TextEditingController(text: _userRegion);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: context.colors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Região de Atuação',
            style: TextStyle(color: context.colors.textPrimary),
          ),
          content: TextField(
            controller: regionController,
            style: TextStyle(color: context.colors.textPrimary),
            decoration: InputDecoration(
              labelText: 'Cidade, Estado',
              labelStyle: TextStyle(color: context.colors.textSecondary),
              prefixIcon: Icon(
                Icons.location_on,
                color: context.colors.textSecondary,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: context.colors.borderLight),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.blueAccent),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancelar',
                style: TextStyle(color: context.colors.textSecondary),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _userRegion = regionController.text;
                });
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Salvar',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showAddPortfolioSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Upload de fotos será integrado com o backend'),
        backgroundColor: Colors.blueAccent,
      ),
    );
  }

  // ─── MOCK DATA ───────────────────────────────────────────────────

  List<_PortfolioItem> _getMockPortfolio() {
    return const [
      _PortfolioItem(
        title: 'Quadro Elétrico Residencial',
        date: 'Mar 2026',
        imagePath: 'assets/images/portfolio/portfolio_1.png',
        description:
            'Instalação completa de quadro elétrico com 24 circuitos, '
            'disjuntores termomagnéticos e DPS. Projeto seguindo '
            'todas as normas da NBR 5410.',
      ),
      _PortfolioItem(
        title: 'Iluminação LED Sala',
        date: 'Mar 2026',
        imagePath: 'assets/images/portfolio/portfolio_2.png',
        description:
            'Projeto de iluminação com spots LED embutidos e fita LED '
            'perimetral. Dimmerização inteligente com controle por app.',
      ),
      _PortfolioItem(
        title: 'Tomadas e Interruptores',
        date: 'Fev 2026',
        imagePath: 'assets/images/portfolio/portfolio_3.png',
        description:
            'Substituição de 15 pontos de tomada e interruptores para '
            'modelo smart com design moderno e acabamento premium.',
      ),
      _PortfolioItem(
        title: 'Iluminação Jardim',
        date: 'Fev 2026',
        imagePath: 'assets/images/portfolio/portfolio_4.png',
        description:
            'Projeto completo de iluminação paisagística com spots de '
            'piso, balizadores e refletores LED IP65.',
      ),
      _PortfolioItem(
        title: 'LED Cozinha Gourmet',
        date: 'Jan 2026',
        imagePath: 'assets/images/portfolio/portfolio_5.png',
        description:
            'Instalação de fitas LED sob bancadas e pendentes sobre '
            'ilha gourmet. Temperatura de cor 3000K para ambiente aconchegante.',
      ),
    ];
  }
}

class _PortfolioItem {
  final String title;
  final String date;
  final String imagePath;
  final String description;

  const _PortfolioItem({
    required this.title,
    required this.date,
    required this.imagePath,
    required this.description,
  });
}

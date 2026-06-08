import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
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

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  String _userName = 'Rafael Pereira';
  String _userSpecialty = 'Eletricista Residencial';
  String _userRegion = 'São Paulo, SP';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
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
              flexibleSpace: FlexibleSpaceBar(
                background: _buildProfileHeader(),
              ),
            ),

            // Tab Bar
            SliverPersistentHeader(
              pinned: true,
              delegate: _TabBarDelegate(_buildBadgeTabs()),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildPortfolioTab(),
            _buildReviewsTab(),
            _buildAboutTab(),
          ],
        ),
    );
  }

  // ─── BADGE TABS ─────────────────────────────────────────────────

  Widget _buildBadgeTabs() {
    final colors = context.colors;
    final tabs = [
      (LucideIcons.layout_dashboard, 'Portfólio'),
      (LucideIcons.star, 'Avaliações'),
      (LucideIcons.info, 'Sobre'),
    ];

    return SizedBox(
      height: kToolbarHeight,
      child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(tabs.length, (i) {
          final isActive = _tabController.index == i;
          final icon = tabs[i].$1;
          final text = tabs[i].$2;
          return Padding(
            padding: EdgeInsets.only(
              left: i > 0 ? 8 : 0,
            ),
            child: GestureDetector(
              onTap: () => _tabController.animateTo(i),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isActive ? Colors.black : Colors.white,
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                    color: isActive ? Colors.black : colors.textSecondary,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      icon,
                      size: 14,
                      color: isActive
                          ? Colors.white
                          : colors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      text,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isActive
                            ? Colors.white
                            : colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    ),
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 32),
                // Avatar com botão de câmera
                Stack(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                      ),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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

  // ─── PORTFÓLIO TAB ───────────────────────────────────────────────

  Widget _buildPortfolioTab() {
    final portfolioItems = _getMockPortfolio();
    return Padding(
      padding: const EdgeInsets.all(12),
      child: GridView.builder(
        padding: EdgeInsets.zero,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.85,
        ),
        itemCount: portfolioItems.length,
        itemBuilder: (context, index) {
          return _buildPortfolioCard(portfolioItems[index]);
        },
      ),
    );
  }

  Widget _buildPortfolioCard(_PortfolioItem item) {
    return GestureDetector(
      onTap: () => _showPortfolioDetail(item),
      child: Container(
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(item.imagePath, fit: BoxFit.cover),
                  // Gradient overlay
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            context.colors.background.withValues(alpha: 0.8),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: TextStyle(
                      color: context.colors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2),
                  Text(
                    item.date,
                    style: TextStyle(
                      color: context.colors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

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
                        color: context.colors.textSecondary.withValues(alpha: 0.3),
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

  // ─── AVALIAÇÕES TAB ──────────────────────────────────────────────

  Widget _buildReviewsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Rating summary
        _buildRatingSection(),
        const SizedBox(height: 20),
        // Reviews list
        ..._getMockReviews().map(_buildReviewCard),
      ],
    );
  }

  Widget _buildRatingSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Column(
            children: [
              Text(
                '4.8',
                style: TextStyle(
                  color: context.colors.textPrimary,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  height: 1,
                ),
              ),
              SizedBox(height: 8),
              _buildStarRow(4.8, size: 20),
              SizedBox(height: 4),
              Text(
                '127 avaliações',
                style: TextStyle(color: context.colors.textSecondary, fontSize: 12),
              ),
            ],
          ),
          SizedBox(width: 24),
          Expanded(
            child: Column(
              children: [
                _buildRatingBar(5, 0.78),
                SizedBox(height: 6),
                _buildRatingBar(4, 0.15),
                SizedBox(height: 6),
                _buildRatingBar(3, 0.05),
                SizedBox(height: 6),
                _buildRatingBar(2, 0.01),
                SizedBox(height: 6),
                _buildRatingBar(1, 0.01),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingBar(int stars, double percentage) {
    return Row(
      children: [
        Text(
          '$stars',
          style: TextStyle(
            color: context.colors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage,
              minHeight: 6,
              backgroundColor: context.colors.surfaceLight,
              valueColor: AlwaysStoppedAnimation<Color>(context.colors.ratingStar),
            ),
          ),
        ),
        SizedBox(width: 8),
        SizedBox(
          width: 36,
          child: Text(
            '${(percentage * 100).toInt()}%',
            style: TextStyle(
              color: context.colors.textSecondary,
              fontSize: 11,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStarRow(double rating, {double size = 16}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        if (index < rating.floor()) {
          return Icon(Icons.star, color: context.colors.ratingStar, size: size);
        } else if (index < rating) {
          return Icon(Icons.star_half, color: context.colors.ratingStar, size: size);
        } else {
          return Icon(Icons.star_border, color: context.colors.ratingStar, size: size);
        }
      }),
    );
  }

  Widget _buildReviewCard(_ReviewData review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: context.colors.surface,
                child: Text(
                  review.initials,
                  style: TextStyle(
                    color: context.colors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.name,
                      style: TextStyle(
                        color: context.colors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        _buildStarRow(review.rating.toDouble(), size: 14),
                        const SizedBox(width: 8),
                        Text(
                          review.date,
                          style: TextStyle(
                            color: context.colors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            review.service,
            style: TextStyle(
              color: context.colors.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            review.comment,
            style: TextStyle(
              color: context.colors.textSecondary,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          // Foto do serviço no review
          if (review.servicePhoto != null) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                review.servicePhoto!,
                width: double.infinity,
                height: 160,
                fit: BoxFit.cover,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ─── SOBRE TAB ───────────────────────────────────────────────────

  Widget _buildAboutTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Estatísticas
        _buildStatsSection(),
        const SizedBox(height: 20),

        // Info cards
        _buildInfoCard(
          Icons.location_on,
          'Região de Atuação',
          _userRegion,
          context.colors.textPrimary.withValues(alpha: 0.1),
        ),
        const SizedBox(height: 12),
        _buildInfoCard(
          Icons.access_time,
          'Membro desde',
          'Janeiro 2024',
          context.colors.textPrimary.withValues(alpha: 0.1),
        ),
        const SizedBox(height: 12),
        _buildInfoCard(
          Icons.verified,
          'Verificação',
          'Documentos verificados ✓',
          context.colors.textPrimary.withValues(alpha: 0.1),
        ),
        const SizedBox(height: 12),
        _buildInfoCard(
          Icons.description,
          'Sobre mim',
          'Eletricista com mais de 8 anos de experiência em '
              'instalações residenciais e comerciais. Especialista em '
              'iluminação LED, quadros elétricos e manutenção preventiva.',
          context.colors.textPrimary.withValues(alpha: 0.1),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildStatsSection() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            Icons.assignment_turned_in,
            '243',
            'Serviços',
            context.colors.success,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            Icons.timer,
            '< 5 min',
            'Resposta',
            context.colors.warning,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            Icons.check_circle,
            '94%',
            'Aceitação',
            context.colors.info,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              color: context.colors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: context.colors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    IconData icon,
    String title,
    String value,
    Color iconColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: context.colors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: context.colors.textPrimary,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
                leading: Icon(
                  Icons.photo_library,
                  color: Colors.greenAccent,
                ),
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
              child: Text(
                'Salvar',
                style: TextStyle(color: Colors.white),
              ),
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

  List<_ReviewData> _getMockReviews() {
    return const [
      _ReviewData(
        name: 'Maria Silva',
        initials: 'MS',
        rating: 5,
        date: '22 Mar 2026',
        service: 'Instalação Elétrica',
        comment:
            'Excelente profissional! Chegou no horário, fez o serviço com '
            'muita qualidade e deixou tudo organizado. Super recomendo!',
        servicePhoto: 'assets/images/portfolio/portfolio_1.png',
      ),
      _ReviewData(
        name: 'João Santos',
        initials: 'JS',
        rating: 5,
        date: '18 Mar 2026',
        service: 'Troca de Disjuntor',
        comment:
            'Muito atencioso e competente. Explicou tudo que estava fazendo '
            'e ainda deu dicas de manutenção. Preço justo.',
      ),
      _ReviewData(
        name: 'Ana Oliveira',
        initials: 'AO',
        rating: 4,
        date: '15 Mar 2026',
        service: 'Reparo de Tomadas',
        comment:
            'Bom serviço, resolveu o problema rapidamente. Só demorou um '
            'pouco para chegar, mas o trabalho foi excelente.',
        servicePhoto: 'assets/images/portfolio/portfolio_3.png',
      ),
      _ReviewData(
        name: 'Carlos Lima',
        initials: 'CL',
        rating: 5,
        date: '10 Mar 2026',
        service: 'Projeto de Iluminação',
        comment:
            'Profissional incrível! Fez todo o projeto de iluminação da '
            'minha sala e ficou perfeito. Trabalho impecável.',
        servicePhoto: 'assets/images/portfolio/portfolio_2.png',
      ),
      _ReviewData(
        name: 'Fernanda Costa',
        initials: 'FC',
        rating: 5,
        date: '5 Mar 2026',
        service: 'Manutenção Geral',
        comment:
            'Já é a terceira vez que contrato e nunca decepciona. '
            'Pontual, educado e o serviço sempre de primeira.',
      ),
    ];
  }
}

// ─── DATA MODELS ─────────────────────────────────────────────────

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  _TabBarDelegate(this.child);

  @override
  double get minExtent => kToolbarHeight;
  @override
  double get maxExtent => kToolbarHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: context.colors.background, child: child);
  }

  @override
  bool shouldRebuild(covariant _TabBarDelegate oldDelegate) => true;
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

class _ReviewData {
  final String name;
  final String initials;
  final int rating;
  final String date;
  final String service;
  final String comment;
  final String? servicePhoto;

  const _ReviewData({
    required this.name,
    required this.initials,
    required this.rating,
    required this.date,
    required this.service,
    required this.comment,
    this.servicePhoto,
  });
}

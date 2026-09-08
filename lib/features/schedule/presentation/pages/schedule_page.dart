import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_tcc/core/theme/app_colors.dart';
import 'package:flutter_tcc/core/theme/app_spacing.dart';
import 'package:flutter_tcc/core/theme/app_typography.dart';
import 'package:flutter_tcc/core/widgets/app_empty_state.dart';
import 'package:flutter_tcc/core/widgets/app_status_chip.dart';

enum AppointmentStatus { pending, confirmed, completed, cancelled }

class Appointment {
  final String id;
  final String clientName;
  final String serviceName;
  final DateTime date;
  final String startTime;
  final String endTime;
  final String price;
  final AppointmentStatus status;
  final String address;

  Appointment({
    required this.id,
    required this.clientName,
    required this.serviceName,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.price,
    required this.status,
    required this.address,
  });
}

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  late DateTime _selectedDate;
  late List<DateTime> _currentWeek;
  final List<Appointment> _allAppointments = [];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
    _generateWeek(now);
    _generateMockData(now);
  }

  void _generateWeek(DateTime referenceDate) {
    // Generate 7 days centered on the reference date or starting from today
    // Let's make it start 3 days before today and end 3 days after today
    // Or simpler: generate 14 days, starting from 3 days ago.
    _currentWeek = List.generate(14, (index) {
      return referenceDate.subtract(const Duration(days: 3)).add(Duration(days: index));
    });
  }

  void _generateMockData(DateTime today) {
    _allAppointments.addAll([
      Appointment(
        id: '1',
        clientName: 'Roberto Almeida',
        serviceName: 'Elétrica Residencial',
        date: DateTime(today.year, today.month, today.day),
        startTime: '09:00',
        endTime: '11:00',
        price: 'R\$ 150,00',
        status: AppointmentStatus.completed,
        address: 'Rua das Laranjeiras, 125, Centro',
      ),
      Appointment(
        id: '1b',
        clientName: 'Marcos Costa',
        serviceName: 'Instalação de Tomadas',
        date: DateTime(today.year, today.month, today.day),
        startTime: '13:00',
        endTime: '14:30',
        price: 'R\$ 85,00',
        status: AppointmentStatus.confirmed,
        address: 'Av. Paulista, 1500, Bela Vista',
      ),
      Appointment(
        id: '2',
        clientName: 'Carla Nogueira',
        serviceName: 'Instalação de Disjuntor',
        date: DateTime(today.year, today.month, today.day).add(const Duration(days: 1)),
        startTime: '14:00',
        endTime: '15:30',
        price: 'R\$ 120,00',
        status: AppointmentStatus.confirmed,
        address: 'Rua Augusta, 456, Jardins',
      ),
      Appointment(
        id: '3',
        clientName: 'Julio Cesar',
        serviceName: 'Troca de Fiação',
        date: DateTime(today.year, today.month, today.day).add(const Duration(days: 2)),
        startTime: '10:00',
        endTime: '12:00',
        price: 'R\$ 200,00',
        status: AppointmentStatus.pending,
        address: 'Rua do Ouvidor, 55, Pinheiros',
      ),
      Appointment(
        id: '4',
        clientName: 'Ana Clara',
        serviceName: 'Orçamento Hidráulico',
        date: DateTime(today.year, today.month, today.day).subtract(const Duration(days: 1)),
        startTime: '16:00',
        endTime: '17:00',
        price: 'R\$ 50,00',
        status: AppointmentStatus.cancelled,
        address: 'Alameda Santos, 98, Paraíso',
      ),
    ]);
    
    // Sort by time (simple simulation)
    _allAppointments.sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  bool _isSameDay(DateTime d1, DateTime d2) {
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }

  String _getShortWeekday(int weekday) {
    const days = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];
    return days[weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    final dailyAppointments = _allAppointments.where((app) => _isSameDay(app.date, _selectedDate)).toList();

    return Column(
      children: [
        _buildWeekTracker(),
        Expanded(
          child: _buildAppointmentsList(dailyAppointments),
        ),
      ],
    );
  }

  /// Faixa de dias. O dia selecionado é um bloco em lima; o dia de hoje leva
  /// um ponto abaixo do número, para os dois estados serem distinguíveis
  /// mesmo quando coincidem.
  Widget _buildWeekTracker() {
    final colors = context.colors;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenH,
        AppSpacing.md,
        AppSpacing.screenH,
        AppSpacing.md,
      ),
      child: Row(
        children: _currentWeek.map((date) {
          final isSelected = _isSameDay(date, _selectedDate);
          final isToday = _isSameDay(date, DateTime.now());
          final foreground = isSelected
              ? colors.onPrimary
              : colors.textPrimary;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedDate = DateTime(date.year, date.month, date.day);
              });
            },
            child: AnimatedContainer(
              duration: AppDuration.normal,
              curve: Curves.easeOut,
              margin: const EdgeInsets.only(right: AppSpacing.xs),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: isSelected ? colors.primary : colors.surface,
                borderRadius: AppRadius.mdAll,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _getShortWeekday(date.weekday).toUpperCase(),
                    style: AppTypography.overline.copyWith(
                      color: isSelected
                          ? colors.onPrimary
                          : colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    date.day.toString().padLeft(2, '0'),
                    style: AppTypography.h3.copyWith(color: foreground),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: isToday ? foreground : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAppointmentsList(List<Appointment> appointments) {
    if (appointments.isEmpty) {
      return const AppEmptyState(
        icon: LucideIcons.calendar_x,
        title: 'Nada agendado',
        description: 'Você não tem serviços marcados para este dia.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenH,
        0,
        AppSpacing.screenH,
        // Espaço para a barra de navegação flutuante.
        120,
      ),
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        return _buildAppointmentCard(appointments[index]);
      },
    );
  }

  Widget _buildAppointmentCard(Appointment appointment) {
    final colors = context.colors;

    final (statusColor, statusText) = switch (appointment.status) {
      AppointmentStatus.pending => (colors.warning, 'Pendente'),
      AppointmentStatus.confirmed => (colors.primary, 'Confirmado'),
      AppointmentStatus.completed => (colors.success, 'Concluído'),
      AppointmentStatus.cancelled => (colors.error, 'Cancelado'),
    };

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadius.lgAll,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointment.serviceName,
                      style: AppTypography.title.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      appointment.clientName,
                      style: AppTypography.bodySmall.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              AppStatusChip(label: statusText, color: statusColor),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Divider(height: 1, color: colors.borderLight),
          const SizedBox(height: AppSpacing.md),
          AppMetaRow(
            icon: LucideIcons.clock,
            text: '${appointment.startTime} — ${appointment.endTime}',
            emphasized: true,
            trailing: Text(
              appointment.price,
              style: AppTypography.title.copyWith(color: colors.textPrimary),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          AppMetaRow(
            icon: LucideIcons.map_pin,
            text: appointment.address,
          ),
        ],
      ),
    );
  }
}

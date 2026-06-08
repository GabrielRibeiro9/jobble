import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_tcc/core/theme/app_colors.dart';

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

  Widget _buildWeekTracker() {
    return Container(
      color: context.colors.surface,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: _currentWeek.map((date) {
            final isSelected = _isSameDay(date, _selectedDate);
            final isToday = _isSameDay(date, DateTime.now());

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedDate = DateTime(date.year, date.month, date.day);
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? context.colors.themePrimary : context.colors.surfaceLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? context.colors.themePrimary : context.colors.border,
                    width: isSelected ? 0 : 1,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _getShortWeekday(date.weekday).toUpperCase(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? context.colors.onPrimary : context.colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      date.day.toString().padLeft(2, '0'),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? context.colors.onPrimary : context.colors.textPrimary,
                      ),
                    ),
                    if (isToday) ...[
                      const SizedBox(height: 4),
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: isSelected ? context.colors.onPrimary : context.colors.themePrimary,
                          shape: BoxShape.circle,
                        ),
                      )
                    ]
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildAppointmentsList(List<Appointment> appointments) {
    if (appointments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.calendar_x, size: 64, color: context.colors.textHint),
            const SizedBox(height: 16),
            Text(
              'Nenhum serviço agendado para este dia.',
              style: TextStyle(
                color: context.colors.textSecondary,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        return _buildAppointmentCard(appointments[index]);
      },
    );
  }

  Widget _buildAppointmentCard(Appointment appointment) {
    Color statusColor;
    String statusText;

    switch (appointment.status) {
      case AppointmentStatus.pending:
        statusColor = context.colors.warning;
        statusText = 'Pendente';
        break;
      case AppointmentStatus.confirmed:
        statusColor = context.colors.themePrimary;
        statusText = 'Confirmado';
        break;
      case AppointmentStatus.completed:
        statusColor = context.colors.success;
        statusText = 'Concluído';
        break;
      case AppointmentStatus.cancelled:
        statusColor = context.colors.error;
        statusText = 'Cancelado';
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colors.borderLight, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointment.serviceName,
                      style: TextStyle(
                        color: context.colors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      appointment.clientName,
                      style: TextStyle(
                        color: context.colors.textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor.withValues(alpha: 0.3), width: 1),
                ),
                child: Text(
                  statusText.toUpperCase(),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(LucideIcons.clock, size: 16, color: context.colors.textSecondary),
              const SizedBox(width: 8),
              Text(
                '${appointment.startTime} - ${appointment.endTime}',
                style: TextStyle(
                  color: context.colors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                appointment.price,
                style: TextStyle(
                  color: context.colors.success,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(LucideIcons.map_pin, size: 16, color: context.colors.textSecondary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  appointment.address,
                  style: TextStyle(
                    color: context.colors.textSecondary,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

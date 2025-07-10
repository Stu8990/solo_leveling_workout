import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/user_progress.dart';
import '../services/data_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final DataService _dataService = DataService();

  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  UserProgress _userProgress = UserProgress();
  List<DateTime> _workoutDays = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWorkoutHistory();
  }

  Future<void> _loadWorkoutHistory() async {
    try {
      _userProgress = await _dataService.loadUserProgress();

      // Convertir las fechas de string a DateTime
      _workoutDays = _userProgress.completedWorkouts.map((dateString) {
        try {
          return DateTime.parse(dateString);
        } catch (e) {
          // Si el formato no es correcto, intentar otro formato
          List<String> parts = dateString.split('-');
          if (parts.length == 3) {
            return DateTime(
              int.parse(parts[0]),
              int.parse(parts[1]),
              int.parse(parts[2]),
            );
          }
          return DateTime.now();
        }
      }).toList();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading workout history: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Verificar si un día tiene entrenamiento
  bool _hasWorkout(DateTime day) {
    return _workoutDays.any((workoutDay) =>
        workoutDay.year == day.year &&
        workoutDay.month == day.month &&
        workoutDay.day == day.day);
  }

  // Calcular estadísticas del mes
  Map<String, int> _getMonthlyStats() {
    DateTime now = DateTime.now();
    DateTime firstDayOfMonth = DateTime(now.year, now.month, 1);
    DateTime lastDayOfMonth = DateTime(now.year, now.month + 1, 0);

    int workoutsThisMonth = _workoutDays
        .where((day) =>
            day.isAfter(firstDayOfMonth.subtract(const Duration(days: 1))) &&
            day.isBefore(lastDayOfMonth.add(const Duration(days: 1))))
        .length;

    int daysInMonth = lastDayOfMonth.day;
    int workoutRate = ((workoutsThisMonth / daysInMonth) * 100).round();

    return {
      'workouts': workoutsThisMonth,
      'rate': workoutRate,
      'daysInMonth': daysInMonth,
    };
  }

  // // Obtener el color del día según su estado
  // Color _getDayColor(DateTime day) {
  //   if (_hasWorkout(day)) {
  //     return const Color(0xFF10b981); // Verde para días con entrenamiento
  //   }
  //   return Colors.transparent;
  // }

  // Obtener información del día seleccionado
  Widget _buildSelectedDayInfo() {
    if (_selectedDay == null) return const SizedBox.shrink();

    bool hasWorkout = _hasWorkout(_selectedDay!);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF16213e),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasWorkout ? const Color(0xFF10b981) : Colors.grey,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                hasWorkout ? Icons.check_circle : Icons.cancel,
                color: hasWorkout ? const Color(0xFF10b981) : Colors.grey,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                '${_selectedDay!.day}/${_selectedDay!.month}/${_selectedDay!.year}',
                style: GoogleFonts.orbitron(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            hasWorkout ? '✅ Entrenamiento completado' : '❌ Sin entrenamiento',
            style: TextStyle(
              fontSize: 16,
              color: hasWorkout ? const Color(0xFF10b981) : Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (hasWorkout) ...[
            const SizedBox(height: 8),
            const Text(
              'Misión diaria cumplida con éxito',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Historial de Entrenamientos'),
          backgroundColor: const Color(0xFF1a1a2e),
        ),
        body: const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF4f46e5),
          ),
        ),
      );
    }

    Map<String, int> monthlyStats = _getMonthlyStats();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Historial de Entrenamientos',
          style: GoogleFonts.orbitron(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF1a1a2e),
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0f172a),
              Color(0xFF1a1a2e),
            ],
          ),
        ),
        child: Column(
          children: [
            // Estadísticas del mes
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF16213e),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF4f46e5),
                  width: 2,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(
                    'Entrenamientos',
                    '${monthlyStats['workouts']}',
                    Icons.fitness_center,
                    const Color(0xFF10b981),
                  ),
                  _buildStatItem(
                    'Racha Actual',
                    '${_userProgress.currentStreak}',
                    Icons.local_fire_department,
                    const Color(0xFFf59e0b),
                  ),
                  _buildStatItem(
                    'Consistencia',
                    '${monthlyStats['rate']}%',
                    Icons.trending_up,
                    const Color(0xFF06b6d4),
                  ),
                ],
              ),
            ),

            // Calendario
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF16213e),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TableCalendar<String>(
                firstDay: DateTime.utc(2024, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDay, day);
                },
                startingDayOfWeek: StartingDayOfWeek.monday,
                calendarStyle: CalendarStyle(
                  outsideDaysVisible: false,
                  weekendTextStyle: const TextStyle(color: Colors.white),
                  defaultTextStyle: const TextStyle(color: Colors.white),
                  selectedDecoration: const BoxDecoration(
                    color: Color(0xFF4f46e5),
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                    color: const Color(0xFF4f46e5).withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  markerDecoration: const BoxDecoration(
                    color: Color(0xFF10b981),
                    shape: BoxShape.circle,
                  ),
                ),
                headerStyle: HeaderStyle(
                  formatButtonVisible: true,
                  titleCentered: true,
                  formatButtonShowsNext: false,
                  formatButtonDecoration: BoxDecoration(
                    color: const Color(0xFF4f46e5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  formatButtonTextStyle: const TextStyle(
                    color: Colors.white,
                  ),
                  titleTextStyle: GoogleFonts.orbitron(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  leftChevronIcon: const Icon(
                    Icons.chevron_left,
                    color: Colors.white,
                  ),
                  rightChevronIcon: const Icon(
                    Icons.chevron_right,
                    color: Colors.white,
                  ),
                ),
                daysOfWeekStyle: const DaysOfWeekStyle(
                  weekendStyle: TextStyle(color: Colors.white),
                  weekdayStyle: TextStyle(color: Colors.white),
                ),
                onDaySelected: (selectedDay, focusedDay) {
                  if (!isSameDay(_selectedDay, selectedDay)) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  }
                },
                onFormatChanged: (format) {
                  if (_calendarFormat != format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  }
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
                eventLoader: (day) {
                  return _hasWorkout(day) ? ['workout'] : [];
                },
              ),
            ),

            // Información del día seleccionado
            _buildSelectedDayInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
      String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

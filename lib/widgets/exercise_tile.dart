import 'package:flutter/material.dart';
import '../screens/cardio_tracker_screen.dart';
import '../models/cardio_session.dart';

class ExerciseTile extends StatelessWidget {
  final String exerciseName;
  final String target;
  final String type;
  final bool isCompleted;
  final int xp;
  final VoidCallback onToggle;

  const ExerciseTile({
    super.key,
    required this.exerciseName,
    required this.target,
    required this.type,
    required this.isCompleted,
    required this.xp,
    required this.onToggle,
  });

  // Función para obtener el color según el tipo de ejercicio
  Color _getTypeColor() {
    switch (type) {
      case 'Empuje':
        return const Color(0xFFef4444); // Rojo
      case 'Jalón':
        return const Color(0xFF10b981); // Verde
      case 'Piernas':
        return const Color(0xFFf59e0b); // Amarillo
      case 'Core':
        return const Color(0xFF8b5cf6); // Morado
      case 'Cardio':
        return const Color(0xFF06b6d4); // Cian/Azul
      default:
        return const Color(0xFF6b7280); // Gris
    }
  }

  // Función para obtener el icono según el tipo de ejercicio
  IconData _getTypeIcon() {
    switch (type) {
      case 'Empuje':
        return Icons.fitness_center;
      case 'Jalón':
        return Icons.accessibility_new;
      case 'Piernas':
        return Icons.directions_run;
      case 'Core':
        return Icons.self_improvement;
      case 'Cardio':
        return Icons.directions_run;
      default:
        return Icons.fitness_center;
    }
  }

  // Manejar tap en el tile
  void _handleTileTap(BuildContext context) {
    if (type == 'Cardio' && exerciseName.toLowerCase().contains('running')) {
      // Abrir GPS tracker para cardio
      _openCardioTracker(context);
    } else {
      // Comportamiento normal para otros ejercicios
      onToggle();
    }
  }

  void _openCardioTracker(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CardioTrackerScreen(
          exerciseType: 'running',
          onSessionComplete: (CardioSession session) {
            // Al completar la sesión de cardio, marcar el ejercicio como completado
            onToggle();

            // Mostrar resumen de la sesión
            _showSessionSummary(context, session);
          },
        ),
      ),
    );
  }

  void _showSessionSummary(BuildContext context, CardioSession session) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF16213e),
        title: const Text(
          '🏃‍♂️ ¡Carrera Completada!',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryRow('Distancia:', session.formattedDistance),
            _buildSummaryRow('Tiempo:', session.formattedDuration),
            _buildSummaryRow('Pace Promedio:', session.formattedPace),
            _buildSummaryRow('Velocidad:',
                '${session.averageSpeedKmh.toStringAsFixed(1)} km/h'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF10b981).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFF10b981),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.star,
                    color: Color(0xFF10b981),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'XP ganado: +$xp',
                    style: const TextStyle(
                      color: Color(0xFF10b981),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10b981),
            ),
            child: const Text('¡Genial!'),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.grey),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isCompleted
                ? const Color(0xFF10b981)
                : _getTypeColor().withOpacity(0.3),
            width: 2,
          ),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),

          // Hacer que todo el tile sea clickeable
          onTap: () => _handleTileTap(context),

          // Icono del tipo de ejercicio
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getTypeColor().withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Stack(
              children: [
                Icon(_getTypeIcon(), color: _getTypeColor(), size: 24),
                // Indicador especial para cardio con GPS
                if (type == 'Cardio' &&
                    exerciseName.toLowerCase().contains('running'))
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: Color(0xFF10b981),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.gps_fixed,
                        size: 8,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Información del ejercicio
          title: Row(
            children: [
              Expanded(
                child: Text(
                  exerciseName,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isCompleted ? Colors.grey : Colors.white,
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
              // Indicador GPS para cardio
              if (type == 'Cardio' &&
                  exerciseName.toLowerCase().contains('running'))
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10b981).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFF10b981),
                      width: 1,
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.gps_fixed,
                        size: 12,
                        color: Color(0xFF10b981),
                      ),
                      SizedBox(width: 2),
                      Text(
                        'GPS',
                        style: TextStyle(
                          fontSize: 10,
                          color: Color(0xFF10b981),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                target,
                style: TextStyle(
                  fontSize: 14,
                  color: isCompleted ? Colors.grey : Colors.grey[300],
                ),
              ),
              const SizedBox(height: 8),

              // Etiquetas del tipo de ejercicio y XP
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getTypeColor().withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      type,
                      style: TextStyle(
                        fontSize: 12,
                        color: _getTypeColor(),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF06b6d4).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star,
                          size: 12,
                          color: Color(0xFF06b6d4),
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '+$xp XP',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF06b6d4),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Checkbox para marcar como completado
          trailing: GestureDetector(
            onTap: onToggle,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color:
                    isCompleted ? const Color(0xFF10b981) : Colors.transparent,
                border: Border.all(
                  color: isCompleted ? const Color(0xFF10b981) : Colors.grey,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: isCompleted
                  ? const Icon(Icons.check, color: Colors.white, size: 18)
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}

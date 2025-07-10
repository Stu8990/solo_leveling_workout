import 'package:flutter/material.dart';

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
      default:
        return Icons.fitness_center;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                isCompleted
                    ? const Color(0xFF10b981)
                    : _getTypeColor().withOpacity(0.3),
            width: 2,
          ),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),

          // Icono del tipo de ejercicio
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getTypeColor().withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(_getTypeIcon(), color: _getTypeColor(), size: 24),
          ),

          // Información del ejercicio
          title: Text(
            exerciseName,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isCompleted ? Colors.grey : Colors.white,
              decoration: isCompleted ? TextDecoration.lineThrough : null,
            ),
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
              child:
                  isCompleted
                      ? const Icon(Icons.check, color: Colors.white, size: 18)
                      : null,
            ),
          ),
        ),
      ),
    );
  }
}

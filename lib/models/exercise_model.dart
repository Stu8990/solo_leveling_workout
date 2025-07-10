class Exercise {
  final String id;
  final String name;
  final String type;
  final int minLevel;
  final Map<int, ExerciseLevel> levels;
  bool isCompleted;

  Exercise({
    required this.id,
    required this.name,
    required this.type,
    required this.minLevel,
    required this.levels,
    this.isCompleted = false,
  });

  // Obtener el target según el nivel del usuario
  String getTarget(int userLevel) {
    int exerciseLevel = userLevel;

    // Si el nivel del usuario es menor al mínimo requerido, usar el mínimo
    if (userLevel < minLevel) {
      exerciseLevel = minLevel;
    }

    // Si no existe ese nivel específico, usar el nivel más alto disponible
    if (!levels.containsKey(exerciseLevel)) {
      exerciseLevel = levels.keys.reduce((a, b) => a > b ? a : b);
    }

    return levels[exerciseLevel]?.target ?? 'No disponible';
  }

  // Obtener XP que da este ejercicio
  int getXP(int userLevel) {
    int exerciseLevel = userLevel;

    if (userLevel < minLevel) {
      exerciseLevel = minLevel;
    }

    if (!levels.containsKey(exerciseLevel)) {
      exerciseLevel = levels.keys.reduce((a, b) => a > b ? a : b);
    }

    return levels[exerciseLevel]?.xp ?? 10;
  }

  // Convertir a Map para guardar en SharedPreferences
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'minLevel': minLevel,
      'isCompleted': isCompleted,
    };
  }

  // Crear desde Map
  static Exercise fromJson(
    Map<String, dynamic> json,
    Map<int, ExerciseLevel> levels,
  ) {
    return Exercise(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      minLevel: json['minLevel'],
      levels: levels,
      isCompleted: json['isCompleted'] ?? false,
    );
  }
}

class ExerciseLevel {
  final String target;
  final int xp;
  final String description;

  ExerciseLevel({
    required this.target,
    required this.xp,
    required this.description,
  });
}

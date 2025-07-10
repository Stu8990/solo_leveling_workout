class UserProgress {
  int hunterLevel;
  int totalXP;
  int currentXP;
  int xpToNextLevel;
  Map<String, int> exerciseLevels; // Por tipo de ejercicio
  List<String> completedWorkouts; // Fechas de entrenamientos completados
  int currentStreak;
  DateTime? lastWorkoutDate;

  UserProgress({
    this.hunterLevel = 1,
    this.totalXP = 0,
    this.currentXP = 0,
    this.xpToNextLevel = 100,
    Map<String, int>? exerciseLevels,
    List<String>? completedWorkouts,
    this.currentStreak = 0,
    this.lastWorkoutDate,
  })  : exerciseLevels = exerciseLevels ??
            {
              'Empuje': 4, // Basado en tus 25 push-ups
              'Jalón': 3, // Basado en tus 5-7 chin-ups
              'Piernas': 3, // Nivel estimado
              'Core': 3, // Nivel estimado
              'Cardio': 4, // Basado en tus 7km
            },
        completedWorkouts = completedWorkouts ?? [];

  // Añadir XP y verificar si subió de nivel
  bool addXP(int xp) {
    totalXP += xp;
    currentXP += xp;

    if (currentXP >= xpToNextLevel) {
      return _levelUp();
    }
    return false;
  }

  // Subir de nivel
  bool _levelUp() {
    hunterLevel++;
    currentXP = currentXP - xpToNextLevel;
    xpToNextLevel = _calculateXPForNextLevel();

    // Si sobra XP, verificar si puede subir otro nivel
    if (currentXP >= xpToNextLevel) {
      return _levelUp();
    }

    return true;
  }

  // Calcular XP necesario para el siguiente nivel
  int _calculateXPForNextLevel() {
    // Fórmula progresiva: cada nivel requiere más XP
    return 100 + (hunterLevel * 25);
  }

  // Subir nivel de un tipo de ejercicio específico
  void levelUpExercise(String exerciseType) {
    if (exerciseLevels.containsKey(exerciseType)) {
      exerciseLevels[exerciseType] = exerciseLevels[exerciseType]! + 1;
    }
  }

  // Completar entrenamiento
  void completeWorkout() {
    String today = DateTime.now().toIso8601String().split('T')[0];

    if (!completedWorkouts.contains(today)) {
      completedWorkouts.add(today);
      _updateStreak();
    }

    lastWorkoutDate = DateTime.now();
  }

  // Actualizar racha de entrenamientos
  void _updateStreak() {
    DateTime now = DateTime.now();
    DateTime yesterday = now.subtract(const Duration(days: 1));
    String yesterdayStr = yesterday.toIso8601String().split('T')[0];

    if (completedWorkouts.contains(yesterdayStr) || currentStreak == 0) {
      currentStreak++;
    } else {
      currentStreak = 1; // Reiniciar racha
    }
  }

  // Convertir a Map para SharedPreferences
  Map<String, dynamic> toJson() {
    return {
      'hunterLevel': hunterLevel,
      'totalXP': totalXP,
      'currentXP': currentXP,
      'xpToNextLevel': xpToNextLevel,
      'exerciseLevels': exerciseLevels,
      'completedWorkouts': completedWorkouts,
      'currentStreak': currentStreak,
      'lastWorkoutDate': lastWorkoutDate?.toIso8601String(),
    };
  }

  // Crear desde Map
  static UserProgress fromJson(Map<String, dynamic> json) {
    // Manejar transición de formato anterior a nuevo
    Map<String, int> exerciseLevels = Map<String, int>.from(
      json['exerciseLevels'] ??
          {
            'Empuje': 4, // Niveles actualizados por defecto
            'Jalón': 3,
            'Piernas': 3,
            'Core': 3,
            'Cardio': 4,
          },
    );

    // Añadir Cardio si no existe (para usuarios existentes)
    if (!exerciseLevels.containsKey('Cardio')) {
      exerciseLevels['Cardio'] = 4; // Tu nivel actual de 7km
    }

    return UserProgress(
      hunterLevel: json['hunterLevel'] ?? 1,
      totalXP: json['totalXP'] ?? 0,
      currentXP: json['currentXP'] ?? 0,
      xpToNextLevel: json['xpToNextLevel'] ?? 100,
      exerciseLevels: exerciseLevels,
      completedWorkouts: List<String>.from(json['completedWorkouts'] ?? []),
      currentStreak: json['currentStreak'] ?? 0,
      lastWorkoutDate: json['lastWorkoutDate'] != null
          ? DateTime.parse(json['lastWorkoutDate'])
          : null,
    );
  }

  // Obtener progreso de XP como porcentaje
  double getXPProgress() {
    return currentXP / xpToNextLevel;
  }
}

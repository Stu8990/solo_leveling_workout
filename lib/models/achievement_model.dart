import 'package:flutter/material.dart';

class Achievement {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final int xpReward;
  final AchievementType type;
  final Map<String, dynamic> criteria;
  bool isUnlocked;
  DateTime? unlockedDate;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.xpReward,
    required this.type,
    required this.criteria,
    this.isUnlocked = false,
    this.unlockedDate,
  });

  // Convertir a Map para guardar
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'isUnlocked': isUnlocked,
      'unlockedDate': unlockedDate?.toIso8601String(),
    };
  }

  // Crear desde Map
  static Achievement fromJson(Map<String, dynamic> json, Achievement template) {
    return Achievement(
      id: template.id,
      title: template.title,
      description: template.description,
      icon: template.icon,
      color: template.color,
      xpReward: template.xpReward,
      type: template.type,
      criteria: template.criteria,
      isUnlocked: json['isUnlocked'] ?? false,
      unlockedDate:
          json['unlockedDate'] != null
              ? DateTime.parse(json['unlockedDate'])
              : null,
    );
  }
}

enum AchievementType {
  firstTime, // Primera vez haciendo algo
  streak, // Rachas de entrenamientos
  volume, // Cantidad total de ejercicios
  level, // Alcanzar cierto nivel
  special, // Logros especiales
}

class AchievementService {
  // Singleton pattern
  static final AchievementService _instance = AchievementService._internal();
  factory AchievementService() => _instance;
  AchievementService._internal();

  // Lista de todos los logros disponibles
  static final List<Achievement> _allAchievements = [
    // Logros de Primera Vez
    Achievement(
      id: 'first_workout',
      title: 'Primer Entrenamiento',
      description: 'Completa tu primera misión diaria',
      icon: Icons.play_arrow,
      color: const Color(0xFF10b981),
      xpReward: 50,
      type: AchievementType.firstTime,
      criteria: {'workouts_completed': 1},
    ),
    Achievement(
      id: 'first_pushup',
      title: 'Primera Flexión',
      description: 'Completa tu primer push-up',
      icon: Icons.fitness_center,
      color: const Color(0xFFef4444),
      xpReward: 25,
      type: AchievementType.firstTime,
      criteria: {'exercise_type': 'pushups', 'completed': 1},
    ),
    Achievement(
      id: 'first_pullup',
      title: 'Primera Dominada',
      description: 'Logra tu primer pull-up',
      icon: Icons.accessibility_new,
      color: const Color(0xFF10b981),
      xpReward: 75,
      type: AchievementType.firstTime,
      criteria: {'exercise_type': 'pullups', 'completed': 1},
    ),

    // Logros de Racha
    Achievement(
      id: 'streak_3',
      title: 'Cazador Consistente',
      description: 'Entrena 3 días consecutivos',
      icon: Icons.local_fire_department,
      color: const Color(0xFFf59e0b),
      xpReward: 100,
      type: AchievementType.streak,
      criteria: {'streak_days': 3},
    ),
    Achievement(
      id: 'streak_7',
      title: 'Guerrero Disciplinado',
      description: 'Entrena 7 días consecutivos',
      icon: Icons.local_fire_department,
      color: const Color(0xFFf59e0b),
      xpReward: 250,
      type: AchievementType.streak,
      criteria: {'streak_days': 7},
    ),
    Achievement(
      id: 'streak_30',
      title: 'Leyenda Viviente',
      description: 'Entrena 30 días consecutivos',
      icon: Icons.local_fire_department,
      color: const Color(0xFFfbbf24),
      xpReward: 1000,
      type: AchievementType.streak,
      criteria: {'streak_days': 30},
    ),

    // Logros de Nivel
    Achievement(
      id: 'level_5',
      title: 'Rango E',
      description: 'Alcanza el nivel 5 de cazador',
      icon: Icons.military_tech,
      color: const Color(0xFF8b5cf6),
      xpReward: 200,
      type: AchievementType.level,
      criteria: {'hunter_level': 5},
    ),
    Achievement(
      id: 'level_10',
      title: 'Rango D',
      description: 'Alcanza el nivel 10 de cazador',
      icon: Icons.military_tech,
      color: const Color(0xFF8b5cf6),
      xpReward: 500,
      type: AchievementType.level,
      criteria: {'hunter_level': 10},
    ),
    Achievement(
      id: 'level_20',
      title: 'Rango C',
      description: 'Alcanza el nivel 20 de cazador',
      icon: Icons.military_tech,
      color: const Color(0xFF6366f1),
      xpReward: 1000,
      type: AchievementType.level,
      criteria: {'hunter_level': 20},
    ),

    // Logros de Volumen
    Achievement(
      id: 'total_100',
      title: 'Veterano',
      description: 'Completa 100 ejercicios en total',
      icon: Icons.emoji_events,
      color: const Color(0xFF06b6d4),
      xpReward: 300,
      type: AchievementType.volume,
      criteria: {'total_exercises': 100},
    ),
    Achievement(
      id: 'total_500',
      title: 'Maestro del Entrenamiento',
      description: 'Completa 500 ejercicios en total',
      icon: Icons.emoji_events,
      color: const Color(0xFF06b6d4),
      xpReward: 750,
      type: AchievementType.volume,
      criteria: {'total_exercises': 500},
    ),

    // Logros Especiales
    Achievement(
      id: 'perfect_week',
      title: 'Semana Perfecta',
      description: 'Completa todos los ejercicios 7 días seguidos',
      icon: Icons.star,
      color: const Color(0xFFfbbf24),
      xpReward: 500,
      type: AchievementType.special,
      criteria: {'perfect_days': 7},
    ),
    Achievement(
      id: 'night_owl',
      title: 'Búho Nocturno',
      description: 'Entrena después de las 10 PM',
      icon: Icons.nightlight,
      color: const Color(0xFF4c1d95),
      xpReward: 50,
      type: AchievementType.special,
      criteria: {'night_workout': true},
    ),
  ];

  // Obtener todos los logros
  List<Achievement> getAllAchievements() {
    return List.from(_allAchievements);
  }

  // Verificar logros según el progreso del usuario
  List<Achievement> checkForNewAchievements(
    Map<String, dynamic> userStats,
    List<Achievement> currentAchievements,
  ) {
    List<Achievement> newAchievements = [];

    for (Achievement template in _allAchievements) {
      // Buscar si ya está desbloqueado
      Achievement? current =
          currentAchievements.where((a) => a.id == template.id).firstOrNull;

      if (current?.isUnlocked == true) continue;

      // Verificar criterios según el tipo
      bool shouldUnlock = false;

      switch (template.type) {
        case AchievementType.firstTime:
          shouldUnlock = _checkFirstTimeAchievement(template, userStats);
          break;
        case AchievementType.streak:
          shouldUnlock = _checkStreakAchievement(template, userStats);
          break;
        case AchievementType.level:
          shouldUnlock = _checkLevelAchievement(template, userStats);
          break;
        case AchievementType.volume:
          shouldUnlock = _checkVolumeAchievement(template, userStats);
          break;
        case AchievementType.special:
          shouldUnlock = _checkSpecialAchievement(template, userStats);
          break;
      }

      if (shouldUnlock) {
        Achievement newAchievement = Achievement(
          id: template.id,
          title: template.title,
          description: template.description,
          icon: template.icon,
          color: template.color,
          xpReward: template.xpReward,
          type: template.type,
          criteria: template.criteria,
          isUnlocked: true,
          unlockedDate: DateTime.now(),
        );
        newAchievements.add(newAchievement);
      }
    }

    return newAchievements;
  }

  // Verificadores específicos por tipo
  bool _checkFirstTimeAchievement(
    Achievement achievement,
    Map<String, dynamic> stats,
  ) {
    if (achievement.id == 'first_workout') {
      return stats['total_workouts'] >= 1;
    }
    if (achievement.id == 'first_pushup') {
      return stats['pushups_completed'] >= 1;
    }
    if (achievement.id == 'first_pullup') {
      return stats['pullups_completed'] >= 1;
    }
    return false;
  }

  bool _checkStreakAchievement(
    Achievement achievement,
    Map<String, dynamic> stats,
  ) {
    int requiredStreak = achievement.criteria['streak_days'] ?? 0;
    return stats['current_streak'] >= requiredStreak;
  }

  bool _checkLevelAchievement(
    Achievement achievement,
    Map<String, dynamic> stats,
  ) {
    int requiredLevel = achievement.criteria['hunter_level'] ?? 0;
    return stats['hunter_level'] >= requiredLevel;
  }

  bool _checkVolumeAchievement(
    Achievement achievement,
    Map<String, dynamic> stats,
  ) {
    int requiredTotal = achievement.criteria['total_exercises'] ?? 0;
    return stats['total_exercises_completed'] >= requiredTotal;
  }

  bool _checkSpecialAchievement(
    Achievement achievement,
    Map<String, dynamic> stats,
  ) {
    if (achievement.id == 'perfect_week') {
      return stats['perfect_days_streak'] >= 7;
    }
    if (achievement.id == 'night_owl') {
      return stats['night_workouts'] >= 1;
    }
    return false;
  }
}

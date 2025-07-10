import '../models/exercise_model.dart';
import '../models/user_progress.dart';

class WorkoutService {
  // Singleton pattern
  static final WorkoutService _instance = WorkoutService._internal();
  factory WorkoutService() => _instance;
  WorkoutService._internal();

  // Base de datos de ejercicios con progresión REALISTA
  static final Map<String, Exercise> _exerciseDatabase = {
    'pushups': Exercise(
      id: 'pushups',
      name: 'Push-ups',
      type: 'Empuje',
      minLevel: 1,
      levels: {
        1: ExerciseLevel(
          target: '3 series de 3-5 reps',
          xp: 15,
          description: 'Push-ups desde rodillas o inclinados',
        ),
        2: ExerciseLevel(
          target: '3 series de 6-10 reps',
          xp: 20,
          description: 'Push-ups completos básicos',
        ),
        3: ExerciseLevel(
          target: '3 series de 12-18 reps',
          xp: 25,
          description: 'Push-ups con buena técnica y volumen',
        ),
        4: ExerciseLevel(
          target: '3 series de 20-25 reps',
          xp: 30,
          description: 'Push-ups avanzados - tu nivel actual!',
        ),
        5: ExerciseLevel(
          target: '3 series de 25+ reps o 2 series de 15 diamond',
          xp: 35,
          description: 'Transición a variaciones difíciles',
        ),
        6: ExerciseLevel(
          target: '3 series de 12-18 diamond push-ups',
          xp: 40,
          description: 'Diamond push-ups como ejercicio principal',
        ),
        7: ExerciseLevel(
          target: '3 series de 20+ diamond o archer push-ups',
          xp: 45,
          description: 'Variaciones asimétricas',
        ),
      },
    ),
    'squats': Exercise(
      id: 'squats',
      name: 'Squats',
      type: 'Piernas',
      minLevel: 1,
      levels: {
        1: ExerciseLevel(
          target: '3 series de 8-12 reps',
          xp: 15,
          description: 'Sentadillas básicas, enfoque en técnica',
        ),
        2: ExerciseLevel(
          target: '3 series de 15-20 reps',
          xp: 20,
          description: 'Sentadillas con rango completo',
        ),
        3: ExerciseLevel(
          target: '3 series de 22-28 reps',
          xp: 25,
          description: 'Sentadillas con resistencia - nivel estimado',
        ),
        4: ExerciseLevel(
          target: '4 series de 25-30 reps',
          xp: 30,
          description: 'Alto volumen de sentadillas',
        ),
        5: ExerciseLevel(
          target: '3 series de 30+ reps o jump squats',
          xp: 35,
          description: 'Transición a variaciones explosivas',
        ),
        6: ExerciseLevel(
          target: '3 series de 15 jump squats o pistol progression',
          xp: 40,
          description: 'Sentadillas unilaterales o explosivas',
        ),
      },
    ),
    'pullups': Exercise(
      id: 'pullups',
      name: 'Pull-ups',
      type: 'Jalón',
      minLevel: 1,
      levels: {
        1: ExerciseLevel(
          target: '3 series de negativos 3-5 seg',
          xp: 25,
          description: 'Pull-ups negativos controlados',
        ),
        2: ExerciseLevel(
          target: '3 series de 1-3 reps completos',
          xp: 30,
          description: 'Primeros pull-ups completos',
        ),
        3: ExerciseLevel(
          target: '3 series de 5-7 chin-ups',
          xp: 35,
          description: 'Chin-ups sólidos - tu nivel actual!',
        ),
        4: ExerciseLevel(
          target: '3 series de 8-10 chin-ups',
          xp: 40,
          description: 'Chin-ups con buen volumen',
        ),
        5: ExerciseLevel(
          target: '3 series de 6-8 pull-ups (prono)',
          xp: 45,
          description: 'Transición a agarre prono',
        ),
        6: ExerciseLevel(
          target: '3 series de 10-12 pull-ups',
          xp: 50,
          description: 'Pull-ups avanzados',
        ),
        7: ExerciseLevel(
          target: '3 series de 15+ pull-ups o weighted',
          xp: 55,
          description: 'Elite level - peso añadido',
        ),
      },
    ),
    'plank': Exercise(
      id: 'plank',
      name: 'Plank',
      type: 'Core',
      minLevel: 1,
      levels: {
        1: ExerciseLevel(
          target: '3 series de 15-30 segundos',
          xp: 15,
          description: 'Plancha básica con forma correcta',
        ),
        2: ExerciseLevel(
          target: '3 series de 30-45 segundos',
          xp: 20,
          description: 'Plancha con mayor resistencia',
        ),
        3: ExerciseLevel(
          target: '3 series de 45-60 segundos',
          xp: 25,
          description: 'Plancha con buen control - nivel estimado',
        ),
        4: ExerciseLevel(
          target: '3 series de 60-90 segundos',
          xp: 30,
          description: 'Plancha avanzada',
        ),
        5: ExerciseLevel(
          target: '3 series de 90+ segundos o variaciones',
          xp: 35,
          description: 'Plancha lateral o con movimiento',
        ),
      },
    ),
    'kneeraises': Exercise(
      id: 'kneeraises',
      name: 'Knee Raises',
      type: 'Core',
      minLevel: 2,
      levels: {
        2: ExerciseLevel(
          target: '3 series de 5-8 reps',
          xp: 20,
          description: 'Knee raises colgado básicos',
        ),
        3: ExerciseLevel(
          target: '3 series de 8-12 reps',
          xp: 25,
          description: 'Knee raises controlados - como haces!',
        ),
        4: ExerciseLevel(
          target: '3 series de 12-15 reps',
          xp: 30,
          description: 'Knee raises con buen volumen',
        ),
        5: ExerciseLevel(
          target: '3 series de 10-12 L-sits',
          xp: 35,
          description: 'Progresión hacia L-sits',
        ),
      },
    ),
    'running': Exercise(
      id: 'running',
      name: 'Running',
      type: 'Cardio',
      minLevel: 1,
      levels: {
        1: ExerciseLevel(
          target: '2-3km trote suave',
          xp: 25,
          description: 'Primeros km de resistencia',
        ),
        2: ExerciseLevel(
          target: '4-5km ritmo cómodo',
          xp: 30,
          description: 'Construyendo base aeróbica',
        ),
        3: ExerciseLevel(
          target: '5-6km ritmo moderado',
          xp: 35,
          description: 'Resistencia sólida',
        ),
        4: ExerciseLevel(
          target: '7-8km ritmo constante',
          xp: 40,
          description: 'Excelente resistencia - tu nivel actual!',
        ),
        5: ExerciseLevel(
          target: '9-10km + intervalos ocasionales',
          xp: 45,
          description: 'Corredor sólido con variedad',
        ),
        6: ExerciseLevel(
          target: '12-15km o entrenamientos específicos',
          xp: 50,
          description: 'Corredor avanzado',
        ),
      },
    ),
    'dips': Exercise(
      id: 'dips',
      name: 'Dips',
      type: 'Empuje',
      minLevel: 2,
      levels: {
        2: ExerciseLevel(
          target: '3 series de 3-5 reps',
          xp: 20,
          description: 'Dips asistidos en silla',
        ),
        3: ExerciseLevel(
          target: '3 series de 5-8 reps',
          xp: 25,
          description: 'Dips completos con descanso',
        ),
        4: ExerciseLevel(
          target: '3 series de 8-12 reps',
          xp: 30,
          description: 'Dips con mayor volumen',
        ),
        5: ExerciseLevel(
          target: '4 series de 8-12 reps',
          xp: 35,
          description: 'Dips avanzados',
        ),
      },
    ),
  };

  // Obtener entrenamiento del día según el progreso del usuario
  List<Exercise> getDailyWorkout(UserProgress userProgress) {
    List<Exercise> dailyExercises = [];

    // Seleccionar ejercicios según el nivel del usuario en cada categoría
    for (String exerciseType in [
      'Empuje',
      'Jalón',
      'Piernas',
      'Core',
      'Cardio'
    ]) {
      int userLevelForType = userProgress.exerciseLevels[exerciseType] ?? 1;

      // Encontrar ejercicios de este tipo que el usuario pueda hacer
      List<Exercise> availableExercises = _exerciseDatabase.values
          .where(
            (exercise) =>
                exercise.type == exerciseType &&
                exercise.minLevel <= userLevelForType,
          )
          .toList();

      if (availableExercises.isNotEmpty) {
        // Selección inteligente de ejercicios según el tipo
        Exercise selectedExercise;

        if (exerciseType == 'Empuje') {
          // Siempre push-ups como ejercicio principal de empuje
          selectedExercise = availableExercises.firstWhere(
            (ex) => ex.id == 'pushups',
            orElse: () => availableExercises.first,
          );
        } else if (exerciseType == 'Jalón') {
          // Siempre pull-ups como ejercicio principal de jalón
          selectedExercise = availableExercises.firstWhere(
            (ex) => ex.id == 'pullups',
            orElse: () => availableExercises.first,
          );
        } else if (exerciseType == 'Core') {
          // Alternar entre plank y knee raises según el nivel
          if (userLevelForType >= 3) {
            selectedExercise = availableExercises.firstWhere(
              (ex) => ex.id == 'kneeraises',
              orElse: () => availableExercises.first,
            );
          } else {
            selectedExercise = availableExercises.firstWhere(
              (ex) => ex.id == 'plank',
              orElse: () => availableExercises.first,
            );
          }
        } else if (exerciseType == 'Cardio') {
          // Running como ejercicio principal de cardio
          selectedExercise = availableExercises.firstWhere(
            (ex) => ex.id == 'running',
            orElse: () => availableExercises.first,
          );
        } else {
          // Para piernas y otros, tomar el primero disponible
          selectedExercise = availableExercises.first;
        }

        // Crear una copia del ejercicio para el entrenamiento de hoy
        Exercise todayExercise = Exercise(
          id: selectedExercise.id,
          name: selectedExercise.name,
          type: selectedExercise.type,
          minLevel: selectedExercise.minLevel,
          levels: selectedExercise.levels,
          isCompleted: false,
        );

        dailyExercises.add(todayExercise);
      }
    }

    return dailyExercises;
  }

  // Calcular XP total del entrenamiento
  int calculateWorkoutXP(List<Exercise> exercises, UserProgress userProgress) {
    int totalXP = 0;

    for (Exercise exercise in exercises) {
      if (exercise.isCompleted) {
        int userLevel = userProgress.exerciseLevels[exercise.type] ?? 1;
        totalXP += exercise.getXP(userLevel);
      }
    }

    return totalXP;
  }

  // Verificar si el usuario puede progresar en algún ejercicio
  Map<String, bool> checkForProgression(
    List<Exercise> exercises,
    UserProgress userProgress,
  ) {
    Map<String, bool> canProgress = {};

    for (Exercise exercise in exercises) {
      if (exercise.isCompleted) {
        // Lógica simple: si completó el ejercicio, puede intentar progresar
        // En versiones futuras se pueden añadir criterios más específicos
        canProgress[exercise.type] = true;
      }
    }

    return canProgress;
  }

  // Obtener ejercicio por ID
  Exercise? getExerciseById(String id) {
    return _exerciseDatabase[id];
  }

  // Obtener todos los ejercicios disponibles
  List<Exercise> getAllExercises() {
    return _exerciseDatabase.values.toList();
  }
}

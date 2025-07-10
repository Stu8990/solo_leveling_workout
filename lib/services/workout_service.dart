import '../models/exercise_model.dart';
import '../models/user_progress.dart';

class WorkoutService {
  // Singleton pattern
  static final WorkoutService _instance = WorkoutService._internal();
  factory WorkoutService() => _instance;
  WorkoutService._internal();

  // Base de datos de ejercicios con progresión
  static final Map<String, Exercise> _exerciseDatabase = {
    'pushups': Exercise(
      id: 'pushups',
      name: 'Push-ups',
      type: 'Empuje',
      minLevel: 1,
      levels: {
        1: ExerciseLevel(
          target: '3 series de 5-8 reps',
          xp: 15,
          description: 'Push-ups básicos desde las rodillas si es necesario',
        ),
        2: ExerciseLevel(
          target: '3 series de 8-12 reps',
          xp: 20,
          description: 'Push-ups completos con forma correcta',
        ),
        3: ExerciseLevel(
          target: '3 series de 12-15 reps',
          xp: 25,
          description: 'Push-ups con mayor volumen',
        ),
        4: ExerciseLevel(
          target: '4 series de 10-15 reps',
          xp: 30,
          description: 'Incremento en series y repeticiones',
        ),
        5: ExerciseLevel(
          target: '4 series de 15-20 reps',
          xp: 35,
          description: 'Push-ups avanzados con alto volumen',
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
          target: '3 series de 10-15 reps',
          xp: 15,
          description: 'Sentadillas básicas con peso corporal',
        ),
        2: ExerciseLevel(
          target: '3 series de 15-20 reps',
          xp: 20,
          description: 'Sentadillas con mayor rango de movimiento',
        ),
        3: ExerciseLevel(
          target: '3 series de 20-25 reps',
          xp: 25,
          description: 'Sentadillas con alto volumen',
        ),
        4: ExerciseLevel(
          target: '4 series de 15-20 reps',
          xp: 30,
          description: 'Incremento en series',
        ),
        5: ExerciseLevel(
          target: '4 series de 20-25 reps',
          xp: 35,
          description: 'Sentadillas avanzadas',
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
          target: '3 series de 1-3 reps',
          xp: 25,
          description: 'Pull-ups asistidos o negativos',
        ),
        2: ExerciseLevel(
          target: '3 series de 3-5 reps',
          xp: 30,
          description: 'Pull-ups completos con descanso',
        ),
        3: ExerciseLevel(
          target: '3 series de 5-8 reps',
          xp: 35,
          description: 'Pull-ups con mejor resistencia',
        ),
        4: ExerciseLevel(
          target: '4 series de 5-8 reps',
          xp: 40,
          description: 'Incremento en volumen',
        ),
        5: ExerciseLevel(
          target: '4 series de 8-12 reps',
          xp: 45,
          description: 'Pull-ups avanzados',
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
          target: '3 series de 20-30 segundos',
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
          description: 'Plancha con buen control',
        ),
        4: ExerciseLevel(
          target: '3 series de 60-90 segundos',
          xp: 30,
          description: 'Plancha avanzada',
        ),
        5: ExerciseLevel(
          target: '4 series de 60-90 segundos',
          xp: 35,
          description: 'Plancha experta',
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
    for (String exerciseType in ['Empuje', 'Jalón', 'Piernas', 'Core']) {
      int userLevelForType = userProgress.exerciseLevels[exerciseType] ?? 1;

      // Encontrar ejercicios de este tipo que el usuario pueda hacer
      List<Exercise> availableExercises =
          _exerciseDatabase.values
              .where(
                (exercise) =>
                    exercise.type == exerciseType &&
                    exercise.minLevel <= userLevelForType,
              )
              .toList();

      if (availableExercises.isNotEmpty) {
        // Por ahora, tomar el primer ejercicio disponible
        // En versiones futuras se puede hacer rotación o selección aleatoria
        Exercise selectedExercise = availableExercises.first;

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

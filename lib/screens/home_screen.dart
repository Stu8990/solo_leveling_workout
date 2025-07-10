import 'package:flutter/material.dart';
import '../widgets/exercise_tile.dart';
import '../widgets/rest_timer.dart';
import '../models/exercise_model.dart';
import '../models/user_progress.dart';
import '../services/data_service.dart';
import '../services/workout_service.dart';
import 'profile_screen.dart';
import 'history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DataService _dataService = DataService();
  final WorkoutService _workoutService = WorkoutService();

  UserProgress _userProgress = UserProgress();
  List<Exercise> _todayExercises = [];
  bool _isLoading = true;
  bool _showRestTimer = false;
  String _currentExerciseName = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Cargar datos del usuario y generar entrenamiento
  Future<void> _loadUserData() async {
    try {
      // Cargar progreso del usuario
      _userProgress = await _dataService.loadUserProgress();

      // Verificar si es un nuevo día
      bool isNewDay = await _dataService.isNewDay();

      if (isNewDay) {
        // Nuevo día: generar nuevo entrenamiento
        _todayExercises = _workoutService.getDailyWorkout(_userProgress);
      } else {
        // Mismo día: intentar cargar entrenamiento guardado
        List<Map<String, dynamic>>? savedWorkout =
            await _dataService.loadDailyWorkout();

        if (savedWorkout != null) {
          // Reconstruir ejercicios desde datos guardados
          _todayExercises = _reconstructExercisesFromSaved(savedWorkout);
        } else {
          // No hay entrenamiento guardado, generar nuevo
          _todayExercises = _workoutService.getDailyWorkout(_userProgress);
        }
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading user data: $e');
      // En caso de error, usar datos por defecto
      _todayExercises = _workoutService.getDailyWorkout(_userProgress);
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Reconstruir ejercicios desde datos guardados
  List<Exercise> _reconstructExercisesFromSaved(
      List<Map<String, dynamic>> savedData) {
    List<Exercise> exercises = [];

    for (Map<String, dynamic> data in savedData) {
      Exercise? baseExercise = _workoutService.getExerciseById(data['id']);
      if (baseExercise != null) {
        Exercise exercise = Exercise(
          id: baseExercise.id,
          name: baseExercise.name,
          type: baseExercise.type,
          minLevel: baseExercise.minLevel,
          levels: baseExercise.levels,
          isCompleted: data['isCompleted'] ?? false,
        );
        exercises.add(exercise);
      }
    }

    return exercises;
  }

  // Marcar/desmarcar ejercicio como completado
  void _toggleExercise(int index) {
    setState(() {
      _todayExercises[index].isCompleted = !_todayExercises[index].isCompleted;
    });

    // Si se completó un ejercicio, mostrar temporizador de descanso
    if (_todayExercises[index].isCompleted) {
      _currentExerciseName = _todayExercises[index].name;
      setState(() {
        _showRestTimer = true;
      });
      print('DEBUG: Showing rest timer for ${_todayExercises[index].name}');
    }

    // Guardar estado del entrenamiento
    _saveDailyWorkout();
  }

  // Guardar estado del entrenamiento diario
  Future<void> _saveDailyWorkout() async {
    List<Map<String, dynamic>> workoutData = _todayExercises
        .map((exercise) => {
              'id': exercise.id,
              'isCompleted': exercise.isCompleted,
            })
        .toList();

    await _dataService.saveDailyWorkout(workoutData);
  }

  // Completar entrenamiento
  Future<void> _completeWorkout() async {
    // Verificar que al menos un ejercicio esté completado
    bool hasCompletedExercises =
        _todayExercises.any((exercise) => exercise.isCompleted);

    if (!hasCompletedExercises) {
      _showMessage('Completa al menos un ejercicio para ganar XP',
          isError: true);
      return;
    }

    // Calcular XP ganado
    int xpGained =
        _workoutService.calculateWorkoutXP(_todayExercises, _userProgress);

    // Añadir XP al progreso del usuario
    bool leveledUp = _userProgress.addXP(xpGained);

    // Marcar entrenamiento como completado
    _userProgress.completeWorkout();

    // Verificar progresión en ejercicios
    Map<String, bool> progressions =
        _workoutService.checkForProgression(_todayExercises, _userProgress);

    // Aplicar progresiones
    for (String exerciseType in progressions.keys) {
      if (progressions[exerciseType] == true) {
        _userProgress.levelUpExercise(exerciseType);
      }
    }

    // Guardar progreso
    await _dataService.saveUserProgress(_userProgress);

    // Mostrar mensaje de éxito
    String message = '¡Entrenamiento completado! +$xpGained XP';
    if (leveledUp) {
      message += '\n🎉 ¡SUBISTE AL NIVEL ${_userProgress.hunterLevel}!';
    }

    _showMessage(message);

    // Actualizar UI
    setState(() {});
  }

  // Mostrar mensaje al usuario
  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : const Color(0xFF4f46e5),
        duration: Duration(seconds: isError ? 2 : 3),
      ),
    );
  }

  // Verificar si el entrenamiento está completado
  bool _isWorkoutCompleted() {
    return _todayExercises.every((exercise) => exercise.isCompleted);
  }

  // Contar ejercicios completados
  int _getCompletedCount() {
    return _todayExercises.where((exercise) => exercise.isCompleted).length;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF4f46e5),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Misión Diaria',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: const Icon(Icons.fitness_center),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Recargar datos
              setState(() {
                _isLoading = true;
              });
              _loadUserData();
            },
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HistoryScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ProfileScreen(userProgress: _userProgress),
                ),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0f172a), // Negro azulado
                  Color(0xFF1a1a2e), // Azul muy oscuro
                ],
              ),
            ),
            child: Column(
              children: [
                // Header con información del cazador
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF16213e),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF4f46e5),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Nivel del Cazador',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                'Nivel ${_userProgress.hunterLevel}',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF4f46e5),
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text(
                                'XP',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                '${_userProgress.currentXP} / ${_userProgress.xpToNextLevel}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF06b6d4),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Barra de progreso de XP
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Progreso al siguiente nivel',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: _userProgress.getXPProgress(),
                              backgroundColor: Colors.grey[800],
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xFF06b6d4),
                              ),
                              minHeight: 8,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Información del entrenamiento
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF16213e).withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Progreso: ${_getCompletedCount()}/${_todayExercises.length}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      if (_userProgress.currentStreak > 0)
                        Row(
                          children: [
                            const Icon(
                              Icons.local_fire_department,
                              color: Color(0xFFf59e0b),
                              size: 20,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${_userProgress.currentStreak} días',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFf59e0b),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Lista de ejercicios
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _todayExercises.length,
                    itemBuilder: (context, index) {
                      Exercise exercise = _todayExercises[index];
                      int userLevel =
                          _userProgress.exerciseLevels[exercise.type] ?? 1;

                      return ExerciseTile(
                        exerciseName: exercise.name,
                        target: exercise.getTarget(userLevel),
                        type: exercise.type,
                        isCompleted: exercise.isCompleted,
                        xp: exercise.getXP(userLevel),
                        onToggle: () => _toggleExercise(index),
                      );
                    },
                  ),
                ),

                // Botón para completar entrenamiento
                Container(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _completeWorkout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isWorkoutCompleted()
                            ? const Color(0xFF10b981)
                            : const Color(0xFF4f46e5),
                      ),
                      child: Text(
                        _isWorkoutCompleted()
                            ? '✅ ¡Entrenamiento Completado!'
                            : 'Completar Entrenamiento',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Overlay del temporizador de descanso
          if (_showRestTimer)
            Container(
              color: Colors.black.withOpacity(0.8),
              child: Center(
                child: RestTimer(
                  restTimeSeconds: 90, // 1:30 minutos de descanso
                  onTimerComplete: () {
                    setState(() {
                      _showRestTimer = false;
                    });
                    _showMessage(
                        '¡Descanso completado! Continúa con el siguiente ejercicio 💪');
                  },
                  onTimerCancel: () {
                    setState(() {
                      _showRestTimer = false;
                    });
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_progress.dart';

class DataService {
  static const String _userProgressKey = 'user_progress';
  static const String _dailyWorkoutKey = 'daily_workout_';

  // Singleton pattern
  static final DataService _instance = DataService._internal();
  factory DataService() => _instance;
  DataService._internal();

  SharedPreferences? _prefs;

  // Inicializar SharedPreferences
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // Guardar progreso del usuario
  Future<bool> saveUserProgress(UserProgress progress) async {
    await init();
    final String jsonString = jsonEncode(progress.toJson());
    return await _prefs!.setString(_userProgressKey, jsonString);
  }

  // Cargar progreso del usuario
  Future<UserProgress> loadUserProgress() async {
    await init();
    final String? jsonString = _prefs!.getString(_userProgressKey);

    if (jsonString != null) {
      final Map<String, dynamic> json = jsonDecode(jsonString);
      return UserProgress.fromJson(json);
    }

    // Si no existe, crear nuevo progreso
    return UserProgress();
  }

  // Guardar estado del entrenamiento diario
  Future<bool> saveDailyWorkout(List<Map<String, dynamic>> exercises) async {
    await init();
    String today = DateTime.now().toIso8601String().split('T')[0];
    final String jsonString = jsonEncode(exercises);
    return await _prefs!.setString(_dailyWorkoutKey + today, jsonString);
  }

  // Cargar estado del entrenamiento diario
  Future<List<Map<String, dynamic>>?> loadDailyWorkout() async {
    await init();
    String today = DateTime.now().toIso8601String().split('T')[0];
    final String? jsonString = _prefs!.getString(_dailyWorkoutKey + today);

    if (jsonString != null) {
      final List<dynamic> json = jsonDecode(jsonString);
      return json.cast<Map<String, dynamic>>();
    }

    return null;
  }

  // Limpiar datos (útil para testing)
  Future<bool> clearAllData() async {
    await init();
    return await _prefs!.clear();
  }

  // Verificar si es un nuevo día
  Future<bool> isNewDay() async {
    await init();
    String today = DateTime.now().toIso8601String().split('T')[0];
    String? lastSavedDay = _prefs!.getString('last_day');

    if (lastSavedDay != today) {
      await _prefs!.setString('last_day', today);
      return true;
    }

    return false;
  }

  // Resetear entrenamiento diario
  Future<void> resetDailyWorkout() async {
    await init();
    String today = DateTime.now().toIso8601String().split('T')[0];
    await _prefs!.remove(_dailyWorkoutKey + today);
  }
}

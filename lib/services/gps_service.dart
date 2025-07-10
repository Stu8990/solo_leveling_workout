// lib/services/gps_service.dart

import 'dart:async';
import 'dart:math';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/cardio_session.dart';

class GPSService {
  // Singleton
  static final GPSService _instance = GPSService._internal();
  factory GPSService() => _instance;
  GPSService._internal();

  // Streams y controllers
  StreamSubscription<Position>? _positionStream;
  final StreamController<LiveCardioStats> _statsController =
      StreamController<LiveCardioStats>.broadcast();
  final StreamController<Position> _positionController =
      StreamController<Position>.broadcast();

  // Estado del tracking
  CardioSession? _currentSession;
  final List<CardioPoint> _currentRoute = [];
  DateTime? _startTime;
  DateTime? _lastPositionTime;
  Position? _lastPosition;
  double _totalDistance = 0.0;
  int _elapsedSeconds = 0;
  Timer? _timer;
  CardioTrackingState _state = CardioTrackingState.stopped;

  // Getters para streams
  Stream<LiveCardioStats> get statsStream => _statsController.stream;
  Stream<Position> get positionStream => _positionController.stream;
  CardioTrackingState get currentState => _state;
  CardioSession? get currentSession => _currentSession;

  // Configuración GPS
  static const LocationSettings _locationSettings = LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 5, // Actualizar cada 5 metros
  );

  /// Verificar y solicitar permisos
  Future<bool> checkAndRequestPermissions() async {
    try {
      // Verificar si el servicio de ubicación está habilitado
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return false;
      }

      // Verificar permisos
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return false;
      }

      return true;
    } catch (e) {
      print('Error checking permissions: $e');
      return false;
    }
  }

  /// Iniciar sesión de tracking
  Future<bool> startTracking({String exerciseType = 'running'}) async {
    try {
      // Verificar permisos
      bool hasPermission = await checkAndRequestPermissions();
      if (!hasPermission) {
        throw Exception('No se concedieron permisos de ubicación');
      }

      // Limpiar estado anterior
      await stopTracking();

      // Inicializar nueva sesión
      _startTime = DateTime.now();
      _totalDistance = 0.0;
      _elapsedSeconds = 0;
      _currentRoute.clear();
      _lastPosition = null;
      _lastPositionTime = null;

      _currentSession = CardioSession(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        startTime: _startTime!,
        totalDistance: 0,
        totalDuration: 0,
        route: [],
        averagePace: 0,
        maxSpeed: 0,
        exerciseType: exerciseType,
      );

      // Iniciar timer
      _timer = Timer.periodic(const Duration(seconds: 1), _updateTimer);

      // Iniciar stream de posición
      _positionStream = Geolocator.getPositionStream(
        locationSettings: _locationSettings,
      ).listen(
        _onPositionUpdate,
        onError: _onPositionError,
      );

      _state = CardioTrackingState.running;
      _emitStats();

      return true;
    } catch (e) {
      print('Error starting tracking: $e');
      return false;
    }
  }

  /// Pausar tracking
  void pauseTracking() {
    if (_state == CardioTrackingState.running) {
      _state = CardioTrackingState.paused;
      _timer?.cancel();
      _emitStats();
    }
  }

  /// Reanudar tracking
  void resumeTracking() {
    if (_state == CardioTrackingState.paused) {
      _state = CardioTrackingState.running;
      _timer = Timer.periodic(const Duration(seconds: 1), _updateTimer);
      _emitStats();
    }
  }

  /// Detener tracking y finalizar sesión
  Future<CardioSession?> stopTracking() async {
    _timer?.cancel();
    await _positionStream?.cancel();

    if (_currentSession != null && _startTime != null) {
      final session = _currentSession!.copyWith(
        endTime: DateTime.now(),
        totalDistance: _totalDistance,
        totalDuration: _elapsedSeconds,
        route: List.from(_currentRoute),
        averagePace: _calculateAveragePace(),
        maxSpeed: _calculateMaxSpeed(),
        isCompleted: true,
      );

      _state = CardioTrackingState.stopped;
      _emitStats();

      _currentSession = null;
      return session;
    }

    _state = CardioTrackingState.stopped;
    _emitStats();
    return null;
  }

  /// Callback del timer
  void _updateTimer(Timer timer) {
    if (_state == CardioTrackingState.running) {
      _elapsedSeconds++;
      _emitStats();
    }
  }

  /// Callback de actualización de posición
  void _onPositionUpdate(Position position) {
    if (_state != CardioTrackingState.running) return;

    // Filtrar posiciones con baja precisión
    if (position.accuracy > 20) return;

    DateTime now = DateTime.now();

    // Calcular distancia desde la última posición
    if (_lastPosition != null) {
      double distance = Geolocator.distanceBetween(
        _lastPosition!.latitude,
        _lastPosition!.longitude,
        position.latitude,
        position.longitude,
      );

      // Filtrar movimientos muy pequeños o muy grandes (posibles errores GPS)
      if (distance > 2 && distance < 100) {
        _totalDistance += distance;
      }
    }

    // Agregar punto a la ruta
    _currentRoute.add(CardioPoint(
      latitude: position.latitude,
      longitude: position.longitude,
      timestamp: now,
      altitude: position.altitude,
      accuracy: position.accuracy,
      speed: position.speed,
      heading: position.heading,
    ));

    _lastPosition = position;
    _lastPositionTime = now;

    // Emitir posición actualizada
    _positionController.add(position);
    _emitStats();
  }

  /// Callback de error de posición
  void _onPositionError(error) {
    print('GPS Error: $error');
  }

  /// Emitir estadísticas actuales
  void _emitStats() {
    double currentPace = _calculateCurrentPace();
    double currentSpeed = _lastPosition?.speed ?? 0.0;

    final stats = LiveCardioStats(
      currentDistance: _totalDistance,
      elapsedTime: _elapsedSeconds,
      currentPace: currentPace,
      currentSpeed: currentSpeed,
      state: _state,
    );

    _statsController.add(stats);
  }

  /// Calcular pace actual (últimos 30 segundos)
  double _calculateCurrentPace() {
    if (_currentRoute.length < 2) return 0.0;

    DateTime cutoff = DateTime.now().subtract(const Duration(seconds: 30));
    List<CardioPoint> recentPoints = _currentRoute
        .where((point) => point.timestamp.isAfter(cutoff))
        .toList();

    if (recentPoints.length < 2) return 0.0;

    double recentDistance = 0.0;
    for (int i = 1; i < recentPoints.length; i++) {
      recentDistance += Geolocator.distanceBetween(
        recentPoints[i - 1].latitude,
        recentPoints[i - 1].longitude,
        recentPoints[i].latitude,
        recentPoints[i].longitude,
      );
    }

    if (recentDistance <= 0) return 0.0;

    double recentTimeMinutes = recentPoints.length / 2; // Aproximación
    double distanceKm = recentDistance / 1000;

    return recentTimeMinutes / distanceKm;
  }

  /// Calcular pace promedio de toda la sesión
  double _calculateAveragePace() {
    if (_totalDistance <= 0 || _elapsedSeconds <= 0) return 0.0;

    double distanceKm = _totalDistance / 1000;
    double timeMinutes = _elapsedSeconds / 60;

    return timeMinutes / distanceKm;
  }

  /// Calcular velocidad máxima
  double _calculateMaxSpeed() {
    if (_currentRoute.isEmpty) return 0.0;

    double maxSpeed = 0.0;
    for (CardioPoint point in _currentRoute) {
      if (point.speed != null && point.speed! > maxSpeed) {
        maxSpeed = point.speed!;
      }
    }

    return maxSpeed;
  }

  /// Obtener posición actual
  Future<Position?> getCurrentPosition() async {
    try {
      bool hasPermission = await checkAndRequestPermissions();
      if (!hasPermission) return null;

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      print('Error getting current position: $e');
      return null;
    }
  }

  /// Limpiar recursos
  void dispose() {
    _timer?.cancel();
    _positionStream?.cancel();
    _statsController.close();
    _positionController.close();
  }
}

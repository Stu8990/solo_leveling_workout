// lib/models/cardio_session.dart

import 'dart:convert';

class CardioSession {
  final String id;
  final DateTime startTime;
  final DateTime? endTime;
  final double totalDistance; // en metros
  final int totalDuration; // en segundos
  final List<CardioPoint> route;
  final double averagePace; // minutos por km
  final double maxSpeed; // m/s
  final String exerciseType; // 'running', 'walking', etc.
  final bool isCompleted;

  CardioSession({
    required this.id,
    required this.startTime,
    this.endTime,
    required this.totalDistance,
    required this.totalDuration,
    required this.route,
    required this.averagePace,
    required this.maxSpeed,
    required this.exerciseType,
    this.isCompleted = false,
  });

  // Calcular pace promedio en min/km
  double get pacePerKm {
    if (totalDistance <= 0) return 0;
    double distanceInKm = totalDistance / 1000;
    double timeInMinutes = totalDuration / 60;
    return timeInMinutes / distanceInKm;
  }

  // Calcular velocidad promedio en km/h
  double get averageSpeedKmh {
    if (totalDuration <= 0) return 0;
    double distanceInKm = totalDistance / 1000;
    double timeInHours = totalDuration / 3600;
    return distanceInKm / timeInHours;
  }

  // Formatear duración como HH:MM:SS
  String get formattedDuration {
    int hours = totalDuration ~/ 3600;
    int minutes = (totalDuration % 3600) ~/ 60;
    int seconds = totalDuration % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  // Formatear pace como MM:SS/km
  String get formattedPace {
    if (pacePerKm.isInfinite || pacePerKm.isNaN || pacePerKm <= 0) {
      return '--:--/km';
    }

    int minutes = pacePerKm.floor();
    int seconds = ((pacePerKm - minutes) * 60).round();

    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}/km';
  }

  // Formatear distancia
  String get formattedDistance {
    if (totalDistance >= 1000) {
      return '${(totalDistance / 1000).toStringAsFixed(2)} km';
    } else {
      return '${totalDistance.toStringAsFixed(0)} m';
    }
  }

  // Convertir a JSON para guardado
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'totalDistance': totalDistance,
      'totalDuration': totalDuration,
      'route': route.map((point) => point.toJson()).toList(),
      'averagePace': averagePace,
      'maxSpeed': maxSpeed,
      'exerciseType': exerciseType,
      'isCompleted': isCompleted,
    };
  }

  // Crear desde JSON
  factory CardioSession.fromJson(Map<String, dynamic> json) {
    return CardioSession(
      id: json['id'] ?? '',
      startTime: DateTime.parse(json['startTime']),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      totalDistance: (json['totalDistance'] ?? 0.0).toDouble(),
      totalDuration: json['totalDuration'] ?? 0,
      route: (json['route'] as List<dynamic>?)
              ?.map((point) => CardioPoint.fromJson(point))
              .toList() ??
          [],
      averagePace: (json['averagePace'] ?? 0.0).toDouble(),
      maxSpeed: (json['maxSpeed'] ?? 0.0).toDouble(),
      exerciseType: json['exerciseType'] ?? 'running',
      isCompleted: json['isCompleted'] ?? false,
    );
  }

  // Copiar con nuevos valores
  CardioSession copyWith({
    String? id,
    DateTime? startTime,
    DateTime? endTime,
    double? totalDistance,
    int? totalDuration,
    List<CardioPoint>? route,
    double? averagePace,
    double? maxSpeed,
    String? exerciseType,
    bool? isCompleted,
  }) {
    return CardioSession(
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      totalDistance: totalDistance ?? this.totalDistance,
      totalDuration: totalDuration ?? this.totalDuration,
      route: route ?? this.route,
      averagePace: averagePace ?? this.averagePace,
      maxSpeed: maxSpeed ?? this.maxSpeed,
      exerciseType: exerciseType ?? this.exerciseType,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

class CardioPoint {
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final double? altitude;
  final double? accuracy;
  final double? speed; // m/s
  final double? heading;

  CardioPoint({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    this.altitude,
    this.accuracy,
    this.speed,
    this.heading,
  });

  // Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp.toIso8601String(),
      'altitude': altitude,
      'accuracy': accuracy,
      'speed': speed,
      'heading': heading,
    };
  }

  // Crear desde JSON
  factory CardioPoint.fromJson(Map<String, dynamic> json) {
    return CardioPoint(
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      timestamp: DateTime.parse(json['timestamp']),
      altitude: json['altitude']?.toDouble(),
      accuracy: json['accuracy']?.toDouble(),
      speed: json['speed']?.toDouble(),
      heading: json['heading']?.toDouble(),
    );
  }
}

// Enums para estados del tracking
enum CardioTrackingState {
  stopped,
  running,
  paused,
}

// Estadísticas en tiempo real durante el tracking
class LiveCardioStats {
  final double currentDistance; // metros
  final int elapsedTime; // segundos
  final double currentPace; // min/km
  final double currentSpeed; // m/s
  final CardioTrackingState state;

  LiveCardioStats({
    required this.currentDistance,
    required this.elapsedTime,
    required this.currentPace,
    required this.currentSpeed,
    required this.state,
  });

  // Formatters para UI
  String get formattedDistance {
    if (currentDistance >= 1000) {
      return '${(currentDistance / 1000).toStringAsFixed(2)} km';
    } else {
      return '${currentDistance.toStringAsFixed(0)} m';
    }
  }

  String get formattedTime {
    int hours = elapsedTime ~/ 3600;
    int minutes = (elapsedTime % 3600) ~/ 60;
    int seconds = elapsedTime % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  String get formattedPace {
    if (currentPace.isInfinite || currentPace.isNaN || currentPace <= 0) {
      return '--:--/km';
    }

    int minutes = currentPace.floor();
    int seconds = ((currentPace - minutes) * 60).round();

    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}/km';
  }

  String get formattedSpeed {
    double speedKmh = currentSpeed * 3.6; // Convertir m/s a km/h
    return '${speedKmh.toStringAsFixed(1)} km/h';
  }
}

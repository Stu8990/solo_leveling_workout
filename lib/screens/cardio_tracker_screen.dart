// lib/screens/cardio_tracker_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import '../models/cardio_session.dart';
import '../services/gps_service.dart';

class CardioTrackerScreen extends StatefulWidget {
  final String exerciseType;
  final Function(CardioSession) onSessionComplete;

  const CardioTrackerScreen({
    super.key,
    this.exerciseType = 'running',
    required this.onSessionComplete,
  });

  @override
  State<CardioTrackerScreen> createState() => _CardioTrackerScreenState();
}

class _CardioTrackerScreenState extends State<CardioTrackerScreen>
    with TickerProviderStateMixin {
  final GPSService _gpsService = GPSService();

  // Estado del tracking
  LiveCardioStats? _currentStats;
  StreamSubscription<LiveCardioStats>? _statsSubscription;
  bool _isInitializing = false;
  String? _errorMessage;

  // Animaciones
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Configurar animaciones
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _pulseController.repeat(reverse: true);

    // Escuchar estadísticas
    _statsSubscription = _gpsService.statsStream.listen((stats) {
      setState(() {
        _currentStats = stats;
      });
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _statsSubscription?.cancel();
    super.dispose();
  }

  Future<void> _startTracking() async {
    setState(() {
      _isInitializing = true;
      _errorMessage = null;
    });

    bool success = await _gpsService.startTracking(
      exerciseType: widget.exerciseType,
    );

    setState(() {
      _isInitializing = false;
      if (!success) {
        _errorMessage = 'No se pudo iniciar el GPS. Verifica los permisos.';
      }
    });
  }

  void _pauseResumeTracking() {
    if (_gpsService.currentState == CardioTrackingState.running) {
      _gpsService.pauseTracking();
    } else if (_gpsService.currentState == CardioTrackingState.paused) {
      _gpsService.resumeTracking();
    }
  }

  Future<void> _stopTracking() async {
    // Mostrar diálogo de confirmación
    bool? shouldStop = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF16213e),
        title: Text(
          '¿Finalizar entrenamiento?',
          style: GoogleFonts.orbitron(color: Colors.white),
        ),
        content: const Text(
          'Se guardará tu progreso y regresarás a la pantalla principal.',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10b981),
            ),
            child: const Text('Finalizar'),
          ),
        ],
      ),
    );

    if (shouldStop == true) {
      CardioSession? session = await _gpsService.stopTracking();
      if (session != null && mounted) {
        widget.onSessionComplete(session);
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.exerciseType == 'running'
              ? 'Tracking de Carrera'
              : 'Tracking de Cardio',
          style: GoogleFonts.orbitron(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF1a1a2e),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: _gpsService.currentState == CardioTrackingState.stopped
              ? () => Navigator.pop(context)
              : _stopTracking,
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0f172a),
              Color(0xFF1a1a2e),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Estadísticas principales
              Expanded(
                flex: 3,
                child: _buildMainStats(),
              ),

              // Controles
              Expanded(
                flex: 1,
                child: _buildControls(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainStats() {
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _startTracking,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (_currentStats == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.directions_run,
              size: 120,
              color: const Color(0xFF06b6d4).withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              '¡Listo para comenzar!',
              style: GoogleFonts.orbitron(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Presiona el botón de inicio cuando estés listo',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[400],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Tiempo principal
          Expanded(
            flex: 2,
            child: Center(
              child: AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale:
                        _gpsService.currentState == CardioTrackingState.running
                            ? _pulseAnimation.value
                            : 1.0,
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: const Color(0xFF16213e),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _getStateColor(),
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _getStateColor().withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _currentStats!.formattedTime,
                            style: GoogleFonts.orbitron(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: _getStateColor(),
                            ),
                          ),
                          Text(
                            _getStateText(),
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[400],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Grid de estadísticas
          Expanded(
            flex: 2,
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
              children: [
                _buildStatCard(
                  'Distancia',
                  _currentStats!.formattedDistance,
                  Icons.straighten,
                  const Color(0xFF10b981),
                ),
                _buildStatCard(
                  'Pace',
                  _currentStats!.formattedPace,
                  Icons.speed,
                  const Color(0xFF06b6d4),
                ),
                _buildStatCard(
                  'Velocidad',
                  _currentStats!.formattedSpeed,
                  Icons.flash_on,
                  const Color(0xFFf59e0b),
                ),
                _buildStatCard(
                  'Estado',
                  _gpsService.currentState.name.toUpperCase(),
                  _getStateIcon(),
                  _getStateColor(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF16213e),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[400],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Botón principal (Start/Pause/Resume)
          Expanded(
            child: _buildMainControlButton(),
          ),

          const SizedBox(width: 16),

          // Botón de stop (solo visible cuando está tracking)
          if (_gpsService.currentState != CardioTrackingState.stopped)
            Expanded(
              child: _buildStopButton(),
            ),
        ],
      ),
    );
  }

  Widget _buildMainControlButton() {
    if (_isInitializing) {
      return ElevatedButton(
        onPressed: null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            SizedBox(width: 12),
            Text(
              'Iniciando GPS...',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    String buttonText;
    IconData buttonIcon;
    Color buttonColor;

    switch (_gpsService.currentState) {
      case CardioTrackingState.stopped:
        buttonText = 'Iniciar';
        buttonIcon = Icons.play_arrow;
        buttonColor = const Color(0xFF10b981);
        break;
      case CardioTrackingState.running:
        buttonText = 'Pausar';
        buttonIcon = Icons.pause;
        buttonColor = const Color(0xFFf59e0b);
        break;
      case CardioTrackingState.paused:
        buttonText = 'Reanudar';
        buttonIcon = Icons.play_arrow;
        buttonColor = const Color(0xFF10b981);
        break;
    }

    return ElevatedButton(
      onPressed: _gpsService.currentState == CardioTrackingState.stopped
          ? _startTracking
          : _pauseResumeTracking,
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonColor,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(buttonIcon, size: 24),
          const SizedBox(width: 8),
          Text(
            buttonText,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStopButton() {
    return ElevatedButton(
      onPressed: _stopTracking,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFef4444),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.stop, size: 24),
          SizedBox(width: 8),
          Text(
            'Finalizar',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStateColor() {
    switch (_gpsService.currentState) {
      case CardioTrackingState.stopped:
        return Colors.grey;
      case CardioTrackingState.running:
        return const Color(0xFF10b981);
      case CardioTrackingState.paused:
        return const Color(0xFFf59e0b);
    }
  }

  IconData _getStateIcon() {
    switch (_gpsService.currentState) {
      case CardioTrackingState.stopped:
        return Icons.stop_circle;
      case CardioTrackingState.running:
        return Icons.play_circle;
      case CardioTrackingState.paused:
        return Icons.pause_circle;
    }
  }

  String _getStateText() {
    switch (_gpsService.currentState) {
      case CardioTrackingState.stopped:
        return 'Detenido';
      case CardioTrackingState.running:
        return 'En progreso';
      case CardioTrackingState.paused:
        return 'Pausado';
    }
  }
}

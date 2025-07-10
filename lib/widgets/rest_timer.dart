import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RestTimer extends StatefulWidget {
  final int restTimeSeconds;
  final VoidCallback onTimerComplete;
  final VoidCallback onTimerCancel;

  const RestTimer({
    super.key,
    required this.restTimeSeconds,
    required this.onTimerComplete,
    required this.onTimerCancel,
  });

  @override
  State<RestTimer> createState() => _RestTimerState();
}

class _RestTimerState extends State<RestTimer> with TickerProviderStateMixin {
  Timer? _timer;
  int _remainingSeconds = 0;
  bool _isRunning = false;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.restTimeSeconds;

    _animationController = AnimationController(
      duration: Duration(seconds: widget.restTimeSeconds),
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.linear,
    ));

    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _isRunning = true;
    });

    _animationController.forward();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _remainingSeconds--;
      });

      if (_remainingSeconds <= 0) {
        _completeTimer();
      }
    });
  }

  void _pauseTimer() {
    setState(() {
      _isRunning = false;
    });
    _timer?.cancel();
    _animationController.stop();
  }

  void _resumeTimer() {
    setState(() {
      _isRunning = true;
    });

    // Reanudar la animación desde donde se quedó
    _animationController.forward();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _remainingSeconds--;
      });

      if (_remainingSeconds <= 0) {
        _completeTimer();
      }
    });
  }

  void _completeTimer() {
    _timer?.cancel();
    _animationController.reset(); // Cambiar complete() por reset()
    widget.onTimerComplete();
  }

  void _cancelTimer() {
    _timer?.cancel();
    _animationController.stop();
    widget.onTimerCancel();
  }

  void _addTime(int seconds) {
    setState(() {
      _remainingSeconds += seconds;
      // No permitir tiempo negativo
      if (_remainingSeconds < 0) {
        _remainingSeconds = 0;
      }
    });
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Color _getTimerColor() {
    if (_remainingSeconds <= 10) {
      return const Color(0xFFef4444); // Rojo - urgente
    } else if (_remainingSeconds <= 30) {
      return const Color(0xFFf59e0b); // Amarillo - advertencia
    } else {
      return const Color(0xFF10b981); // Verde - normal
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF16213e),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _getTimerColor(),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: _getTimerColor().withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Título
          Text(
            'Tiempo de Descanso',
            style: GoogleFonts.orbitron(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 20),

          // Timer circular
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return CircularProgressIndicator(
                      value: _animation.value,
                      strokeWidth: 8,
                      backgroundColor: Colors.grey[800],
                      valueColor:
                          AlwaysStoppedAnimation<Color>(_getTimerColor()),
                    );
                  },
                ),
              ),

              // Tiempo restante
              Column(
                children: [
                  Text(
                    _formatTime(_remainingSeconds),
                    style: GoogleFonts.orbitron(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: _getTimerColor(),
                    ),
                  ),
                  Text(
                    'restantes',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Botones de control
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Botón -15s
              _buildControlButton(
                icon: Icons.remove,
                label: '-15s',
                onPressed: () => _addTime(-15),
                color: const Color(0xFFef4444),
              ),

              // Botón play/pause
              _buildControlButton(
                icon: _isRunning ? Icons.pause : Icons.play_arrow,
                label: _isRunning ? 'Pausa' : 'Reanudar',
                onPressed: _isRunning ? _pauseTimer : _resumeTimer,
                color: const Color(0xFF4f46e5),
                isLarge: true,
              ),

              // Botón +15s
              _buildControlButton(
                icon: Icons.add,
                label: '+15s',
                onPressed: () => _addTime(15),
                color: const Color(0xFF10b981),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Botones de acción
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _cancelTimer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Cancelar'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _completeTimer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _getTimerColor(),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Terminar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color color,
    bool isLarge = false,
  }) {
    return Column(
      children: [
        Container(
          width: isLarge ? 60 : 45,
          height: isLarge ? 60 : 45,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(isLarge ? 30 : 22.5),
            border: Border.all(color: color, width: 2),
          ),
          child: IconButton(
            onPressed: onPressed,
            icon: Icon(
              icon,
              color: color,
              size: isLarge ? 30 : 24,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/user_progress.dart';
import '../models/achievement_model.dart';

class ProfileScreen extends StatefulWidget {
  final UserProgress userProgress;

  const ProfileScreen({super.key, required this.userProgress});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AchievementService _achievementService = AchievementService();

  List<Achievement> _achievements = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAchievements();
  }

  Future<void> _loadAchievements() async {
    // Por ahora creamos logros de ejemplo
    // En versiones futuras se cargarán desde SharedPreferences
    _achievements = _achievementService.getAllAchievements();

    // Simular algunos logros desbloqueados según el progreso actual
    _updateAchievementsBasedOnProgress();

    setState(() {
      _isLoading = false;
    });
  }

  void _updateAchievementsBasedOnProgress() {
    Map<String, dynamic> userStats = {
      'total_workouts': widget.userProgress.completedWorkouts.length,
      'hunter_level': widget.userProgress.hunterLevel,
      'current_streak': widget.userProgress.currentStreak,
      'total_exercises_completed':
          widget.userProgress.completedWorkouts.length * 4, // Estimación
      'pushups_completed':
          (widget.userProgress.exerciseLevels['Empuje'] ?? 1) > 1 ? 1 : 0,
      'pullups_completed':
          (widget.userProgress.exerciseLevels['Jalón'] ?? 1) > 1 ? 1 : 0,
      'perfect_days_streak': 0, // Por implementar
      'night_workouts': 0, // Por implementar
    };

    List<Achievement> newAchievements =
        _achievementService.checkForNewAchievements(userStats, _achievements);

    // Actualizar logros desbloqueados
    for (Achievement newAchievement in newAchievements) {
      int index = _achievements.indexWhere((a) => a.id == newAchievement.id);
      if (index != -1) {
        _achievements[index] = newAchievement;
      }
    }
  }

  String _getRankTitle() {
    int level = widget.userProgress.hunterLevel;
    if (level >= 20) return 'Rango S';
    if (level >= 15) return 'Rango A';
    if (level >= 10) return 'Rango B';
    if (level >= 5) return 'Rango C';
    if (level >= 3) return 'Rango D';
    return 'Rango E';
  }

  Color _getRankColor() {
    int level = widget.userProgress.hunterLevel;
    if (level >= 20) return const Color(0xFFfbbf24); // Dorado
    if (level >= 15) return const Color(0xFF8b5cf6); // Morado
    if (level >= 10) return const Color(0xFF06b6d4); // Cian
    if (level >= 5) return const Color(0xFF10b981); // Verde
    if (level >= 3) return const Color(0xFFf59e0b); // Amarillo
    return const Color(0xFF6b7280); // Gris
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Perfil del Cazador'),
          backgroundColor: const Color(0xFF1a1a2e),
        ),
        body: const Center(
          child: CircularProgressIndicator(color: Color(0xFF4f46e5)),
        ),
      );
    }

    List<Achievement> unlockedAchievements =
        _achievements.where((a) => a.isUnlocked).toList();
    List<Achievement> lockedAchievements =
        _achievements.where((a) => !a.isUnlocked).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Perfil del Cazador',
          style: GoogleFonts.orbitron(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF1a1a2e),
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0f172a), Color(0xFF1a1a2e)],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Header del Cazador
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF16213e),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _getRankColor(), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: _getRankColor().withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Avatar del cazador
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: _getRankColor().withOpacity(0.2),
                        borderRadius: BorderRadius.circular(40),
                        border: Border.all(color: _getRankColor(), width: 3),
                      ),
                      child: Icon(
                        Icons.person,
                        size: 40,
                        color: _getRankColor(),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Rango y nivel
                    Text(
                      _getRankTitle(),
                      style: GoogleFonts.orbitron(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: _getRankColor(),
                      ),
                    ),

                    Text(
                      'Nivel ${widget.userProgress.hunterLevel}',
                      style: GoogleFonts.orbitron(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Barra de XP
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'XP: ${widget.userProgress.currentXP}',
                              style: const TextStyle(
                                color: Color(0xFF06b6d4),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Siguiente: ${widget.userProgress.xpToNextLevel}',
                              style: const TextStyle(
                                color: Color(0xFF06b6d4),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: widget.userProgress.getXPProgress(),
                            backgroundColor: Colors.grey[800],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _getRankColor(),
                            ),
                            minHeight: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Estadísticas
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF16213e),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Estadísticas',
                      style: GoogleFonts.orbitron(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Grid de estadísticas
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.5,
                      children: [
                        _buildStatCard(
                          'XP Total',
                          '${widget.userProgress.totalXP}',
                          Icons.star,
                          const Color(0xFF06b6d4),
                        ),
                        _buildStatCard(
                          'Racha Actual',
                          '${widget.userProgress.currentStreak} días',
                          Icons.local_fire_department,
                          const Color(0xFFf59e0b),
                        ),
                        _buildStatCard(
                          'Entrenamientos',
                          '${widget.userProgress.completedWorkouts.length}',
                          Icons.fitness_center,
                          const Color(0xFF10b981),
                        ),
                        _buildStatCard(
                          'Logros',
                          '${unlockedAchievements.length}/${_achievements.length}',
                          Icons.emoji_events,
                          const Color(0xFF8b5cf6),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Niveles por tipo de ejercicio
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF16213e),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Progreso por Categoría',
                      style: GoogleFonts.orbitron(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...widget.userProgress.exerciseLevels.entries.map((entry) {
                      return _buildExerciseTypeProgress(entry.key, entry.value);
                    }),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Logros
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF16213e),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Logros',
                      style: GoogleFonts.orbitron(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Logros desbloqueados
                    if (unlockedAchievements.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Desbloqueados',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF10b981),
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...unlockedAchievements.map((achievement) {
                            return _buildAchievementTile(achievement, true);
                          }),
                        ],
                      ),

                    // Logros bloqueados (mostrar solo algunos)
                    if (lockedAchievements.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          const Text(
                            'Por Desbloquear',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...lockedAchievements.take(3).map((achievement) {
                            return _buildAchievementTile(achievement, false);
                          }),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
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
          ),
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseTypeProgress(String type, int level) {
    Color typeColor;
    IconData typeIcon;

    switch (type) {
      case 'Empuje':
        typeColor = const Color(0xFFef4444);
        typeIcon = Icons.fitness_center;
        break;
      case 'Jalón':
        typeColor = const Color(0xFF10b981);
        typeIcon = Icons.accessibility_new;
        break;
      case 'Piernas':
        typeColor = const Color(0xFFf59e0b);
        typeIcon = Icons.directions_run;
        break;
      case 'Core':
        typeColor = const Color(0xFF8b5cf6);
        typeIcon = Icons.self_improvement;
        break;
      default:
        typeColor = Colors.grey;
        typeIcon = Icons.fitness_center;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: typeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: typeColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(typeIcon, color: typeColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  type,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: typeColor,
                  ),
                ),
                Text(
                  'Nivel $level',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: typeColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Lvl $level',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementTile(Achievement achievement, bool isUnlocked) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isUnlocked
            ? achievement.color.withOpacity(0.1)
            : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isUnlocked
              ? achievement.color.withOpacity(0.3)
              : Colors.grey.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isUnlocked
                  ? achievement.color.withOpacity(0.2)
                  : Colors.grey.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              achievement.icon,
              color: isUnlocked ? achievement.color : Colors.grey,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isUnlocked ? achievement.color : Colors.grey,
                  ),
                ),
                Text(
                  achievement.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: isUnlocked ? Colors.grey[300] : Colors.grey[600],
                  ),
                ),
                if (isUnlocked && achievement.unlockedDate != null)
                  Text(
                    'Desbloqueado: ${_formatDate(achievement.unlockedDate!)}',
                    style: TextStyle(
                      fontSize: 10,
                      color: achievement.color.withOpacity(0.7),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ),
          if (isUnlocked)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: achievement.color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star, size: 12, color: Colors.white),
                  const SizedBox(width: 2),
                  Text(
                    '+${achievement.xpReward}',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            )
          else
            const Icon(Icons.lock, color: Colors.grey, size: 20),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

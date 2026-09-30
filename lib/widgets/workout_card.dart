import 'package:flutter/material.dart';
import 'package:gym_logger/data/workout_progress.dart';
import 'package:gym_logger/models/exercise.dart';
import 'package:gym_logger/screens/workout/workout_screen.dart';
import 'package:gym_logger/theme/app_colors.dart';

class WorkoutCard extends StatelessWidget {
  final int week;
  final int day;
  final String exercise;
  final List<Exercise> exercises;
  final WorkoutProgress progress;
  final bool ready;
  const WorkoutCard({
    super.key,
    required this.week,
    required this.day,
    required this.exercise,
    required this.exercises,
    required this.progress,
    required this.ready,
  });
  @override
  Widget build(BuildContext context) {
    final complete = progress.isCompleted(week, exercise);
    final started = progress.hasEntries(week, exercise);
    final logged = progress.loggedWorkSets(week, exercise, exercises);
    final total = exercises.fold<int>(0, (sum, e) => sum + e.workSets);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: AppColors.surfaceLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: ready
              ? AppColors.primary.withValues(alpha: 0.5)
              : AppColors.border,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => WorkoutScreen(
              week: week,
              exercise: exercise,
              exercises: exercises,
              progress: progress,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'WORKOUT ${day.toString().padLeft(2, '0')} · ${complete
                          ? 'COMPLETED'
                          : started
                          ? 'IN PROGRESS'
                          : ready
                          ? 'READY'
                          : 'NOT STARTED'}',
                      style: TextStyle(
                        fontSize: 11,
                        color: complete || ready || started
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      exercise,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${exercises.length} exercises · $logged/$total sets logged',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                complete ? Icons.check_circle : Icons.chevron_right,
                color: complete ? AppColors.primary : AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

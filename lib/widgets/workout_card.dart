import 'package:flutter/material.dart';
import 'package:gym_logger/data/workout_progress.dart';
import 'package:gym_logger/models/exercise.dart';
import 'package:gym_logger/screens/workout/workout_screen.dart';

class WorkoutCard extends StatelessWidget {
  final int week;
  final int day;
  final String exercise;
  final List<Exercise> exercises;
  final List<Exercise> previousExercises;
  final WorkoutProgress progress;
  final bool ready;
  const WorkoutCard({
    super.key,
    required this.week,
    required this.day,
    required this.exercise,
    required this.exercises,
    this.previousExercises = const [],
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
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: ready
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.5)
              : Theme.of(context).colorScheme.outline,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => WorkoutScreen(
              week: week,
              workoutName: exercise,
              exercises: exercises,
              previousExercises: previousExercises,
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
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurfaceVariant,
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
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                complete ? Icons.check_circle : Icons.chevron_right,
                color: complete
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

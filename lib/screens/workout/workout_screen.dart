import 'package:flutter/material.dart';
import 'package:gym_logger/data/workout_progress.dart';
import 'package:gym_logger/models/exercise.dart';
import 'package:gym_logger/widgets/exercise_accordion.dart';
import 'package:gym_logger/widgets/save_status.dart';

class WorkoutScreen extends StatelessWidget {
  final int week;
  final String workoutName;
  final List<Exercise> exercises;
  final List<Exercise> previousExercises;
  final WorkoutProgress progress;
  const WorkoutScreen({
    super.key,
    required this.week,
    required this.workoutName,
    required this.exercises,
    this.previousExercises = const [],
    required this.progress,
  });

  Exercise? _previousExerciseFor(Exercise current) {
    // Follow the prescribed exercise even when a different variation was used.
    for (final candidate in previousExercises) {
      if (candidate.name == current.name) return candidate;
    }
    for (final candidate in previousExercises) {
      if (progress.movementFor(week - 1, workoutName, candidate) ==
          progress.movementFor(week, workoutName, current)) {
        return candidate;
      }
    }
    return null;
  }

  String? _previousMovementFor(Exercise current) {
    final previous = _previousExerciseFor(current);
    return previous == null
        ? null
        : progress.movementFor(week - 1, workoutName, previous);
  }

  SetEntry? _previousEntryFor(Exercise current, int workSet) {
    final previous = _previousExerciseFor(current);
    if (previous == null) return null;
    final previousWorkSets = previous.indexedWorkSets;
    if (workSet < 0 || workSet >= previousWorkSets.length) return null;
    final entry = progress.entry(
      week - 1,
      workoutName,
      previous.id,
      previousWorkSets[workSet].key,
    );
    return entry.weight.isEmpty && entry.reps.isEmpty ? null : entry;
  }

  Future<void> _finishWorkout(BuildContext context) async {
    final saved = await progress.finish(week, workoutName);
    if (saved && context.mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: progress,
    builder: (context, _) {
      final complete = progress.isCompleted(week, workoutName);
      final logged = progress.loggedWorkSets(week, workoutName, exercises);
      final total = exercises.fold<int>(0, (sum, e) => sum + e.workSets);
      final showPrevious =
          week > 1 &&
          progress.completedCount(week - 1) == progress.workouts.length;

      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Week $week · $workoutName',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ExerciseAccordion(
              exercises: exercises,
              readOnly: complete,
              movementFor: (exercise) =>
                  progress.movementFor(week, workoutName, exercise),
              onMovementChanged: (exercise, name) =>
                  progress.selectMovement(week, workoutName, exercise, name),
              entryFor: (id, set) => progress.entry(week, workoutName, id, set),
              previousEntryFor: showPrevious ? _previousEntryFor : null,
              previousMovementFor: showPrevious ? _previousMovementFor : null,
              onSetChanged: (id, set, entry) =>
                  progress.updateSet(week, workoutName, id, set, entry),
            ),
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SaveStatus(progress: progress),
                const SizedBox(height: 6),
                Text(
                  complete
                      ? 'Workout completed'
                      : '$logged of $total sets logged automatically',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                if (complete)
                  OutlinedButton(
                    onPressed: progress.saving
                        ? null
                        : () => progress.reopen(week, workoutName),
                    child: const Text('Reopen workout'),
                  )
                else
                  ElevatedButton.icon(
                    onPressed: progress.saving
                        ? null
                        : () => _finishWorkout(context),
                    icon: const Icon(Icons.check),
                    label: const Text('Finish workout'),
                  ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

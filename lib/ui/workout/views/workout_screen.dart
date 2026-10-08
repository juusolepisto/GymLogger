import 'package:flutter/material.dart';
import 'package:gym_logger/ui/workout/view_models/workout_view_model.dart';
import 'package:gym_logger/models/exercise.dart';
import 'package:gym_logger/ui/core/widgets/exercise_accordion.dart';
import 'package:gym_logger/ui/core/widgets/save_status.dart';

class WorkoutScreen extends StatelessWidget {
  final int week;
  final String workoutName;
  final List<Exercise> exercises;
  final List<Exercise> previousExercises;
  final WorkoutViewModel progress;
  const WorkoutScreen({
    super.key,
    required this.week,
    required this.workoutName,
    required this.exercises,
    this.previousExercises = const [],
    required this.progress,
  });

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
      final showPrevious = progress.canShowPreviousWeek(week);

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
              previousLabel: week == 1 ? 'Previous run - Week 12' : 'Last week',
              readOnly: complete,
              movementFor: (exercise) =>
                  progress.movementFor(week, workoutName, exercise),
              onMovementChanged: (exercise, name) =>
                  progress.selectMovement(week, workoutName, exercise, name),
              entryFor: (id, set) => progress.entry(week, workoutName, id, set),
              previousEntryFor: showPrevious
                  ? (exercise, set) => progress.previousEntryFor(
                      week,
                      workoutName,
                      exercise,
                      previousExercises,
                      set,
                    )
                  : null,
              previousMovementFor: showPrevious
                  ? (exercise) => progress.previousMovementFor(
                      week,
                      workoutName,
                      exercise,
                      previousExercises,
                    )
                  : null,
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

import 'package:flutter/material.dart';
import 'package:gym_logger/data/workout_progress.dart';
import 'package:gym_logger/models/exercise.dart';
import 'package:gym_logger/widgets/exercise_accordion.dart';
import 'package:gym_logger/widgets/save_status.dart';

class WorkoutScreen extends StatelessWidget {
  final int week;
  final String exercise;
  final List<Exercise> exercises;
  final WorkoutProgress progress;
  const WorkoutScreen({
    super.key,
    required this.week,
    required this.exercise,
    required this.exercises,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: progress,
    builder: (context, _) {
      final complete = progress.isCompleted(week, exercise);
      final logged = progress.loggedWorkSets(week, exercise, exercises);
      final total = exercises.fold<int>(0, (sum, e) => sum + e.workSets);
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Week $week · $exercise',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ExerciseAccordion(
              exercises: exercises,
              readOnly: complete,
              entryFor: (id, set) => progress.entry(week, exercise, id, set),
              onSetChanged: (id, set, entry) =>
                  progress.updateSet(week, exercise, id, set, entry),
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
                        : () => progress.reopen(week, exercise),
                    child: const Text('Reopen workout'),
                  )
                else
                  ElevatedButton.icon(
                    onPressed:
                        progress.saving ||
                            !progress.canFinish(week, exercise, exercises)
                        ? null
                        : () async {
                            final saved = await progress.finish(
                              week,
                              exercise,
                              exercises,
                            );
                            if (saved && context.mounted) {
                              Navigator.of(context).pop();
                            }
                          },
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

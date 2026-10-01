import 'package:flutter/material.dart';
import 'package:gym_logger/data/workout_program.dart';
import 'package:gym_logger/data/workout_progress.dart';
import 'package:gym_logger/widgets/save_status.dart';
import 'package:gym_logger/widgets/week_accordion.dart';

class ProgramOverview extends StatelessWidget {
  final Map<int, WorkoutProgram> plans;
  final WorkoutProgress progress;
  const ProgramOverview({
    super.key,
    required this.plans,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: progress,
    builder: (context, _) => SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Workouts per week',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 4, label: Text('4 workouts')),
                ButtonSegment(value: 5, label: Text('5 workouts')),
              ],
              selected: {progress.workoutsPerWeek},
              onSelectionChanged: (selection) =>
                  progress.selectPlan(selection.single),
              showSelectedIcon: false,
              style: ButtonStyle(
                foregroundColor: WidgetStateProperty.resolveWith<Color?>((
                  states,
                ) {
                  if (!states.contains(WidgetState.selected)) {
                    return Theme.of(context).colorScheme.onSurface;
                  }

                  return Theme.of(context).colorScheme.primary;
                }),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Each plan keeps its own progress.',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Select your week and workout',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 6),
          SaveStatus(progress: progress),
          const SizedBox(height: 20),
          WeekAccordion(
            key: ValueKey(progress.workoutsPerWeek),
            program: plans[progress.workoutsPerWeek]!,
            progress: progress,
          ),
        ],
      ),
    ),
  );
}

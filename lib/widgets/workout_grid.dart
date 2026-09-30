import 'package:flutter/material.dart';
import 'package:gym_logger/data/workout_program.dart';
import 'package:gym_logger/data/workout_progress.dart';
import 'package:gym_logger/widgets/workout_card.dart';

class WorkoutGrid extends StatelessWidget {
  final int week;
  final WorkoutProgram program;
  final WorkoutProgress progress;
  const WorkoutGrid({
    super.key,
    required this.week,
    required this.program,
    required this.progress,
  });
  @override
  Widget build(BuildContext context) {
    final workouts = program.workoutsForWeek(week);
    final next = workouts
        .where((w) => !progress.isCompleted(week, w))
        .firstOrNull;
    // A single column leaves room for labels at phone widths and large text sizes.
    return Column(
      children: [
        for (final entry in workouts.asMap().entries)
          WorkoutCard(
            week: week,
            day: entry.key + 1,
            exercise: entry.value,
            exercises: program.exercisesFor(week, entry.value),
            progress: progress,
            ready: progress.currentWeek == week && next == entry.value,
          ),
      ],
    );
  }
}

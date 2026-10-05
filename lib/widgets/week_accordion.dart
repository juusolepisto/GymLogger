import 'package:flutter/material.dart';
import 'package:gym_logger/data/workout_program.dart';
import 'package:gym_logger/data/workout_progress.dart';
import 'package:gym_logger/widgets/week_header.dart';
import 'package:gym_logger/widgets/workout_grid.dart';

class WeekAccordion extends StatefulWidget {
  final WorkoutProgram program;
  final WorkoutProgress progress;
  const WeekAccordion({
    super.key,
    required this.program,
    required this.progress,
  });
  @override
  State<WeekAccordion> createState() => _WeekAccordionState();
}

class _WeekAccordionState extends State<WeekAccordion> {
  int? _openWeek;
  int? _currentWeek;
  @override
  void initState() {
    super.initState();
    _currentWeek = widget.progress.currentWeek;
    _openWeek = _currentWeek ?? 12;
    widget.progress.addListener(_onProgress);
  }

  void _onProgress() {
    final current = widget.progress.currentWeek;
    setState(() {
      if (current != _currentWeek) _openWeek = current ?? 12;
      _currentWeek = current;
    });
  }

  Future<void> _confirmResetWeek(int week) async {
    final progress = widget.progress;
    final plan = progress.workoutsPerWeek;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reset week $week?'),
        content: Text(
          'This will clear all weights, reps, and workout completion for '
          'week $week in your $plan-workout plan. Other weeks and plans '
          'will be kept. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Reset week'),
          ),
        ],
      ),
    );
    if (!mounted ||
        confirmed != true ||
        progress.saving ||
        progress.workoutsPerWeek != plan) {
      return;
    }
    await progress.resetWeek(week);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          progress.saveError == null
              ? 'Week $week progress reset.'
              : 'Week $week was cleared, but could not be saved. Use Retry save.',
        ),
      ),
    );
  }

  @override
  void dispose() {
    widget.progress.removeListener(_onProgress);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
    children: [
      if (_currentWeek == null)
        Padding(
          padding: EdgeInsets.only(bottom: 16),
          child: Text(
            'Program completed',
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      for (var week = 1; week <= 12; week++)
        Card(
          margin: const EdgeInsets.only(bottom: 12),
          color: Theme.of(context).colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Theme.of(context).colorScheme.outline),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              InkWell(
                onTap: () =>
                    setState(() => _openWeek = _openWeek == week ? null : week),
                child: WeekHeader(
                  week: week,
                  completedCount: widget.progress.completedCount(week),
                  workoutCount: widget.program.workoutsForWeek(week).length,
                  current: _currentWeek == week,
                  expanded: _openWeek == week,
                ),
              ),
              if (_openWeek == week)
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  child: Column(
                    children: [
                      Divider(
                        color: Theme.of(context).colorScheme.outline,
                        height: 1,
                      ),
                      const SizedBox(height: 12),
                      WorkoutGrid(
                        week: week,
                        program: widget.program,
                        progress: widget.progress,
                      ),
                      ElevatedButton.icon(
                        onPressed: widget.progress.saving
                            ? null
                            : () => _confirmResetWeek(week),
                        icon: const Icon(Icons.refresh),
                        label: Text('Reset Progress for week $week'),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
    ],
  );
}

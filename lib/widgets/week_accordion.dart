import 'package:flutter/material.dart';
import 'package:gym_logger/data/workout_program.dart';
import 'package:gym_logger/data/workout_progress.dart';
import 'package:gym_logger/theme/app_colors.dart';
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

  @override
  void dispose() {
    widget.progress.removeListener(_onProgress);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
    children: [
      if (_currentWeek == null)
        const Padding(
          padding: EdgeInsets.only(bottom: 16),
          child: Text(
            'Program completed',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      for (var week = 1; week <= 12; week++)
        Card(
          margin: const EdgeInsets.only(bottom: 12),
          color: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AppColors.border),
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
                      const Divider(color: AppColors.border, height: 1),
                      const SizedBox(height: 12),
                      WorkoutGrid(
                        week: week,
                        program: widget.program,
                        progress: widget.progress,
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

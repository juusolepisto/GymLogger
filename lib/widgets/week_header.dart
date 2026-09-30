import 'package:flutter/material.dart';
import 'package:gym_logger/theme/app_colors.dart';

class WeekHeader extends StatelessWidget {
  final int week;
  final int completedCount;
  final int workoutCount;
  final bool current;
  final bool expanded;
  const WeekHeader({
    super.key,
    required this.week,
    required this.completedCount,
    required this.workoutCount,
    required this.current,
    required this.expanded,
  });
  @override
  Widget build(BuildContext context) {
    final complete = completedCount == workoutCount;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  complete
                      ? 'COMPLETED'
                      : current
                      ? 'IN PROGRESS'
                      : 'WEEK ${week.toString().padLeft(2, '0')}',
                  style: TextStyle(
                    fontSize: 12,
                    color: complete || current
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Week $week',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$completedCount of $workoutCount workouts complete',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: completedCount / workoutCount,
                    minHeight: 4,
                    backgroundColor: AppColors.surfaceLight,
                    color: AppColors.primary,
                    semanticsLabel: 'Week $week completion',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          if (complete)
            const Icon(Icons.check_circle, size: 20, color: AppColors.primary),
          Icon(
            expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }
}

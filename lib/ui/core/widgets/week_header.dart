import 'package:flutter/material.dart';

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
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurfaceVariant,
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
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: completedCount / workoutCount,
                    minHeight: 4,
                    backgroundColor: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest,
                    color: Theme.of(context).colorScheme.primary,
                    semanticsLabel: 'Week $week completion',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          if (complete)
            Icon(
              Icons.check_circle,
              size: 20,
              color: Theme.of(context).colorScheme.primary,
            ),
          Icon(
            expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }
}

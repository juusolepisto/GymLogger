import 'package:flutter/material.dart';
import 'package:gym_logger/models/exercise.dart';

class ExerciseHeader extends StatelessWidget {
  const ExerciseHeader({
    super.key,
    required this.exercise,
    required this.index,
    required this.exerciseCount,
    required this.open,
    required this.exerciseLogged,
    required this.onToggle,
    this.movement,
    this.onMovementChanged,
  });
  final Exercise exercise;
  final int index;
  final int exerciseCount;
  final bool open;
  final bool exerciseLogged;
  final VoidCallback onToggle;
  final String? movement;
  final ValueChanged<String>? onMovementChanged;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onToggle,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 12,
                    runSpacing: 4,
                    children: <Widget>[
                      Text(
                        open
                            ? 'Exercise ${index + 1} of $exerciseCount'
                            : '#${(index + 1).toString().padLeft(2, '0')}',
                        style: TextStyle(
                          fontSize: 12,
                          color: exerciseLogged
                              ? colors.primary
                              : colors.onSurfaceVariant,
                        ),
                      ),
                      if (exerciseLogged)
                        Text(
                          'Complete',
                          style: TextStyle(fontSize: 12, color: colors.primary),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  if (open && exercise.movementNames.length > 1)
                    DropdownButtonHideUnderline(
                      child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                            ),
                          decoration: BoxDecoration(
                            border: Border.all(color: colors.primary),
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: [
                              BoxShadow(
                                color: colors.onSurfaceVariant.withValues(alpha: 0.1),
                                blurRadius: 1,
                              ),
                            ],
                          ),
                          child: DropdownButton<String>(
                          value: movement ?? exercise.name,
                          isExpanded: false,
                          itemHeight: null,
                          style: Theme.of(context).textTheme.titleMedium,
                          items: [
                            for (final name in exercise.movementNames)
                              DropdownMenuItem(
                                value: name,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  child: Text(name),
                                ),
                              ),
                          ],
                          onChanged: onMovementChanged == null
                              ? null
                              : (value) {
                                  if (value != null) onMovementChanged!(value);
                                },
                        ),
                      )
                    )
                  else
                    Text(
                      movement ?? exercise.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    '${exercise.workSets} work sets · ${exercise.repSummary} reps',
                    style: TextStyle(
                      fontSize: 12,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              open ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: colors.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:gym_logger/models/set_entry.dart';
import 'package:flutter/material.dart';
import 'package:gym_logger/models/exercise.dart';

import 'exercise_header.dart';
import 'exercise_links_sheet.dart';
import 'exercise_set_row.dart';

class ExerciseCard extends StatelessWidget {
  const ExerciseCard({
    super.key,
    required this.exercise,
    required this.index,
    required this.exerciseCount,
    required this.open,
    required this.onToggle,
    this.entryFor,
    this.previousEntryFor,
    this.previousMovement,
    this.previousLabel = 'Last week',
    this.onSetChanged,
    this.readOnly = false,
    this.movement,
    this.onMovementChanged,
  });
  final Exercise exercise;
  final int index;
  final int exerciseCount;
  final bool open;
  final VoidCallback onToggle;
  final SetEntry Function(int set)? entryFor;
  final SetEntry? Function(int workSet)? previousEntryFor;
  final String previousLabel;
  final String? previousMovement;
  final void Function(int set, SetEntry entry)? onSetChanged;
  final bool readOnly;
  final String? movement;
  final ValueChanged<String>? onMovementChanged;

  void _showLinks(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => ExerciseLinksSheet(exercise: exercise),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final workSets = exercise.indexedWorkSets;
    final loggedSets = workSets.where((set) {
      return entryFor?.call(set.key).logged ?? false;
    }).length;

    final exerciseLogged = workSets.isNotEmpty && loggedSets == workSets.length;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ExerciseHeader(
            exercise: exercise,
            index: index,
            exerciseCount: exerciseCount,
            open: open,
            exerciseLogged: exerciseLogged,
            onToggle: onToggle,
            movement: movement,
            onMovementChanged: readOnly ? null : onMovementChanged,
          ),
          // Preserve entered values and completion when another section opens.
          Offstage(
            offstage: !open,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(color: colors.outline),
                  Wrap(
                    spacing: 12,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        exercise.rest == '-'
                            ? 'Superset'
                            : 'Rest: ${exercise.rest}',
                        style: TextStyle(color: colors.onSurfaceVariant),
                      ),
                      TextButton.icon(
                        onPressed: () => _showLinks(context),
                        icon: const Icon(Icons.play_circle_outline, size: 18),
                        label: const Text('Videos & alternatives'),
                      ),
                    ],
                  ),
                  Text(
                    'Warm-up: ${exercise.warmupRange} ${exercise.warmupRange == '1' ? 'set' : 'sets'}',
                    style: TextStyle(
                      fontSize: 12,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  if (exercise.intensity != '-')
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text('Last set: ${exercise.intensity}'),
                    ),
                  const SizedBox(height: 16),
                  const Row(
                    children: [
                      SizedBox(
                        width: 36,
                        child: Text('SET', style: TextStyle(fontSize: 10)),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          'TARGET / RIR',
                          style: TextStyle(fontSize: 10),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          'WEIGHT',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 10),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'REPS',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 10),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  for (final set in workSets)
                    ExerciseSetRow(
                      key: ValueKey('${exercise.id}-${set.key}'),
                      prescription: set.value,
                      initialEntry: entryFor?.call(set.key) ?? const SetEntry(),
                      previousEntry: previousEntryFor?.call(
                        set.key - exercise.warmupSets,
                      ),
                      previousMovement: previousMovement,
                      previousLabel: previousLabel,
                      onChanged: (value) => onSetChanged?.call(set.key, value),
                      readOnly: readOnly,
                      label: '${set.key - exercise.warmupSets + 1}',
                    ),
                  const SizedBox(height: 12),
                  Text(
                    exercise.notes,
                    style: TextStyle(
                      fontSize: 12,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

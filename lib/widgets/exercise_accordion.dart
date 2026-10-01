import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gym_logger/data/workout_progress.dart';
import 'package:gym_logger/models/exercise.dart';
import 'package:url_launcher/url_launcher.dart';

class ExerciseAccordion extends StatefulWidget {
  final List<Exercise> exercises;
  final SetEntry Function(int exercise, int set)? entryFor;
  final SetEntry? Function(Exercise exercise, int workSet)? previousEntryFor;
  final void Function(int exercise, int set, SetEntry value)? onSetChanged;
  final bool readOnly;
  const ExerciseAccordion({
    super.key,
    required this.exercises,
    this.entryFor,
    this.previousEntryFor,
    this.onSetChanged,
    this.readOnly = false,
  });

  @override
  State<ExerciseAccordion> createState() => _ExerciseAccordionState();
}

class _ExerciseAccordionState extends State<ExerciseAccordion> {
  int? _openIndex = 0;

  Future<void> _openLink(ExerciseLink link) async {
    try {
      if (await launchUrl(
        Uri.parse(link.url),
        mode: LaunchMode.externalApplication,
      )) {
        return;
      }
    } catch (_) {
      // Keep the source URL accessible when no external handler is available.
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Could not open the video. You can copy its link.'),
      ),
    );
  }

  void _showLinks(Exercise exercise) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Exercise & alternatives',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              for (final link in [
                ExerciseLink(name: exercise.name, url: exercise.url),
                ...exercise.alternatives,
              ])
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        link.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SelectableText(
                        link.url,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Row(
                        children: [
                          TextButton.icon(
                            onPressed: () => _openLink(link),
                            icon: const Icon(Icons.open_in_new, size: 18),
                            label: const Text('Watch video'),
                          ),
                          IconButton(
                            tooltip: 'Copy link',
                            icon: const Icon(Icons.copy, size: 18),
                            onPressed: () async {
                              await Clipboard.setData(
                                ClipboardData(text: link.url),
                              );
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Link copied')),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final entry in widget.exercises.asMap().entries)
          _card(entry.key, entry.value),
      ],
    );
  }

  Widget _card(int index, Exercise exercise) {
    final open = _openIndex == index;
    final workSets = exercise.sets.asMap().entries
      .where((entry) => !entry.value.warmup)
      .toList();
    final loggedSets = workSets.where((set) {
      return widget.entryFor?.call(exercise.id, set.key).logged ?? false;
    }).length;

    final exerciseLogged = workSets.isNotEmpty && loggedSets == workSets.length;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => setState(() => _openIndex = open ? null : index),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              open
                                  ? 'Exercise ${index + 1} of ${widget.exercises.length}'
                                  : '#${(index + 1).toString().padLeft(2, '0')}',
                              style: TextStyle(
                                fontSize: 12,
                                color: exerciseLogged
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                              ),
                            ),
                            Text(
                              exerciseLogged
                                ? 'Complete'
                                : '',
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).colorScheme.primary
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          exercise.name,
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
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    open ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
          // Preserve entered values and completion when another section opens.
          Offstage(
            offstage: !open,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(color: Theme.of(context).colorScheme.outline),
                  Wrap(
                    spacing: 12,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        exercise.rest == '-'
                            ? 'Superset'
                            : 'Rest: ${exercise.rest}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => _showLinks(exercise),
                        icon: const Icon(Icons.play_circle_outline, size: 18),
                        label: const Text('Videos & alternatives'),
                      ),
                    ],
                  ),
                  Text(
                    'Warm-up: ${exercise.warmupRange} ${exercise.warmupRange == '1' ? 'set' : 'sets'}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                  for (final set in exercise.sets.asMap().entries.where(
                    (entry) => !entry.value.warmup,
                  ))
                    _SetRow(
                      key: ValueKey('${exercise.id}-${set.key}'),
                      prescription: set.value,
                      initialEntry:
                          widget.entryFor?.call(exercise.id, set.key) ??
                          const SetEntry(),
                      previousEntry: widget.previousEntryFor?.call(
                        exercise,
                        set.key - exercise.warmupSets,
                      ),
                      onChanged: (value) => widget.onSetChanged?.call(
                        exercise.id,
                        set.key,
                        value,
                      ),
                      readOnly: widget.readOnly,
                      label: '${set.key - exercise.warmupSets + 1}',
                    ),
                  const SizedBox(height: 12),
                  Text(
                    exercise.notes,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
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

class _SetRow extends StatefulWidget {
  final ExerciseSet prescription;
  final String label;
  final SetEntry initialEntry;
  final SetEntry? previousEntry;
  final ValueChanged<SetEntry> onChanged;
  final bool readOnly;
  const _SetRow({
    super.key,
    required this.prescription,
    required this.label,
    required this.initialEntry,
    this.previousEntry,
    required this.onChanged,
    required this.readOnly,
  });
  @override
  State<_SetRow> createState() => _SetRowState();
}

class _SetRowState extends State<_SetRow> {
  bool get _logged => SetEntry(weight: _weight.text, reps: _reps.text).logged;
  final _weight = TextEditingController();
  final _reps = TextEditingController();

  @override
  void initState() {
    super.initState();
    _weight.text = widget.initialEntry.weight;
    _reps.text = widget.initialEntry.reps;
  }

  void _save() {
    setState(() {});
    widget.onChanged(SetEntry(weight: _weight.text, reps: _reps.text));
  }

  @override
  void dispose() {
    _weight.dispose();
    _reps.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final set = widget.prescription;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: _logged
            ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.08)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _logged
              ? Theme.of(context).colorScheme.primary
              : Colors.transparent,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              SizedBox(
                width: 35,
                child: Text(
                  widget.label,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: set.warmup
                        ? Theme.of(context).colorScheme.onSurfaceVariant
                        : Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  set.warmup ? 'Warm-up' : '${set.reps}\nRIR ${set.rir}',
                  style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: TextField(
                  controller: _weight,
                  enabled: !widget.readOnly,
                  onChanged: (_) => _save(),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    hintText: '—',
                    semanticCounterText: 'Weight for set ${widget.label}',
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 4,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _reps,
                  enabled: !widget.readOnly,
                  onChanged: (_) => _save(),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    hintText: '—',
                    semanticCounterText: 'Reps for set ${widget.label}',
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 4,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (widget.previousEntry case final previous?)
            Padding(
              padding: const EdgeInsets.fromLTRB(35, 0, 4, 6),
              child: Text(
                'Last week: Weight ${previous.weight.isEmpty ? '—' : previous.weight} · '
                'Reps ${previous.reps.isEmpty ? '—' : previous.reps}',
                style: TextStyle(
                  fontSize: 11,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

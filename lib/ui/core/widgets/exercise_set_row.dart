import 'package:gym_logger/models/set_entry.dart';
import 'package:flutter/material.dart';
import 'package:gym_logger/models/exercise.dart';
import 'package:flutter/services.dart';

class ExerciseSetRow extends StatefulWidget {
  final ExerciseSet prescription;
  final String label;
  final SetEntry initialEntry;
  final SetEntry? previousEntry;
  final String previousLabel;
  final String? previousMovement;
  final ValueChanged<SetEntry> onChanged;
  final bool readOnly;
  const ExerciseSetRow({
    super.key,
    required this.prescription,
    required this.label,
    required this.initialEntry,
    this.previousEntry,
    this.previousMovement,
    this.previousLabel = 'Last week',
    required this.onChanged,
    required this.readOnly,
  });
  @override
  State<ExerciseSetRow> createState() => _ExerciseSetRowState();
}

class _ExerciseSetRowState extends State<ExerciseSetRow> {
  bool get _logged => SetEntry(weight: _weight.text, reps: _reps.text).logged;
  final _weight = TextEditingController();
  final _reps = TextEditingController();

  @override
  void initState() {
    super.initState();
    _weight.text = widget.initialEntry.weight;
    _reps.text = widget.initialEntry.reps;
  }

  void _onEntryChanged() {
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
    final colors = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: _logged
            ? colors.primary.withValues(alpha: 0.08)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _logged ? colors.primary : Colors.transparent,
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
                        ? colors.onSurfaceVariant
                        : colors.primary,
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  set.warmup ? 'Warm-up' : '${set.reps}\nRIR ${set.rir}',
                  style: TextStyle(
                    fontSize: 11,
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: TextField(
                  controller: _weight,
                  enabled: !widget.readOnly,
                  onChanged: (_) => _onEntryChanged(),
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
                  onChanged: (_) => _onEntryChanged(),
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
              padding: const EdgeInsets.fromLTRB(35, 5, 4, 6),
              child: Text(
                '${widget.previousLabel}: ${widget.previousMovement == null ? '' : '${widget.previousMovement} · '}'
                'Weight ${previous.weight.isEmpty ? '—' : previous.weight} · '
                'Reps ${previous.reps.isEmpty ? '—' : previous.reps}',
                style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant),
              ),
            ),
        ],
      ),
    );
  }
}

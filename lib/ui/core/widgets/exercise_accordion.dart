import 'package:gym_logger/models/set_entry.dart';
import 'package:flutter/material.dart';
import 'package:gym_logger/models/exercise.dart';

import 'exercise_card.dart';

class ExerciseAccordion extends StatefulWidget {
  final List<Exercise> exercises;
  final SetEntry Function(int exercise, int set)? entryFor;
  final SetEntry? Function(Exercise exercise, int workSet)? previousEntryFor;
  final String? Function(Exercise exercise)? previousMovementFor;
  final void Function(int exercise, int set, SetEntry value)? onSetChanged;
  final String previousLabel;
  final bool readOnly;
  final String Function(Exercise exercise)? movementFor;
  final void Function(Exercise exercise, String name)? onMovementChanged;
  const ExerciseAccordion({
    super.key,
    required this.exercises,
    this.entryFor,
    this.previousEntryFor,
    this.previousMovementFor,
    this.previousLabel = 'Last week',
    this.onSetChanged,
    this.readOnly = false,
    this.movementFor,
    this.onMovementChanged,
  });

  @override
  State<ExerciseAccordion> createState() => _ExerciseAccordionState();
}

class _ExerciseAccordionState extends State<ExerciseAccordion> {
  int? _openIndex = 0;

  void _toggleExercise(int index) {
    setState(() => _openIndex = _openIndex == index ? null : index);
  }

  @override
  Widget build(BuildContext context) => Column(
    children: [
      for (final entry in widget.exercises.asMap().entries)
        ExerciseCard(
          key: ValueKey(entry.value.id),
          exercise: entry.value,
          index: entry.key,
          exerciseCount: widget.exercises.length,
          open: _openIndex == entry.key,
          onToggle: () => _toggleExercise(entry.key),
          entryFor: widget.entryFor == null
              ? null
              : (set) => widget.entryFor!(entry.value.id, set),
          previousEntryFor: widget.previousEntryFor == null
              ? null
              : (set) => widget.previousEntryFor!(entry.value, set),
          previousLabel: widget.previousLabel,
          previousMovement: widget.previousMovementFor?.call(entry.value),
          onSetChanged: (set, value) =>
              widget.onSetChanged?.call(entry.value.id, set, value),
          readOnly: widget.readOnly,
          movement: widget.movementFor?.call(entry.value),
          onMovementChanged: widget.onMovementChanged == null
              ? null
              : (name) => widget.onMovementChanged!(entry.value, name),
        ),
    ],
  );
}

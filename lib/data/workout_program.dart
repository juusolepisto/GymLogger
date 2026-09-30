import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:gym_logger/models/exercise.dart';

class WorkoutProgram {
  static const workouts = ['Upper', 'Lower', 'Push', 'Pull'];
  static const fiveDayWorkouts = [...workouts, 'Arms'];
  static List<String> workoutsFor(int days) => switch (days) {
    4 => workouts,
    5 => fiveDayWorkouts,
    _ => throw ArgumentError.value(days, 'days', 'Choose 4 or 5 workouts'),
  };
  static final Future<WorkoutProgram> instance = _load();
  static final Future<Map<int, WorkoutProgram>> plans = _loadPlans();
  final List<dynamic> _workouts;
  WorkoutProgram.fromJson(this._workouts);
  List<String> workoutsForWeek(int week) => List.unmodifiable(
    _workouts
        .cast<Map<String, dynamic>>()
        .where((w) => w['week'] == week)
        .map((w) => w['name'] as String),
  );
  static Future<Map<int, WorkoutProgram>> _loadPlans() async => {
    4: await instance,
    5: WorkoutProgram.fromJson(
      jsonDecode(
        await rootBundle.loadString('assets/data/workout_program_5x.json'),
      ) as List<dynamic>,
    ),
  };
  static Future<WorkoutProgram> _load() async => WorkoutProgram.fromJson(
    jsonDecode(await rootBundle.loadString('assets/data/workout_program.json'))
        as List<dynamic>,
  );
  List<Exercise> exercisesFor(int week, String workout) {
    final entry = _workouts.cast<Map<String, dynamic>>().firstWhere(
      (entry) => entry['week'] == week && entry['name'] == workout,
    );
    return List.unmodifiable(
      (entry['exercises'] as List).map(
        (e) => Exercise.fromJson(e as Map<String, dynamic>),
      ),
    );
  }
}

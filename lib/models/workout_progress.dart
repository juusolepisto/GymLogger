import 'exercise.dart';
import 'set_entry.dart';
import 'workout_program.dart';

/// Workout state and rules, independent of Flutter and device storage.
class WorkoutProgress {
  final Map<String, SetEntry> _sets = {};
  final Map<String, String> _movements = {};
  final Set<String> _completed = {};
  int _workoutsPerWeek = 4;
  int get workoutsPerWeek => _workoutsPerWeek;
  List<String> get workouts => WorkoutProgram.workoutsFor(_workoutsPerWeek);
  WorkoutProgress();

  String _workoutKey(int week, String workout) =>
      '$_workoutsPerWeek/$week/$workout';
  String _setKey(int week, String workout, int exercise, int set) =>
      '${_workoutKey(week, workout)}/$exercise/$set';
  SetEntry entry(int week, String workout, int exercise, int set) =>
      _sets[_setKey(week, workout, exercise, set)] ?? const SetEntry();
  bool isCompleted(int week, String workout) =>
      _completed.contains(_workoutKey(week, workout));

  String movementFor(int week, String workout, Exercise exercise) {
    final saved = _movements['${_workoutKey(week, workout)}/${exercise.id}'];
    return exercise.movementNames.contains(saved) ? saved! : exercise.name;
  }

  void selectMovement(
    int week,
    String workout,
    Exercise exercise,
    String name,
  ) {
    if (!exercise.movementNames.contains(name)) {
      throw ArgumentError.value(name, 'name', 'Unknown exercise movement');
    }
    final key = '${_workoutKey(week, workout)}/${exercise.id}';
    if (name == exercise.name) {
      _movements.remove(key);
    } else {
      _movements[key] = name;
    }
    _completed.remove(_workoutKey(week, workout));
  }

  int completedCount(int week) =>
      workouts.where((w) => isCompleted(week, w)).length;

  bool canShowPreviousWeek(int week) =>
      week > 1 && completedCount(week - 1) == workouts.length;

  Exercise? previousExerciseFor(
    int week,
    String workout,
    Exercise current,
    List<Exercise> previousExercises,
  ) {
    // Follow the prescription even when a different movement was selected.
    for (final candidate in previousExercises) {
      if (candidate.name == current.name) return candidate;
    }
    for (final candidate in previousExercises) {
      if (movementFor(week - 1, workout, candidate) ==
          movementFor(week, workout, current)) {
        return candidate;
      }
    }
    return null;
  }

  SetEntry? previousEntryFor(
    int week,
    String workout,
    Exercise current,
    List<Exercise> previousExercises,
    int workSet,
  ) {
    final previous = previousExerciseFor(
      week,
      workout,
      current,
      previousExercises,
    );
    if (previous == null) return null;
    final workSets = previous.indexedWorkSets;
    if (workSet < 0 || workSet >= workSets.length) return null;
    final saved = entry(week - 1, workout, previous.id, workSets[workSet].key);
    return saved.weight.isEmpty && saved.reps.isEmpty ? null : saved;
  }

  int? get currentWeek {
    for (var week = 1; week <= 12; week++) {
      if (completedCount(week) < workouts.length) return week;
    }
    return null;
  }

  bool hasEntries(int week, String workout) => _sets.entries.any(
    (e) =>
        e.key.startsWith('${_workoutKey(week, workout)}/') &&
        (e.value.weight.isNotEmpty || e.value.reps.isNotEmpty),
  );
  int loggedWorkSets(int week, String workout, List<Exercise> exercises) {
    var count = 0;
    for (final exercise in exercises) {
      for (var index = 0; index < exercise.sets.length; index++) {
        final saved = entry(week, workout, exercise.id, index);
        if (!exercise.sets[index].warmup && saved.logged) {
          count++;
        }
      }
    }
    return count;
  }

  bool canFinish(int week, String workout, List<Exercise> exercises) =>
      exercises.isNotEmpty &&
      loggedWorkSets(week, workout, exercises) ==
          exercises.fold<int>(0, (sum, e) => sum + e.workSets);

  void updateSet(
    int week,
    String workout,
    int exercise,
    int set,
    SetEntry value,
  ) {
    _sets[_setKey(week, workout, exercise, set)] = value;
    _completed.remove(_workoutKey(week, workout));
  }

  void finish(int week, String workout) {
    _completed.add(_workoutKey(week, workout));
  }

  void reopen(int week, String workout) {
    _completed.remove(_workoutKey(week, workout));
  }

  /// Clears only this week in the selected plan, including unfinished entries.
  void resetWeek(int week) {
    RangeError.checkValueInInterval(week, 1, 12, 'week');
    final prefix = '$_workoutsPerWeek/$week/';
    _sets.removeWhere((key, _) => key.startsWith(prefix));
    _movements.removeWhere((key, _) => key.startsWith(prefix));
    _completed.removeWhere((key) => key.startsWith(prefix));
  }

  void selectPlan(int days) {
    WorkoutProgram.workoutsFor(days); // Validate before changing saved state.
    if (_workoutsPerWeek == days) return;
    _workoutsPerWeek = days;
  }

  Map<String, dynamic> toJson() => {
    'version': 2,
    'workoutsPerWeek': _workoutsPerWeek,
    'sets': _sets.map((key, value) => MapEntry(key, value.toJson())),
    'movements': Map<String, String>.of(_movements),
    'completed': _completed.toList()..sort(),
  };

  factory WorkoutProgress.fromJson(Map<String, dynamic> json) {
    final store = WorkoutProgress();
    final version = json['version'];
    if (version != 1 && version != 2) {
      throw const FormatException('Unsupported progress version');
    }
    final days = version == 1 ? 4 : json['workoutsPerWeek'];
    if (days != 4 && days != 5) {
      throw const FormatException('Unsupported workout frequency');
    }
    final sets = (json['sets'] as Map<String, dynamic>).map(
      (key, value) => MapEntry(
        version == 1 ? '4/$key' : key,
        SetEntry.fromJson(value as Map<String, dynamic>),
      ),
    );
    final completed = (json['completed'] as List)
        .cast<String>()
        .map((key) => version == 1 ? '4/$key' : key)
        .toSet();
    final movements = (json['movements'] as Map<String, dynamic>? ?? {}).map(
      (key, value) => MapEntry(key, value as String),
    );
    store._workoutsPerWeek = days as int;
    store._movements.addAll(movements);
    store._sets.addAll(sets);
    store._completed.addAll(completed);
    return store;
  }
}

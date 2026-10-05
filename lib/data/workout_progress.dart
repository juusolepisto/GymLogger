import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gym_logger/data/workout_program.dart';
import 'package:gym_logger/models/exercise.dart';

class SetEntry {
  final String weight;
  final String reps;
  const SetEntry({this.weight = '', this.reps = ''});
  bool get logged => valid;
  bool get valid {
    final load = double.tryParse(weight.replaceAll(',', '.'));
    return load != null &&
        load.isFinite &&
        load >= 0 &&
        (int.tryParse(reps) ?? 0) > 0;
  }

  Map<String, dynamic> toJson() => {
    'weight': weight,
    'reps': reps,
    'logged': logged,
  };
  factory SetEntry.fromJson(Map<String, dynamic> json) =>
      SetEntry(weight: json['weight'] as String, reps: json['reps'] as String);
}

/// Local-only progress. Writes are serialized and a previous snapshot is retained
/// so an interrupted file replacement can be recovered at the next launch.
class WorkoutProgress extends ChangeNotifier {
  final Directory directory;
  final Map<String, SetEntry> _sets = {};
  final Map<String, String> _movements = {};
  final Set<String> _completed = {};
  Future<void> _writes = Future.value();
  int _pending = 0;
  bool _disposed = false;
  int _workoutsPerWeek = 4;
  int get workoutsPerWeek => _workoutsPerWeek;
  List<String> get workouts => WorkoutProgram.workoutsFor(_workoutsPerWeek);
  String? saveError;
  bool get saving => _pending > 0;
  WorkoutProgress._(this.directory);

  static Future<WorkoutProgress> loadDefault() async =>
      open(await getApplicationSupportDirectory());
  static Future<WorkoutProgress> open(Directory directory) async {
    await directory.create(recursive: true);
    final store = WorkoutProgress._(directory);
    final primary = store._file('progress.json');
    final backup = store._file('progress.backup.json');
    var foundFile = false;
    for (final file in [primary, backup]) {
      if (!await file.exists()) continue;
      foundFile = true;
      try {
        final json =
            jsonDecode(await file.readAsString()) as Map<String, dynamic>;
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
        final movements = (json['movements'] as Map<String, dynamic>? ?? {})
            .map((key, value) => MapEntry(key, value as String));
        store._workoutsPerWeek = days as int;
        store._movements.addAll(movements);
        store._sets.addAll(sets);
        store._completed.addAll(completed);
        // Do not rotate a corrupt primary over the recovered backup.
        if (file.path == backup.path && await primary.exists()) {
          await primary.rename(
            store
                ._file(
                  'progress.corrupt.${DateTime.now().microsecondsSinceEpoch}.json',
                )
                .path,
          );
        }
        return store;
      } on FormatException {
        continue;
      } on TypeError {
        continue;
      }
    }
    if (foundFile) {
      throw const FormatException(
        'Saved progress could not be read. Existing files were kept.',
      );
    }
    return store;
  }

  File _file(String name) =>
      File('${directory.path}${Platform.pathSeparator}$name');
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

  Future<void> selectMovement(
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
    return _save();
  }

  int completedCount(int week) =>
      workouts.where((w) => isCompleted(week, w)).length;
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
    _save();
  }

  Future<bool> finish(int week, String workout) async {
    _completed.add(_workoutKey(week, workout));
    await _save();
    return saveError == null;
  }

  Future<void> reopen(int week, String workout) {
    _completed.remove(_workoutKey(week, workout));
    return _save();
  }

  Future<void> retrySave() => _save();

  /// Clears only this week in the selected plan, including unfinished entries.
  Future<void> resetWeek(int week) {
    RangeError.checkValueInInterval(week, 1, 12, 'week');
    final prefix = '$_workoutsPerWeek/$week/';
    _sets.removeWhere((key, _) => key.startsWith(prefix));
    _movements.removeWhere((key, _) => key.startsWith(prefix));
    _completed.removeWhere((key) => key.startsWith(prefix));
    return _save();
  }

  Future<void> selectPlan(int days) {
    WorkoutProgram.workoutsFor(days); // Validate before changing saved state.
    if (_workoutsPerWeek == days) return Future.value();
    _workoutsPerWeek = days;
    return _save();
  }

  Future<void> flush() => _writes;

  Future<void> _save() {
    final snapshot = jsonEncode({
      'version': 2,
      'workoutsPerWeek': _workoutsPerWeek,
      'sets': _sets.map((key, value) => MapEntry(key, value.toJson())),
      'movements': _movements,
      'completed': _completed.toList()..sort(),
    });
    _pending++;
    _notify();
    _writes = _writes.then((_) async {
      try {
        final temporary = _file('progress.tmp.json');
        final primary = _file('progress.json');
        final backup = _file('progress.backup.json');
        await temporary.writeAsString(snapshot, flush: true);
        if (await primary.exists()) {
          if (await backup.exists()) await backup.delete();
          await primary.rename(backup.path);
        }
        await temporary.rename(primary.path);
        saveError = null;
      } catch (_) {
        saveError =
            'Could not save to this device. Retry to keep your latest changes.';
      } finally {
        _pending--;
        _notify();
      }
    });
    return _writes;
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

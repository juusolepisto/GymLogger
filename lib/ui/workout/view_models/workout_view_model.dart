import 'package:flutter/foundation.dart';

import '../../../models/exercise.dart';
import '../../../models/set_entry.dart';
import '../../../models/workout_progress.dart';
import '../../../repositories/progress_repository.dart';

/// Shared by the overview and workout views for a single editing session.
/// Owns UI notifications and save status; the model owns workout rules.
class WorkoutViewModel extends ChangeNotifier {
  final ProgressRepository _repository;
  final WorkoutProgress _progress;
  Future<void> _writes = Future.value();
  int _pending = 0;
  bool _disposed = false;
  String? _saveError;

  WorkoutViewModel({required this._repository, required this._progress});

  static Future<WorkoutViewModel> load(ProgressRepository repository) async =>
      WorkoutViewModel(
        repository: repository,
        progress: await repository.load(),
      );

  bool get saving => _pending > 0;
  String? get saveError => _saveError;
  int get workoutsPerWeek => _progress.workoutsPerWeek;
  List<String> get workouts => _progress.workouts;
  int? get currentWeek => _progress.currentWeek;
  int completedCount(int week) => _progress.completedCount(week);
  bool canShowPreviousWeek(int week) => _progress.canShowPreviousWeek(week);
  SetEntry? previousEntryFor(
    int week,
    String workout,
    Exercise current,
    List<Exercise> previousExercises,
    int workSet,
  ) => _progress.previousEntryFor(
    week,
    workout,
    current,
    previousExercises,
    workSet,
  );
  String? previousMovementFor(
    int week,
    String workout,
    Exercise current,
    List<Exercise> previousExercises,
  ) {
    final previous = _progress.previousExerciseFor(
      week,
      workout,
      current,
      previousExercises,
    );
    return previous == null
        ? null
        : _progress.movementFor(week - 1, workout, previous);
  }

  bool isCompleted(int week, String workout) =>
      _progress.isCompleted(week, workout);
  bool hasEntries(int week, String workout) =>
      _progress.hasEntries(week, workout);
  SetEntry entry(int week, String workout, int exercise, int set) =>
      _progress.entry(week, workout, exercise, set);
  String movementFor(int week, String workout, Exercise exercise) =>
      _progress.movementFor(week, workout, exercise);
  int loggedWorkSets(int week, String workout, List<Exercise> exercises) =>
      _progress.loggedWorkSets(week, workout, exercises);
  bool canFinish(int week, String workout, List<Exercise> exercises) =>
      _progress.canFinish(week, workout, exercises);

  void updateSet(
    int week,
    String workout,
    int exercise,
    int set,
    SetEntry value,
  ) {
    _progress.updateSet(week, workout, exercise, set, value);
    _save();
  }

  Future<void> selectMovement(
    int week,
    String workout,
    Exercise exercise,
    String name,
  ) {
    _progress.selectMovement(week, workout, exercise, name);
    return _save();
  }

  Future<bool> finish(int week, String workout) async {
    _progress.finish(week, workout);
    await _save();
    return _saveError == null;
  }

  Future<void> reopen(int week, String workout) {
    _progress.reopen(week, workout);
    return _save();
  }

  Future<void> resetWeek(int week) {
    _progress.resetWeek(week);
    return _save();
  }

  Future<void> selectPlan(int days) {
    if (days == workoutsPerWeek) return Future.value();
    _progress.selectPlan(days);
    return _save();
  }

  Future<void> retrySave() => _save();
  Future<void> flush() => _writes;

  Future<void> _save() {
    // Capture each edit before later mutations; writes preserve their order.
    final snapshot = WorkoutProgress.fromJson(_progress.toJson());
    _pending++;
    _notify();
    _writes = _writes.then((_) async {
      try {
        await _repository.save(snapshot);
        _saveError = null;
      } catch (_) {
        _saveError =
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

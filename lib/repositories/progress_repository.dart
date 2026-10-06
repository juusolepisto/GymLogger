import '../models/workout_progress.dart';

abstract interface class ProgressRepository {
  Future<WorkoutProgress> load();
  Future<void> save(WorkoutProgress progress);
}

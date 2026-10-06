import '../models/workout_program.dart';

abstract interface class ProgramRepository {
  Future<Map<int, WorkoutProgram>> loadPlans();
}

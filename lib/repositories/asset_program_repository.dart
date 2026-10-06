import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/workout_program.dart';
import 'program_repository.dart';

class AssetProgramRepository implements ProgramRepository {
  final AssetBundle _bundle;
  Map<int, WorkoutProgram>? _plans;
  AssetProgramRepository({AssetBundle? bundle})
    : _bundle = bundle ?? rootBundle;

  @override
  Future<Map<int, WorkoutProgram>> loadPlans() async {
    // Cache successes only so a failed load can be retried.
    return _plans ??= Map.unmodifiable({
      4: await _load('assets/data/workout_program.json'),
      5: await _load('assets/data/workout_program_5x.json'),
    });
  }

  Future<WorkoutProgram> _load(String path) async => WorkoutProgram.fromJson(
    jsonDecode(await _bundle.loadString(path)) as List<dynamic>,
  );
}

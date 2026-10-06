import 'package:flutter/foundation.dart';

import '../../../models/workout_program.dart';
import '../../../repositories/program_repository.dart';
import '../../../repositories/progress_repository.dart';
import '../../workout/view_models/workout_view_model.dart';

class HomeViewModel extends ChangeNotifier {
  final ProgramRepository _programRepository;
  final Future<ProgressRepository> Function() _createProgressRepository;
  final Future<String> Function() _loadVersion;
  bool _disposed = false;
  bool _loading = false;
  String? _error;
  String _appVersion = '';
  Map<int, WorkoutProgram>? _plans;
  WorkoutViewModel? _progress;

  HomeViewModel({
    required this._programRepository,
    required this._createProgressRepository,
    required this._loadVersion,
  });

  bool get loading => _loading;
  String? get error => _error;
  String get appVersion => _appVersion;
  Map<int, WorkoutProgram>? get plans => _plans;
  WorkoutViewModel? get progress => _progress;

  Future<void> load() async {
    if (_loading || _disposed || _progress != null) return;
    _loading = true;
    _error = null;
    notifyListeners();
    await Future.wait([_loadWorkouts(), _loadAppVersion()]);
    _loading = false;
    if (!_disposed) notifyListeners();
  }

  Future<void> _loadWorkouts() async {
    try {
      final plans = await _programRepository.loadPlans();
      final progress = await WorkoutViewModel.load(
        await _createProgressRepository(),
      );
      if (_disposed) {
        progress.dispose();
        return;
      }
      _plans = plans;
      _progress = progress;
    } catch (_) {
      _error = 'Could not load your local progress. Your saved files have been kept.';
    }
  }

  Future<void> _loadAppVersion() async {
    try {
      _appVersion = await _loadVersion();
    } catch (_) {
      // Version metadata is optional and must not prevent workout loading.
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _progress?.dispose();
    super.dispose();
  }
}

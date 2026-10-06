import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:gym_logger/models/set_entry.dart';
import 'package:gym_logger/models/workout_program.dart';
import 'package:gym_logger/models/workout_progress.dart';
import 'package:gym_logger/repositories/program_repository.dart';
import 'package:gym_logger/repositories/progress_repository.dart';
import 'package:gym_logger/ui/home/view_models/home_view_model.dart';
import 'package:gym_logger/ui/workout/view_models/workout_view_model.dart';

class FakePrograms implements ProgramRepository {
  bool fail = false;
  Completer<Map<int, WorkoutProgram>>? pending;
  @override
  Future<Map<int, WorkoutProgram>> loadPlans() async {
    if (fail) throw StateError('Asset unavailable');
    return pending?.future ?? {4: WorkoutProgram.fromJson([])};
  }
}

class FakeProgress implements ProgressRepository {
  final snapshots = <WorkoutProgress>[];
  Completer<void>? firstWrite;
  bool fail = false;
  @override
  Future<WorkoutProgress> load() async => WorkoutProgress();
  @override
  Future<void> save(WorkoutProgress progress) async {
    if (fail) throw StateError('Disk unavailable');
    snapshots.add(progress);
    if (snapshots.length == 1) await firstWrite?.future;
  }
}

void main() {
  test(
    'Home retries loading and tolerates unavailable version metadata',
    () async {
      final programs = FakePrograms()..fail = true;
      final home = HomeViewModel(
        programRepository: programs,
        createProgressRepository: () async => FakeProgress(),
        loadVersion: () async => throw StateError('No platform metadata'),
      );
      addTearDown(home.dispose);
      await home.load();
      expect(home.error, isNotNull);
      expect(home.loading, isFalse);
      expect(home.progress, isNull);
      programs.fail = false;
      await home.load();
      expect(home.error, isNull);
      expect(home.progress, isNotNull);
      expect(home.plans!.keys, [4]);
      expect(home.appVersion, isEmpty);
    },
  );

  test(
    'Disposing during loading does not notify or retain a workout session',
    () async {
      final programs = FakePrograms()..pending = Completer();
      final home = HomeViewModel(
        programRepository: programs,
        createProgressRepository: () async => FakeProgress(),
        loadVersion: () async => '1.0.3',
      );
      var notifications = 0;
      home.addListener(() => notifications++);
      final loading = home.load();
      expect(notifications, 1);
      home.dispose();
      programs.pending!.complete({});
      await loading;
      expect(notifications, 1);
      expect(home.progress, isNull);
    },
  );

  test('Queued snapshots retain each edit and finish after disposal', () async {
    final repository = FakeProgress()..firstWrite = Completer<void>();
    final vm = await WorkoutViewModel.load(repository);
    vm.updateSet(1, 'Upper', 1, 0, const SetEntry(weight: '20'));
    await Future<void>.delayed(Duration.zero);
    vm.updateSet(1, 'Upper', 1, 0, const SetEntry(weight: '25'));
    expect(repository.snapshots.length, 1);
    expect(vm.saving, isTrue);
    expect(repository.snapshots.first.entry(1, 'Upper', 1, 0).weight, '20');
    vm.dispose();
    repository.firstWrite!.complete();
    await vm.flush();
    expect(repository.snapshots.map((s) => s.entry(1, 'Upper', 1, 0).weight), [
      '20',
      '25',
    ]);
    expect(vm.saving, isFalse);
  });

  test('Save failure retains edits and retry clears the error', () async {
    final repository = FakeProgress()..fail = true;
    final vm = await WorkoutViewModel.load(repository);
    addTearDown(vm.dispose);
    vm.updateSet(1, 'Upper', 1, 0, const SetEntry(weight: '30', reps: '8'));
    await vm.flush();
    expect(vm.saveError, isNotNull);
    expect(vm.entry(1, 'Upper', 1, 0).logged, isTrue);
    repository.fail = false;
    await vm.retrySave();
    expect(vm.saveError, isNull);
    expect(repository.snapshots.single.entry(1, 'Upper', 1, 0).weight, '30');
  });
}

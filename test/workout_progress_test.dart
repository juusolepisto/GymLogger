import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_logger/data/workout_program.dart';
import 'package:gym_logger/data/workout_progress.dart';
import 'package:gym_logger/models/exercise.dart';
import 'package:gym_logger/screens/workout/workout_screen.dart';
import 'package:gym_logger/widgets/week_accordion.dart';
import 'package:gym_logger/widgets/program_overview.dart';
import 'package:gym_logger/widgets/workout_card.dart';

final program = WorkoutProgram.fromJson(
  jsonDecode(File('assets/data/workout_program.json').readAsStringSync())
      as List,
);
final fiveDayProgram = WorkoutProgram.fromJson(
  jsonDecode(File('assets/data/workout_program_5x.json').readAsStringSync())
      as List,
);
const tinyWorkout = [
  Exercise(
    id: 1000,
    name: 'Test press',
    url: 'https://example.com',
    warmupRange: '1',
    rest: '1 min',
    notes: '',
    intensity: '-',
    alternatives: [],
    sets: [
      ExerciseSet(reps: '', rir: '', warmup: true),
      ExerciseSet(reps: '6-8', rir: '1'),
    ],
  ),
];

void logWorkSets(
  WorkoutProgress progress,
  int week,
  String workout,
  List<Exercise> exercises,
) {
  for (final exercise in exercises) {
    for (var index = 0; index < exercise.sets.length; index++) {
      if (!exercise.sets[index].warmup) {
        progress.updateSet(
          week,
          workout,
          exercise.id,
          index,
          const SetEntry(weight: '25.5', reps: '8'),
        );
      }
    }
  }
}

void main() {
  late Directory directory;
  late WorkoutProgress progress;
  Future<void> drainWrites(WidgetTester tester, WorkoutProgress store) async {
    for (var attempt = 0; attempt < 200 && store.saving; attempt++) {
      await tester.pump();
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 10)),
      );
    }
    await tester.pump();
    expect(store.saving, isFalse);
  }

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('gym_progress_test_');
    progress = await WorkoutProgress.open(directory);
  });
  tearDown(() async {
    if (progress.saving) await progress.flush();
    progress.dispose();
    await directory.delete(recursive: true);
  });

  test('Logging follows valid values, including older saved drafts', () {
    for (final entry in [
      const SetEntry(weight: '', reps: '8'),
      const SetEntry(weight: '20', reps: ''),
      const SetEntry(weight: '-1', reps: '8'),
      const SetEntry(weight: 'NaN', reps: '8'),
      const SetEntry(weight: '20', reps: '0'),
      const SetEntry(weight: '20', reps: '1.5'),
    ]) {
      expect(entry.logged, isFalse);
    }
    expect(const SetEntry(weight: '0', reps: '8').logged, isTrue);
    expect(const SetEntry(weight: '12,5', reps: '8').logged, isTrue);
    expect(
      SetEntry.fromJson({'weight': '20', 'reps': '8', 'logged': false}).logged,
      isTrue,
    );
  });

  test(
    'Five-day workbook has all twelve weeks and original exercise links',
    () {
      for (var week = 1; week <= 12; week++) {
        expect(fiveDayProgram.workoutsForWeek(week), [
          'Upper',
          'Lower',
          'Push',
          'Pull',
          'Arms',
        ]);
        for (final workout in fiveDayProgram.workoutsForWeek(week)) {
          for (final exercise in fiveDayProgram.exercisesFor(week, workout)) {
            expect(exercise.workSets, greaterThan(0));
            for (final url in [
              exercise.url,
              ...exercise.alternatives.map((a) => a.url),
            ]) {
              expect(Uri.parse(url).scheme, 'https');
            }
            expect(
              exercise.sets
                  .where((s) => !s.warmup)
                  .every((s) => s.reps.isNotEmpty && s.rir.isNotEmpty),
              isTrue,
            );
          }
        }
      }
      expect(fiveDayProgram.exercisesFor(1, 'Upper').length, 5);
      expect(program.exercisesFor(1, 'Upper').length, 7);
      final arms = fiveDayProgram.exercisesFor(1, 'Arms');
      expect(arms.first.name, 'S1: EZ-Bar Cheat Curl');
      expect(arms.first.sets.where((s) => !s.warmup).map((s) => s.reps), [
        '4-6',
        '4-6',
      ]);
      expect(arms.first.sets.where((s) => !s.warmup).map((s) => s.rir), [
        '0',
        '1',
      ]);
      expect(arms.first.url, 'https://youtu.be/E2fIvANy9BQ');
      expect(
        arms
            .firstWhere((e) => e.name == 'S3: DB Wrist Curl')
            .alternatives
            .length,
        1,
      );
    },
  );

  test(
    'Existing version-one progress migrates without losing four-day history',
    () async {
      await File('${directory.path}/progress.json').writeAsString(
        jsonEncode({
          'version': 1,
          'sets': {
            '1/Upper/14/3': {'weight': '35', 'reps': '6', 'logged': true},
          },
          'completed': ['1/Upper', '1/Lower', '1/Push', '1/Pull'],
        }),
      );
      final migrated = await WorkoutProgress.open(directory);
      expect(migrated.workoutsPerWeek, 4);
      expect(migrated.currentWeek, 2);
      expect(migrated.entry(1, 'Upper', 14, 3).weight, '35');
      await migrated.selectPlan(5);
      expect(migrated.currentWeek, 1);
      expect(migrated.entry(1, 'Upper', 14, 3).weight, isEmpty);
      migrated.updateSet(
        1,
        'Upper',
        14,
        3,
        const SetEntry(weight: '50', reps: '5'),
      );
      await migrated.flush();
      final restored = await WorkoutProgress.open(directory);
      expect(restored.workoutsPerWeek, 5);
      expect(restored.entry(1, 'Upper', 14, 3).weight, '50');
      await restored.selectPlan(4);
      expect(restored.currentWeek, 2);
      expect(restored.entry(1, 'Upper', 14, 3).weight, '35');
      expect(restored.entry(1, 'Upper', 14, 3).logged, isTrue);
      restored.dispose();
      migrated.dispose();
    },
  );

  test('Five-day weeks require Arms before advancing and keep independent completion', () async {
    await progress.selectPlan(5);
    for (final workout in WorkoutProgram.workouts) {
      final exercises = fiveDayProgram.exercisesFor(1, workout);
      logWorkSets(progress, 1, workout, exercises);
      await progress.finish(1, workout);
    }
    expect(progress.completedCount(1), 4);
    expect(progress.currentWeek, 1);
    final arms = fiveDayProgram.exercisesFor(1, 'Arms');
    logWorkSets(progress, 1, 'Arms', arms);
    await progress.finish(1, 'Arms');
    expect(progress.currentWeek, 2);
    await progress.selectPlan(4);
    expect(progress.currentWeek, 1);
    expect(progress.completedCount(1), 0);
    await progress.selectPlan(5);
    expect(progress.completedCount(1), 5);
    expect(progress.currentWeek, 2);
  });

  testWidgets(
    'Plan selector shows four or five actual workouts and opens Arms',
    (tester) async {
      tester.view.physicalSize = const Size(320, 1800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(
            body: ProgramOverview(
              plans: {4: program, 5: fiveDayProgram},
              progress: progress,
            ),
          ),
        ),
      );
      expect(find.byType(WorkoutCard), findsNWidgets(4));
      expect(find.text('Arms'), findsNothing);
      await tester.tap(find.text('5 workouts'));
      await drainWrites(tester, progress);
      expect(find.byType(WorkoutCard), findsNWidgets(5));
      expect(find.text('0 of 5 workouts complete'), findsNWidgets(12));
      await tester.tap(find.text('Arms'));
      await tester.pumpAndSettle();
      expect(find.text('S1: EZ-Bar Cheat Curl'), findsOneWidget);
      expect(find.text('S3: DB Wrist Curl'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.tap(find.text('4 workouts'));
      await drainWrites(tester, progress);
      expect(find.byType(WorkoutCard), findsNWidgets(4));
      expect(find.text('0 of 4 workouts complete'), findsNWidgets(12));
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );

  test('Drafts, partially logged sets and completed workouts survive a fresh store', () async {
    progress.updateSet(
      1,
      'Upper',
      14,
      0,
      const SetEntry(weight: '12,5', reps: ''),
    );
    final exercises = program.exercisesFor(1, 'Upper');
    expect(await progress.finish(1, 'Upper'), isTrue);
    final restored = await WorkoutProgress.open(directory);
    expect(restored.entry(1, 'Upper', 14, 0).weight, '12,5');
    expect(restored.entry(1, 'Upper', 14, 0).reps, '');
    expect(restored.canFinish(1, 'Upper', exercises), isFalse);
    expect(restored.isCompleted(1, 'Upper'), isTrue);
    expect(restored.isCompleted(2, 'Upper'), isFalse);
    expect(restored.completedCount(1), 1);
    restored.dispose();
  });

  test(
    'Four completed workouts advance the week; reopening rolls back',
    () async {
      for (final workout in WorkoutProgram.workouts) {
        final exercises = program.exercisesFor(1, workout);
        logWorkSets(progress, 1, workout, exercises);
        await progress.finish(1, workout);
      }
      expect(progress.completedCount(1), 4);
      expect(progress.currentWeek, 2);
      await progress.reopen(1, 'Upper');
      expect(progress.currentWeek, 1);
      expect(
        progress.canFinish(1, 'Upper', program.exercisesFor(1, 'Upper')),
        isTrue,
      );
      final restored = await WorkoutProgress.open(directory);
      expect(restored.currentWeek, 1);
      expect(restored.completedCount(1), 3);
      restored.dispose();
    },
  );

  test(
    'Out-of-order completion never skips unfinished weeks, and ends at week 12',
    () async {
      for (var week = 12; week >= 1; week--) {
        for (final workout in WorkoutProgram.workouts) {
          logWorkSets(progress, week, workout, tinyWorkout);
          await progress.finish(week, workout);
        }
        expect(progress.currentWeek, week == 1 ? isNull : 1);
      }
      expect(progress.completedCount(12), 4);
      final restored = await WorkoutProgress.open(directory);
      expect(restored.currentWeek, isNull);
      restored.dispose();
    },
  );

  test('Interrupted/corrupt primary recovers the previous save', () async {
    progress.updateSet(1, 'Upper', 14, 0, const SetEntry(weight: '20'));
    await progress.flush();
    progress.updateSet(1, 'Upper', 14, 0, const SetEntry(weight: '25'));
    await progress.flush();
    await File('${directory.path}/progress.json').writeAsString('{broken');
    final restored = await WorkoutProgress.open(directory);
    expect(restored.entry(1, 'Upper', 14, 0).weight, '20');
    await restored.retrySave();
    expect(restored.saveError, isNull);
    restored.dispose();
  });

  test(
    'Unreadable data is not silently replaced with empty progress',
    () async {
      final file = File('${directory.path}/progress.json');
      await file.writeAsString('{broken');
      await expectLater(WorkoutProgress.open(directory), throwsFormatException);
      expect(await file.readAsString(), '{broken');
    },
  );

  test(
    'Failed saves are visible and can be retried without losing latest edits',
    () async {
      final obstruction = Directory('${directory.path}/progress.tmp.json');
      await obstruction.create();
      progress.updateSet(
        1,
        'Upper',
        14,
        0,
        const SetEntry(weight: '30', reps: '10'),
      );
      await progress.flush();
      expect(progress.saveError, isNotNull);
      await obstruction.delete();
      await progress.retrySave();
      expect(progress.saveError, isNull);
      final restored = await WorkoutProgress.open(directory);
      expect(restored.entry(1, 'Upper', 14, 0).weight, '30');
      restored.dispose();
    },
  );

  testWidgets('Narrow week list updates completion and opens the next week', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.dark(),
        home: Scaffold(
          body: SingleChildScrollView(
            child: WeekAccordion(program: program, progress: progress),
          ),
        ),
      ),
    );
    expect(find.text('0 of 4 workouts complete'), findsNWidgets(12));
    expect(find.text('WORKOUT 01 · READY'), findsOneWidget);
    await tester.runAsync(() async {
      for (final workout in WorkoutProgram.workouts) {
        final exercises = program.exercisesFor(1, workout);
        logWorkSets(progress, 1, workout, exercises);
        await progress.finish(1, workout);
      }
    });
    await tester.pump();
    expect(find.text('4 of 4 workouts complete'), findsOneWidget);
    expect(find.text('COMPLETED'), findsOneWidget);
    expect(find.text('IN PROGRESS'), findsOneWidget);
    expect(find.text('WORKOUT 01 · READY'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
    'Workout entries restore after leaving and can finish without warm-ups',
    (tester) async {
      tester.view.physicalSize = const Size(320, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      Widget screen(WorkoutProgress store) => MaterialApp(
        theme: ThemeData.dark(),
        home: WorkoutScreen(
          week: 1,
          exercise: 'Upper',
          exercises: tinyWorkout,
          progress: store,
        ),
      );
      await tester.pumpWidget(screen(progress));
      expect(find.byType(TextField), findsNWidgets(2));
      expect(find.text('Warm-up: 1 set'), findsOneWidget);
      expect(
        tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
        isNotNull,
      );
      await tester.enterText(find.byType(TextField).at(0), '40');
      await drainWrites(tester, progress);
      expect(progress.canFinish(1, 'Upper', tinyWorkout), isFalse);
      await tester.enterText(find.byType(TextField).at(1), '8');

      await drainWrites(tester, progress);
      await tester.pump();
      expect(
        tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
        isNotNull,
      );
      // Keep the original prescription index: index 0 was the warm-up.
      expect(progress.entry(1, 'Upper', 1000, 1).logged, isTrue);
      expect(progress.entry(1, 'Upper', 1000, 0).weight, isEmpty);
      await tester.enterText(find.byType(TextField).at(1), '');
      await drainWrites(tester, progress);
      expect(
        tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
        isNotNull,
      );
      await tester.enterText(find.byType(TextField).at(1), '8');
      await drainWrites(tester, progress);
      await tester.pumpWidget(const SizedBox());
      final restored = (await tester.runAsync(
        () => WorkoutProgress.open(directory),
      ))!;
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => WorkoutScreen(
                      week: 1,
                      exercise: 'Upper',
                      exercises: tinyWorkout,
                      progress: restored,
                    ),
                  ),
                ),
                child: const Text('Open workout'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open workout'));
      await tester.pumpAndSettle();
      expect(find.text('40'), findsOneWidget);
      expect(find.text('LOG'), findsNothing);
      expect(restored.entry(1, 'Upper', 1000, 1).logged, isTrue);
      await tester.tap(find.text('Finish workout'));
      await drainWrites(tester, restored);
      await tester.pumpAndSettle();
      expect(find.text('Open workout'), findsOneWidget);
      expect(restored.isCompleted(1, 'Upper'), isTrue);
      await tester.tap(find.text('Open workout'));
      await tester.pumpAndSettle();
      expect(find.text('Workout completed'), findsOneWidget);
      expect(find.text('Reopen workout'), findsOneWidget);
      await tester.tap(find.text('Reopen workout'));
      await drainWrites(tester, restored);
      await tester.pump();
      expect(find.text('Finish workout'), findsOneWidget);
      expect(find.text('40'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      restored.dispose();
    },
  );
}

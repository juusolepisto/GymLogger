import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_logger/models/exercise.dart';
import 'package:gym_logger/ui/core/widgets/exercise_accordion.dart';

final program = (jsonDecode(
  File('assets/data/workout_program.json').readAsStringSync(),
) as List).cast<Map<String, dynamic>>();
List<Exercise> exercisesFor(int week, String name) =>
    (program.firstWhere(
              (w) => w['week'] == week && w['name'] == name,
            )['exercises']
            as List)
        .map((e) => Exercise.fromJson(e as Map<String, dynamic>))
        .toList();

void main() {
  test('All twelve weeks have four workouts and valid exercise links', () {
    expect(program.length, 48);
    for (var week = 1; week <= 12; week++) {
      for (final workout in ['Upper', 'Lower', 'Push', 'Pull']) {
        final exercises = exercisesFor(week, workout);
        expect(exercises, isNotEmpty);
        for (final exercise in exercises) {
          expect(exercise.workSets, greaterThan(0));
          expect(exercise.alternatives.length, 2);
          for (final url in [
            exercise.url,
            ...exercise.alternatives.map((a) => a.url),
          ]) {
            expect(Uri.parse(url).scheme, 'https');
          }
        }
      }
    }
    final chest = exercisesFor(1, 'Upper').first;
    expect(chest.warmupSets, 3);
    expect(chest.workSets, 3);
    expect(chest.sets.where((s) => !s.warmup).map((s) => s.reps), [
      '4-6',
      '4-6',
      '20',
    ]);
    expect(chest.sets.where((s) => !s.warmup).map((s) => s.rir), [
      '1',
      '2',
      '1',
    ]);
    expect(exercisesFor(2, 'Upper').first.sets.last.rir, '0');
  });

  Future<void> pumpAccordion(WidgetTester tester) async {
    tester.view.physicalSize = const Size(320, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.dark(),
        home: Scaffold(
          body: SingleChildScrollView(
            child: ExerciseAccordion(exercises: exercisesFor(1, 'Upper')),
          ),
        ),
      ),
    );
  }

  testWidgets('Fixed rows retain values and log state after collapsing', (
    tester,
  ) async {
    await pumpAccordion(tester);
    expect(find.byType(TextField), findsNWidgets(6));
    expect(find.text('Add Set'), findsNothing);
    expect(find.byIcon(Icons.remove), findsNothing);
    await tester.enterText(find.byType(TextField).at(0), '25.5');
    await tester.enterText(find.byType(TextField).at(1), '12');

    await tester.pump();
    expect(find.text('LOG'), findsNothing);
    expect(find.text('W1'), findsNothing);
    expect(find.text('Warm-up: 2-3 sets'), findsOneWidget);
    await tester.tap(find.text('Machine Chest Press'));
    await tester.pump();
    expect(find.byType(TextField), findsNothing);
    await tester.tap(find.text('Machine Lat Pullover'));
    await tester.pump();
    await tester.tap(find.text('Machine Chest Press'));
    await tester.pump();
    expect(find.text('25.5'), findsOneWidget);
    expect(find.text('LOG'), findsNothing);
    expect(find.text('W1'), findsNothing);
    expect(find.text('Warm-up: 2-3 sets'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Exercise and both alternatives expose original workbook URLs', (
    tester,
  ) async {
    await pumpAccordion(tester);
    await tester.tap(find.text('Videos & alternatives'));
    await tester.pumpAndSettle();
    expect(find.text('Exercise & alternatives'), findsOneWidget);
    expect(find.text('Smith Machine Bench Press'), findsOneWidget);
    expect(find.text('DB Bench Press'), findsOneWidget);
    expect(find.text('https://youtu.be/qTSTOVVr8rU'), findsOneWidget);
    expect(find.text('https://youtu.be/cJ8JrXUQ3xQ'), findsOneWidget);
    expect(find.text('https://youtu.be/qmyToaabqdQ'), findsOneWidget);
    expect(find.text('Watch video'), findsNWidgets(3));
    expect(tester.takeException(), isNull);
  });
}

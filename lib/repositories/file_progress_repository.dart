import 'dart:convert';
import 'dart:io';

import '../models/workout_progress.dart';
import 'progress_repository.dart';

/// Retains the previous snapshot and recovers it if the primary is corrupt.
class FileProgressRepository implements ProgressRepository {
  final Directory directory;
  FileProgressRepository(this.directory);

  @override
  Future<WorkoutProgress> load() async {
    await directory.create(recursive: true);

    final primary = _file('progress.json');
    final backup = _file('progress.backup.json');
    var foundFile = false;
    for (final file in [primary, backup]) {
      if (!await file.exists()) continue;
      foundFile = true;
      try {
        final json =
            jsonDecode(await file.readAsString()) as Map<String, dynamic>;
        final store = WorkoutProgress.fromJson(json);
        // Do not rotate a corrupt primary over the recovered backup.
        if (file.path == backup.path && await primary.exists()) {
          await primary.rename(
            _file(
              'progress.corrupt.${DateTime.now().microsecondsSinceEpoch}.json',
            ).path,
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
    return WorkoutProgress();
  }

  File _file(String name) =>
      File('${directory.path}${Platform.pathSeparator}$name');

  @override
  Future<void> save(WorkoutProgress progress) async {
    final snapshot = jsonEncode(progress.toJson());
    final temporary = _file('progress.tmp.json');
    final primary = _file('progress.json');
    final backup = _file('progress.backup.json');
    await temporary.writeAsString(snapshot, flush: true);
    if (await primary.exists()) {
      if (await backup.exists()) await backup.delete();
      await primary.rename(backup.path);
    }
    await temporary.rename(primary.path);
  }
}

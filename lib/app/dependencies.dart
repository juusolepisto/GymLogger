import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

import '../repositories/asset_program_repository.dart';
import '../repositories/file_progress_repository.dart';
import '../ui/home/view_models/home_view_model.dart';

/// Composition root: concrete platform dependencies stay outside the views.
class AppDependencies {
  HomeViewModel createHomeViewModel() => HomeViewModel(
    programRepository: AssetProgramRepository(),
    createProgressRepository: () async =>
        FileProgressRepository(await getApplicationSupportDirectory()),
    loadVersion: () async => (await PackageInfo.fromPlatform()).version,
  );
}

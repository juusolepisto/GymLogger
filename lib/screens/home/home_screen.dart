import 'package:flutter/material.dart';
import 'package:gym_logger/data/workout_program.dart';
import 'package:gym_logger/data/workout_progress.dart';
import 'package:gym_logger/widgets/program_overview.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:gym_logger/theme/app_colors.dart';
import '../changelog/changelog_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.palette,
    required this.onPaletteChanged,
  });

  final AppPalette palette;
  final ValueChanged<AppPalette> onPaletteChanged;
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<(Map<int, WorkoutProgram>, WorkoutProgress)> _loaded;

  WorkoutProgress? _progress;

  String _appVersion = '';

  @override
  void initState() {
    super.initState();

    _loaded = _load();

    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();

    if (mounted) {
      setState(() {
        _appVersion = packageInfo.version;
      });
    }
  }

  Future<(Map<int, WorkoutProgram>, WorkoutProgress)> _load() async {
    final plans = await WorkoutProgram.plans;
    final progress = await WorkoutProgress.loadDefault();

    if (!mounted) {
      progress.dispose();
    } else {
      _progress = progress;
    }

    return (plans, progress);
  }

  @override
  void dispose() {
    _progress?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(
        'GymLogger',
        style: Theme.of(context).textTheme.headlineSmall,
      ),
    ),

    body: SafeArea(
      child: Column(
        children: [
          Expanded(
            child: FutureBuilder<(Map<int, WorkoutProgram>, WorkoutProgress)>(
              future: _loaded,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Could not load your local progress. '
                            'Your saved files have been kept.',
                          ),
                          TextButton(
                            onPressed: () => setState(() => _loaded = _load()),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final (plans, progress) = snapshot.data!;

                return ProgramOverview(plans: plans, progress: progress);
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(12),
            child: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ChangelogScreen(),
                  ),
                );
              },
              child:Text(
                'v$_appVersion',
                style: TextStyle(color: AppColors.primary),
              ),
            )
          ),
        ],
      ),
    ),
  );
}

import 'package:flutter/material.dart';

import '../../core/widgets/program_overview.dart';
import '../../core/theme/app_colors.dart';
import '../../changelog/views/changelog_screen.dart';
import '../view_models/home_view_model.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.viewModel});
  final HomeViewModel viewModel;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: viewModel,
    builder: (context, _) => Scaffold(
      appBar: AppBar(
        title: Text(
          'GymLogger',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: _buildContent()),
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => const ChangelogScreen(),
                  ),
                ),
                child: Text(
                  'v${viewModel.appVersion}',
                  style: const TextStyle(color: AppColors.primary),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _buildContent() {
    if (viewModel.error case final error?) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(error),
              TextButton(onPressed: viewModel.load, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }
    if (viewModel.loading || viewModel.progress == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return ProgramOverview(
      plans: viewModel.plans!,
      progress: viewModel.progress!,
    );
  }
}

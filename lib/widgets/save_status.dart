import 'package:flutter/material.dart';
import 'package:gym_logger/data/workout_progress.dart';
import 'package:gym_logger/theme/app_colors.dart';

class SaveStatus extends StatelessWidget {
  final WorkoutProgress progress;
  const SaveStatus({super.key, required this.progress});
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: progress,
    builder: (context, _) => progress.saveError != null
        ? Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                progress.saveError!,
                style: const TextStyle(color: AppColors.tertiary),
              ),
              TextButton(
                onPressed: progress.saving ? null : progress.retrySave,
                child: const Text('Retry save'),
              ),
            ],
          )
        : Text(
            progress.saving ? 'Saving to device...' : 'Saved on this device',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
  );
}

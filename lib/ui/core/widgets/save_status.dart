import 'package:flutter/material.dart';
import 'package:gym_logger/ui/workout/view_models/workout_view_model.dart';

class SaveStatus extends StatelessWidget {
  final WorkoutViewModel progress;
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
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              TextButton(
                onPressed: progress.saving ? null : progress.retrySave,
                child: const Text('Retry save'),
              ),
            ],
          )
        : Text(
            progress.saving ? 'Saving to device...' : 'Saved on this device',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
  );
}

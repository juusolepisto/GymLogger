import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gym_logger/models/exercise.dart';
import 'package:url_launcher/url_launcher.dart';

class ExerciseLinksSheet extends StatelessWidget {
  const ExerciseLinksSheet({super.key, required this.exercise});
  final Exercise exercise;

  Future<void> _openLink(BuildContext context, ExerciseLink link) async {
    try {
      if (await launchUrl(
        Uri.parse(link.url),
        mode: LaunchMode.externalApplication,
      )) {
        return;
      }
    } catch (_) {
      // Keep the source URL accessible when no external handler is available.
    }
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Could not open the video. You can copy its link.'),
      ),
    );
  }

  Future<void> _copyLink(BuildContext context, ExerciseLink link) async {
    await Clipboard.setData(ClipboardData(text: link.url));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Link copied')));
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    child: SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Exercise & alternatives',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          for (final link in [
            ExerciseLink(name: exercise.name, url: exercise.url),
            ...exercise.alternatives,
          ])
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    link.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SelectableText(
                    link.url,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Row(
                    children: [
                      TextButton.icon(
                        onPressed: () => _openLink(context, link),
                        icon: const Icon(Icons.open_in_new, size: 18),
                        label: const Text('Watch video'),
                      ),
                      IconButton(
                        tooltip: 'Copy link',
                        icon: const Icon(Icons.copy, size: 18),
                        onPressed: () => _copyLink(context, link),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    ),
  );
}

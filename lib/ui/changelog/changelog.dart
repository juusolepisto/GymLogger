import '../../models/changelog_entry.dart';

const changelog = [
  ChangelogEntry(
    version: '1.0.0',
    changes: [
      'First working version of the app.',
      'New features yet to be added.',
    ],
  ),
  ChangelogEntry(
    version: '1.0.1',
    changes: [
      'Made workout amount switch selection more clear.',
      'Workouts can be ended without having all sets completed.',
      'If the previous week’s workout has been completed, it is reflected for that specific workout.',
    ],
  ),
  ChangelogEntry(
    version: '1.0.2',
    changes: [
      'The user can now more clearly see what exercises they have logged/completed for a workout.',
    ],
  ),
  ChangelogEntry(
    version: '1.0.3',
    changes: [
      'Added changelog screen to view app updates.',
      'Added ability to reset progress for a selected week.',
      'The user can log what type of movement they performed for each exercise.',
    ],
  ),
  ChangelogEntry(
    version: '1.0.4',
    changes: [
      'Exercise variation dropdown made more clear.',
    ],
  ),
];

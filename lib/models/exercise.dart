class ExerciseLink {
  final String name;
  final String url;
  const ExerciseLink({required this.name, required this.url});
  factory ExerciseLink.fromJson(Map<String, dynamic> json) =>
      ExerciseLink(name: json['name'] as String, url: json['url'] as String);
}

class ExerciseSet {
  final String reps;
  final String rir;
  final bool warmup;
  const ExerciseSet({
    required this.reps,
    required this.rir,
    this.warmup = false,
  });
  factory ExerciseSet.fromJson(Map<String, dynamic> json) => ExerciseSet(
    reps: json['reps'] as String,
    rir: json['rir'] as String,
    warmup: json['warmup'] as bool,
  );
}

class Exercise {
  final int id;
  final String name;
  final String url;
  final String warmupRange;
  final String rest;
  final String notes;
  final String intensity;
  final List<ExerciseSet> sets;
  final List<ExerciseLink> alternatives;
  const Exercise({
    required this.id,
    required this.name,
    required this.url,
    required this.warmupRange,
    required this.rest,
    required this.notes,
    required this.intensity,
    required this.sets,
    required this.alternatives,
  });

  int get warmupSets => sets.where((set) => set.warmup).length;
  int get workSets => sets.length - warmupSets;
  String get repSummary => sets
      .where((set) => !set.warmup)
      .map((set) => set.reps)
      .toSet()
      .join(' / ');

  factory Exercise.fromJson(Map<String, dynamic> json) => Exercise(
    id: json['id'] as int,
    name: json['name'] as String,
    url: json['url'] as String,
    warmupRange: json['warmupRange'] as String,
    rest: json['rest'] as String,
    notes: json['notes'] as String,
    intensity: json['intensity'] as String,
    sets: List.unmodifiable(
      (json['sets'] as List).map(
        (s) => ExerciseSet.fromJson(s as Map<String, dynamic>),
      ),
    ),
    alternatives: List.unmodifiable(
      (json['alternatives'] as List).map(
        (a) => ExerciseLink.fromJson(a as Map<String, dynamic>),
      ),
    ),
  );
}

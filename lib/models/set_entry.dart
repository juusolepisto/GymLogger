class SetEntry {
  final String weight;
  final String reps;
  const SetEntry({this.weight = '', this.reps = ''});
  bool get logged => valid;
  bool get valid {
    final load = double.tryParse(weight.replaceAll(',', '.'));
    return load != null &&
        load.isFinite &&
        load >= 0 &&
        (int.tryParse(reps) ?? 0) > 0;
  }

  Map<String, dynamic> toJson() => {
    'weight': weight,
    'reps': reps,
    'logged': logged,
  };
  factory SetEntry.fromJson(Map<String, dynamic> json) =>
      SetEntry(weight: json['weight'] as String, reps: json['reps'] as String);
}

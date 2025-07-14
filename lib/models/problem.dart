class Problem {
  final int id;
  final String title;
  final String description;
  final List<int> inputs;
  final List<int> expectedOutputs;
  final int memorySlots;
  final List<String> hints;

  Problem({
    required this.id,
    required this.title,
    required this.description,
    required this.inputs,
    required this.expectedOutputs,
    required this.memorySlots,
    required this.hints,
  });

  factory Problem.fromJson(Map<String, dynamic> json) {
    return Problem(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      inputs: List<int>.from(json['inputs']),
      expectedOutputs: List<int>.from(json['expected_outputs']),
      memorySlots: json['memory_slots'],
      hints: List<String>.from(json['hints'] ?? []),
    );
  }
}

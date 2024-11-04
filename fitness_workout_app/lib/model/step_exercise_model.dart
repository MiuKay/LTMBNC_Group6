class StepExercise {
  final String name;
  final int step;
  final String title;
  final String detail;

  StepExercise({
    required this.name,
    required this.step,
    required this.title,
    required this.detail,
  });

  // Phương thức chuyển đổi từ JSON sang StepExercise
  factory StepExercise.fromJson(Map<String, dynamic> json) {
    return StepExercise(
      name: json['name'] as String,
      step: json['step'] as int,
      title: json['title'] as String,
      detail: json['detail'] as String,
    );
  }

  // Phương thức chuyển đổi từ StepExercise sang JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'step': step,
      'title': title,
      'detail': detail,
    };
  }
}


class Exercise {
  final int calo;
  final String descriptions;
  final String difficulty;
  final String name;
  final String pic;
  final int rep;
  final int time;
  final String video;

  Exercise({
    required this.calo,
    required this.descriptions,
    required this.difficulty,
    required this.name,
    required this.pic,
    required this.rep,
    required this.time,
    required this.video,
  });

  // Tạo một phương thức để chuyển đổi từ Firestore document thành đối tượng Exercise
  factory Exercise.fromJson(Map<String, dynamic> data) {
    return Exercise(
      calo: data['calo'] ?? 0,
      descriptions: data['descriptions'] ?? '',
      difficulty: data['difficulty'] ?? '',
      name: data['name'] ?? '',
      pic: data['pic'] ?? '',
      rep: data['rep'] ?? 0,
      time: data['time'] ?? 0,
      video: data['video'] ?? '',
    );
  }

  // Tạo một phương thức để chuyển đổi từ đối tượng Exercise thành Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'calo': calo,
      'descriptions': descriptions,
      'difficulty': difficulty,
      'name': name,
      'pic': pic,
      'rep': rep,
      'time': time,
      'video': video,
    };
  }
}

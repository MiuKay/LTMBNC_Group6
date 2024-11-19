class WorkoutSchedule {
  final String id;
  final String uid;
  final String name;
  final String day;
  final String hour;
  final String difficulty;
  final bool notify;
  final String repeatInterval;
  final String id_notify;

  WorkoutSchedule({
    required this.id,
    required this.uid,
    required this.name,
    required this.day,
    required this.hour,
    required this.difficulty,
    required this.notify,
    required this.repeatInterval,
    required this.id_notify,
  });

  // Phương thức chuyển đổi từ Map (JSON) sang đối tượng WorkoutSchedule
  factory WorkoutSchedule.fromFirestore(Map<String, dynamic> data) {
    return WorkoutSchedule(
      id: data['id'],
      uid: data['uid'],
      name: data['name'],
      day: data['day'],
      hour: data['hour'],
      difficulty: data['difficulty'],
      notify: data['notify'],
      repeatInterval: data['repeat_interval'],
      id_notify: data['id_notify'],
    );
  }

  // Phương thức chuyển đổi từ đối tượng WorkoutSchedule sang Map (JSON)
  Map<String, dynamic> toMap() {
    return {
      'id':id,
      'uid': uid,
      'name': name,
      'day': day,
      'hour': hour,
      'difficulty': difficulty,
      'notify': notify,
      'repeat_interval': repeatInterval,
      'id_notify': id_notify,
    };
  }
}

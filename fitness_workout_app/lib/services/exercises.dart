import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitness_workout_app/model/step_exercise_model.dart';


class ExercisesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<StepExercise>> fetchStepExercises({
    required String name,
  }) async {
    List<StepExercise> stepExercises = [];

    try {
      QuerySnapshot stepExercisesSnapshot = await _firestore
          .collection('Step_exercies')
          .where('name', isEqualTo: name)
          .orderBy('step')
          .get();

      // Chuyển đổi mỗi tài liệu thành đối tượng StepExercise và thêm vào danh sách
      for (var stepDoc in stepExercisesSnapshot.docs) {
        stepExercises.add(StepExercise.fromJson(stepDoc.data() as Map<String, dynamic>));
      }
    } catch (e) {
      print("Error fetching stepExercises: $e");
    }
    return stepExercises;
  }
}


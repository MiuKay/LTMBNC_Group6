import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/exercise_model.dart';

class WorkoutService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> fetchCategoryWorkoutList() async {
    List<Map<String, dynamic>> categoryWorkoutList = [];

    try {
      // Fetch all CategoryWorkout documents
      QuerySnapshot categorySnapshot = await _firestore.collection('CategoryWorkout').get();
      print("Fetched ${categorySnapshot.docs.length} categories.");

      for (var categoryDoc in categorySnapshot.docs) {
        String categoryId = categoryDoc.id;
        String image = categoryDoc['pic'];
        String title = categoryDoc['name'];

        // Fetch all workouts for the current category in a single query
        QuerySnapshot workoutSnapshot = await _firestore
            .collection('Workout')
            .where('id_cate', isEqualTo: categoryId)
            .get();
        int exerciseCount = workoutSnapshot.size;
        print("Category $title has $exerciseCount workouts.");

        // Collect all unique exercise names for bulk querying
        Set<String> exerciseNames = workoutSnapshot.docs
            .map((workoutDoc) => workoutDoc['name_exercise'] as String)
            .toSet();

        //if (exerciseNames.isNotEmpty) {
          // Fetch exercises with 'Beginner' difficulty for all collected exercise names in a single query
          QuerySnapshot exerciseSnapshot = await _firestore
              .collection('Exercies')
              .where('name', whereIn: exerciseNames.toList())
              .where('difficulty', isEqualTo: 'Beginner')
              .get();

          print("Fetched ${exerciseSnapshot.docs.length} beginner exercises for category $title.");

          // Calculate the total time for all beginner exercises in this category
          int totalTimeInSeconds = 0;
          for (var doc in exerciseSnapshot.docs) {
            var timeField = doc['time'];
            // Handle both int and string values for 'time'
            int exerciseTimeInSeconds = 0;
            if (timeField is int) {
              exerciseTimeInSeconds = timeField;
            } else if (timeField is String) {
              exerciseTimeInSeconds = int.tryParse(timeField) ?? 0;
            }
            totalTimeInSeconds += exerciseTimeInSeconds;
          }

          // Convert total time in seconds to minutes
          int totalTimeInMinutes = (totalTimeInSeconds / 60).round();

          // Calculate calo
          int totalCalo = 0;
          for (var doc in exerciseSnapshot.docs) {
            var caloField = doc['calo'];
            // Handle both int and string values for 'time'
            int calo = 0;
            if (caloField is int) {
              calo = caloField;
            } else if (caloField is String) {
              calo = int.tryParse(caloField) ?? 0;
            }
            totalCalo += calo;
          }

          // Add category workout data to the list
          categoryWorkoutList.add({
            'id': categoryId,
            'image': image,
            'title': title,
            'exercises': "$exerciseCount Exercises",
            'time': "$totalTimeInMinutes Mins",
            'calo' : "$totalCalo Calories Burn",
          });
        //} else {
          print("No exercise names found for category $title.");
        //}
      }
    } catch (e) {
      print("Error fetching category workouts: $e");
    }

    return categoryWorkoutList;
  }

  Future<List<Map<String, dynamic>>> fetchCategoryWorkoutWithLevelList({required String level}) async {
    List<Map<String, dynamic>> categoryWorkoutList = [];

    try {
      // Fetch all CategoryWorkout documents
      QuerySnapshot categorySnapshot = await _firestore
          .collection('CategoryWorkout')
          .where('level', arrayContains: level)
          .get();
      print("Fetched ${categorySnapshot.docs.length} categories.");

      for (var categoryDoc in categorySnapshot.docs) {
        String categoryId = categoryDoc.id;
        String image = categoryDoc['pic'];
        String title = categoryDoc['name'];

        // Fetch all workouts for the current category in a single query
        QuerySnapshot workoutSnapshot = await _firestore
            .collection('Workout')
            .where('id_cate', isEqualTo: categoryId)
            .get();
        int exerciseCount = workoutSnapshot.size;
        print("Category $title has $exerciseCount workouts.");

        // Collect all unique exercise names for bulk querying
        Set<String> exerciseNames = workoutSnapshot.docs
            .map((workoutDoc) => workoutDoc['name_exercise'] as String)
            .toSet();

        if (exerciseNames.isNotEmpty) {
          // Fetch exercises with 'Beginner' difficulty for all collected exercise names in a single query
          QuerySnapshot exerciseSnapshot = await _firestore
              .collection('Exercies')
              .where('name', whereIn: exerciseNames.toList())
              .where('difficulty', isEqualTo: 'Beginner')
              .get();

          print("Fetched ${exerciseSnapshot.docs.length} beginner exercises for category $title.");

          // Calculate the total time for all beginner exercises in this category
          int totalTimeInSeconds = 0;
          for (var doc in exerciseSnapshot.docs) {
            var timeField = doc['time'];
            // Handle both int and string values for 'time'
            int exerciseTimeInSeconds = 0;
            if (timeField is int) {
              exerciseTimeInSeconds = timeField;
            } else if (timeField is String) {
              exerciseTimeInSeconds = int.tryParse(timeField) ?? 0;
            }
            totalTimeInSeconds += exerciseTimeInSeconds;
          }

          // Convert total time in seconds to minutes
          int totalTimeInMinutes = (totalTimeInSeconds / 60).round();

          // Calculate calo
          int totalCalo = 0;
          for (var doc in exerciseSnapshot.docs) {
            var caloField = doc['calo'];
            // Handle both int and string values for 'time'
            int calo = 0;
            if (caloField is int) {
              calo = caloField;
            } else if (caloField is String) {
              calo = int.tryParse(caloField) ?? 0;
            }
            totalCalo += calo;
          }

          // Add category workout data to the list
          categoryWorkoutList.add({
            'id': categoryId,
            'image': image,
            'title': title,
            'exercises': "$exerciseCount Exercises",
            'time': "$totalTimeInMinutes Mins",
            'calo' : "$totalCalo Calories Burn",
          });
        } else {
          print("No exercise names found for category $title.");
        }
      }
    } catch (e) {
      print("Error fetching category workouts: $e");
    }

    return categoryWorkoutList;
  }

  Future<List<Map<String, dynamic>>> fetchToolsForCategory(String categoryId) async {
    List<Map<String, dynamic>> toolsList = [];

    try {
      // Bước 1: Lấy danh sách id_tool từ CateWork_tool
      QuerySnapshot cateWorkToolSnapshot = await FirebaseFirestore.instance
          .collection('CateWork_tool')
          .where('id_cate', isEqualTo: categoryId)
          .get();

      // Bước 2: Lấy danh sách id_tool từ kết quả truy vấn
      List<String> toolIds = cateWorkToolSnapshot.docs
          .map((doc) => doc['id_tool'] as String)
          .toList();

      if (toolIds.isNotEmpty) {
        // Bước 3: Lấy thông tin chi tiết của các tool từ collection Tools
        QuerySnapshot toolsSnapshot = await FirebaseFirestore.instance
            .collection('Tools')
            .where(FieldPath.documentId, whereIn: toolIds)
            .get();

        // Bước 4: Chuyển đổi các document thành map
        for (var toolDoc in toolsSnapshot.docs) {
          toolsList.add({
            'id': toolDoc.id,
            'title': toolDoc['name'],
            'image': toolDoc['pic'],
          });
        }
      }
    } catch (e) {
      print("Error fetching tools: $e");
    }

    return toolsList;
  }

  Future<List<Exercise>> fetchExercisesByCategoryAndDifficulty({
    required String categoryId,
    required String difficulty,
  }) async {
    List<Exercise> exercises = [];

    try {
      // Bước 1: Truy vấn danh sách Workout dựa trên categoryId và sắp xếp theo ste
      print("Fetching workouts for category ID: $categoryId");
      QuerySnapshot workoutSnapshot = await _firestore
          .collection('Workout')
          .where('id_cate', isEqualTo: categoryId)
          .orderBy('step')
          .get();
      print("Fetched ${workoutSnapshot.docs.length} workouts");

      // Lấy danh sách các name_exercise duy nhất từ các document của Workout
      List<String> exerciseNames = workoutSnapshot.docs
          .map((doc) => doc['name_exercise'] as String)
          .toSet()
          .toList();
      print("Unique exercise names extracted: $exerciseNames");

      if (exerciseNames.isNotEmpty) {
        // Bước 2: Truy vấn Exercises với name nằm trong exerciseNames và lọc theo difficulty
        print("Fetching exercises with names: $exerciseNames and difficulty: $difficulty");
        QuerySnapshot exerciseSnapshot = await _firestore
            .collection('Exercies')
            .where('name', whereIn: exerciseNames)
            .where('difficulty', isEqualTo: difficulty)
            .get();
        print("Fetched ${exerciseSnapshot.docs.length} exercises matching difficulty: $difficulty");

        // Tạo bản đồ nhanh để tra cứu tài liệu Exercises
        Map<String, Exercise> exerciseMap = {
          for (var doc in exerciseSnapshot.docs)
            doc['name']: Exercise.fromFirestore(doc.data() as Map<String, dynamic>)
        };

        // Sắp xếp lại danh sách exercises theo thứ tự của exerciseNames
        exercises = exerciseNames
            .where((name) => exerciseMap.containsKey(name)) // Lọc các bài tập hợp lệ
            .map((name) => exerciseMap[name]!) // Lấy bài tập theo thứ tự
            .toList();
      } else {
        print("No exercise names found in workouts for category ID: $categoryId");
      }
    } catch (e) {
      print("Error fetching exercises: $e");
    }
    return exercises;
  }


}

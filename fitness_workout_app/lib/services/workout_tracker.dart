import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../model/exercise_model.dart';
import '../model/step_exercise_model.dart';
import '../model/tip_model.dart';
import '../model/workout_schedule_model.dart';

class WorkoutService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> fetchCategoryWorkoutList() async {
    List<Map<String, dynamic>> categoryWorkoutList = [];

    try {
      // Fetch all CategoryWorkout documents
      QuerySnapshot categorySnapshot = await _firestore.collection(
          'CategoryWorkout').get();
      //print("Fetched ${categorySnapshot.docs.length} categories.");

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
        //print("Category $title has $exerciseCount workouts.");

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

        //print("Fetched ${exerciseSnapshot.docs.length} beginner exercises for category $title.");
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
          'calo': "$totalCalo Calories Burn",
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

  Future<List<Map<String, dynamic>>> fetchCategoryWorkoutWithLevelList(
      {required String level}) async {
    List<Map<String, dynamic>> categoryWorkoutList = [];

    try {
      // Fetch all CategoryWorkout documents
      QuerySnapshot categorySnapshot = await _firestore
          .collection('CategoryWorkout')
          .where('level', arrayContains: level)
          .get();
      //print("Fetched ${categorySnapshot.docs.length} categories.");

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
        //print("Category $title has $exerciseCount workouts.");

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

          //print("Fetched ${exerciseSnapshot.docs.length} beginner exercises for category $title.");
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
            'calo': "$totalCalo Calories Burn",
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

  Future<List<Map<String, dynamic>>> fetchToolsForCategory(
      String categoryId) async {
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
      //print("Fetching workouts for category ID: $categoryId");
      QuerySnapshot workoutSnapshot = await _firestore
          .collection('Workout')
          .where('id_cate', isEqualTo: categoryId)
          .orderBy('step')
          .get();
      //print("Fetched ${workoutSnapshot.docs.length} workouts");

      // Lấy danh sách các name_exercise duy nhất từ các document của Workout
      List<String> exerciseNames = workoutSnapshot.docs
          .map((doc) => doc['name_exercise'] as String)
          .toSet()
          .toList();
      //print("Unique exercise names extracted: $exerciseNames");

      if (exerciseNames.isNotEmpty) {
        // Bước 2: Truy vấn Exercises với name nằm trong exerciseNames và lọc theo difficulty
        //print("Fetching exercises with names: $exerciseNames and difficulty: $difficulty");
        QuerySnapshot exerciseSnapshot = await _firestore
            .collection('Exercies')
            .where('name', whereIn: exerciseNames)
            .where('difficulty', isEqualTo: difficulty)
            .get();
        //print("Fetched ${exerciseSnapshot.docs.length} exercises matching difficulty: $difficulty");

        // Tạo bản đồ nhanh để tra cứu tài liệu Exercises
        Map<String, Exercise> exerciseMap = {
          for (var doc in exerciseSnapshot.docs)
            doc['name']: Exercise.fromFirestore(
                doc.data() as Map<String, dynamic>)
        };

        // Sắp xếp lại danh sách exercises theo thứ tự của exerciseNames
        exercises = exerciseNames
            .where((name) =>
            exerciseMap.containsKey(name)) // Lọc các bài tập hợp lệ
            .map((name) => exerciseMap[name]!) // Lấy bài tập theo thứ tự
            .toList();
      } else {
        print(
            "No exercise names found in workouts for category ID: $categoryId");
      }
    } catch (e) {
      print("Error fetching exercises: $e");
    }
    return exercises;
  }

  Future<Map<String, String>> fetchTimeAndCalo({
    required String categoryId,
    required String difficulty,
  }) async {
    Map<String, String> data = {};

    try {
      QuerySnapshot workoutSnapshot = await _firestore
          .collection('Workout')
          .where('id_cate', isEqualTo: categoryId)
          .get();

      // Collect all unique exercise names for bulk querying
      Set<String> exerciseNames = workoutSnapshot.docs
          .map((workoutDoc) => workoutDoc['name_exercise'] as String)
          .toSet();

      // Fetch exercises with 'Beginner' difficulty for all collected exercise names in a single query
      QuerySnapshot exerciseSnapshot = await _firestore
          .collection('Exercies')
          .where('name', whereIn: exerciseNames.toList())
          .where('difficulty', isEqualTo: difficulty)
          .get();

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
      // Store the result in the map
      data['time'] = "$totalTimeInMinutes Mins";
      data['calo'] = "$totalCalo Calories Burned";
    } catch (e) {
      print("Error fetching category workouts: $e");
    }
    return data;
  }

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
        stepExercises.add(
            StepExercise.fromJson(stepDoc.data() as Map<String, dynamic>));
      }
    } catch (e) {
      print("Error fetching stepExercises: $e");
    }
    return stepExercises;
  }

  Future<List<Map<String, dynamic>>> fetchWorkoutSchedule({
    required String userId,
  }) async {
    List<Map<String, dynamic>> workoutList = [];
    DateTime endDate = DateTime.now().add(Duration(days: 30));
    final DateFormat dateFormat = DateFormat(
        'dd/MM/yyyy hh:mm a'); // Định dạng mong muốn
    final DateFormat hourFormat = DateFormat(
        'hh:mm a'); // Định dạng giờ từ trường hour

    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('WorkoutSchedule')
          .where('uid', isEqualTo: userId)
          .get();

      for (var doc in snapshot.docs) {
        String repeatInterval = doc['repeat_interval'];
        DateTime startDate = DateFormat('dd/MM/yyyy').parse(doc['day']);
        String name = doc['name'];
        String hour = doc['hour'];
        String id = doc['id'];
        DateTime hourTime = hourFormat.parse(
            hour); // Chuyển chuỗi hour thành DateTime

        if (repeatInterval == "no") {
          // Nếu không có lặp lại, chỉ thêm sự kiện vào ngày đã chỉ định
          DateTime eventTime = DateTime(
              startDate.year, startDate.month, startDate.day,
              hourTime.hour, hourTime.minute
          );
          workoutList.add({
            "name": name,
            "start_time": dateFormat.format(eventTime),
            "id": id,
          });
        }
        else if (repeatInterval == "Everyday") {
          // Thêm sự kiện vào mỗi ngày từ ngày bắt đầu cho đến ngày kết thúc
          DateTime currentDate = startDate;
          while (currentDate.isBefore(endDate)) {
            DateTime eventTime = DateTime(
                currentDate.year, currentDate.month, currentDate.day,
                hourTime.hour, hourTime.minute
            );
            workoutList.add({
              "name": name,
              "start_time": dateFormat.format(eventTime), // Định dạng thời gian
              "id": id,
            });
            currentDate =
                currentDate.add(Duration(days: 1)); // Tiến tới ngày tiếp theo
          }
        }
        else {
          DateTime eventTime = DateTime(
              startDate.year, startDate.month, startDate.day,
              hourTime.hour, hourTime.minute
          );
          workoutList.add({
            "name": name,
            "start_time": dateFormat.format(eventTime),
            "id": id,
          });

          List<String> daysOfWeek = repeatInterval.split(',');
          DateTime currentDate = startDate;

          // Đảm bảo currentDate là ngày bắt đầu của tuần tính từ startDate
          currentDate =
              currentDate.subtract(Duration(days: currentDate.weekday - 1));

          while (currentDate.isBefore(endDate)) {
            for (var day in daysOfWeek) {
              DateTime eventTime = findNextDateForDay(day, currentDate);

              // Kiểm tra nếu eventTime là sau startDate và trước endDate
              if (eventTime.isAfter(startDate.subtract(Duration(days: 1))) &&
                  eventTime.isBefore(endDate)) {
                workoutList.add({
                  "name": name,
                  "start_time": dateFormat.format(DateTime(
                      eventTime.year, eventTime.month, eventTime.day,
                      hourTime.hour, hourTime.minute)),
                  "id": id,
                });
              }
            }

            // Tiến tới tuần tiếp theo, không thêm 7 ngày trực tiếp cho currentDate, chỉ tính lại ngày bắt đầu tuần mới
            currentDate = currentDate.add(Duration(days: 7));
          }
        }
      }
    } catch (e) {
      print("Error fetching workout schedule: $e");
    }
    //print("workout schedule: $workoutList");
    return workoutList;
  }

  DateTime findNextDateForDay(String day, DateTime currentDate) {
    // Mảng các ngày trong tuần
    List<String> days = [
      "Monday",
      "Tuesday",
      "Wednesday",
      "Thursday",
      "Friday",
      "Saturday",
      "Sunday"
    ];

    // Tìm chỉ số ngày trong tuần (0 = Monday, 6 = Sunday)
    int targetDayIndex = days.indexOf(day);

    // Tính số ngày còn lại để đến ngày mong muốn
    int daysToAdd = (targetDayIndex - (currentDate.weekday - 1) + 7) % 7;

    // Nếu daysToAdd là 0, nghĩa là ngày lặp lại là ngày hôm nay, ta chuyển sang tuần tiếp theo
    if (daysToAdd == 0) daysToAdd = 7;

    // Tính ngày tiếp theo
    return currentDate.add(Duration(days: daysToAdd));
  }

  Future<String> addWorkoutSchedule({
    required String day,
    required String difficulty,
    required String hour,
    required String name,
    required String repeatInterval,
    required String uid,
  }) async {
    String res = "Có lỗi gì đó xảy ra";
    bool notify = true;

    try {
      // Kiểm tra nếu name hoặc difficulty trống
      if (name.isEmpty || difficulty.isEmpty) {
        return ("Error: Name and difficulty must not be empty.");
      }

      // Chuyển day và hour thành DateTime để kiểm tra trùng lặp và thời gian hợp lệ
      final DateFormat dateFormat = DateFormat('dd/MM/yyyy');
      final DateFormat hourFormat = DateFormat('hh:mm a');

      DateTime selectedDay = dateFormat.parse(day); // Parse day thành DateTime
      DateTime selectedHour = hourFormat.parse(
          hour); // Parse hour thành DateTime

      // Kết hợp ngày và giờ thành một đối tượng DateTime
      DateTime selectedDateTime = DateTime(
          selectedDay.year,
          selectedDay.month,
          selectedDay.day,
          selectedHour.hour,
          selectedHour.minute
      );

      // Kiểm tra nếu thời gian đã chọn là quá khứ so với thời gian hiện tại
      if (selectedDateTime.isBefore(DateTime.now())) {
        return "Error: The selected date and time cannot be in the past.";
      }

      // Kiểm tra nếu đã có sự kiện trùng lặp trong Firestore
      bool isDuplicate = await _checkDuplicateEvent(
          uid, selectedDay, selectedHour);
      if (isDuplicate) {
        return "Error: A workout is already scheduled for this day and time.";
      }

      // Lấy reference đến collection "WorkoutSchedule"
      CollectionReference workoutScheduleRef = FirebaseFirestore.instance
          .collection('WorkoutSchedule');

      // Tạo dữ liệu cho lịch tập
      Map<String, dynamic> workoutData = {
        'day': day,
        'difficulty': difficulty,
        'hour': hour,
        'name': name,
        'notify': notify,
        'repeat_interval': repeatInterval,
        'uid': uid,
      };

      // Thêm dữ liệu vào Firestore và lấy document ID
      DocumentReference docRef = await workoutScheduleRef.add(workoutData);

      // Lấy ID tài liệu được tạo ra từ Firebase
      String docId = docRef.id;

      // Cập nhật lại tài liệu với ID của tài liệu vào trường 'id'
      await docRef.update({
        'id': docId,
      });

      res = ("success");
    } catch (e) {
      return ("Error adding workout schedule: $e");
    }

    return res;
  }

  Future<bool> _checkDuplicateEvent(String uid, DateTime day,
      DateTime hour) async {
    // Kiểm tra sự kiện trùng lặp trong Firestore với UID và ngày giờ
    final DateFormat hourFormat = DateFormat('hh:mm a');

    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('WorkoutSchedule')
          .where('uid', isEqualTo: uid)
          .get();

      for (var doc in snapshot.docs) {
        DateTime eventDay = DateFormat('dd/MM/yyyy').parse(doc['day']);
        DateTime eventHour = hourFormat.parse(doc['hour']);

        // Kiểm tra nếu có sự kiện trùng lặp với ngày và giờ
        if (eventDay.isAtSameMomentAs(day) &&
            eventHour.isAtSameMomentAs(hour)) {
          return true; // Nếu trùng lặp, trả về true
        }
      }
    } catch (e) {
      print("Error checking duplicate event: $e");
    }
    return false; // Không có sự kiện trùng lặp
  }

  Future<String> deleteWorkoutSchedule({required String scheduleId}) async {
    try {
      // Truy cập đến collection 'WorkoutSchedule' và xoá tài liệu theo id
      await FirebaseFirestore.instance
          .collection('WorkoutSchedule')
          .doc(scheduleId)
          .delete();

      return ('success');
    } catch (e) {
      return ('Error deleting workout schedule: $e');
    }
  }

  Future<WorkoutSchedule> getWorkoutScheduleById(
      {required String scheduleId}) async {
    //print("Find: $scheduleId");
    DocumentSnapshot doc = await _firestore.collection("WorkoutSchedule")
        .doc(scheduleId)
        .get();
    return WorkoutSchedule.fromFirestore(doc.data() as Map<String, dynamic>);
  }

  Future<String> updateSchedule({
    required String id,
    required String day,
    required String difficulty,
    required String hour,
    required String name,
    required String repeatInterval,
    required String uid,
  }) async {
    String res = "Có lỗi gì đó xảy ra";

    try {
      // Kiểm tra nếu name hoặc difficulty trống
      if (name.isEmpty || difficulty.isEmpty) {
        return ("Error: Name and difficulty must not be empty.");
      }
      // Chuyển day và hour thành DateTime để kiểm tra trùng lặp và thời gian hợp lệ
      final DateFormat dateFormat = DateFormat('dd/MM/yyyy');
      final DateFormat hourFormat = DateFormat('hh:mm a');
      DateTime selectedDay = dateFormat.parse(day); // Parse day thành DateTime
      DateTime selectedHour = hourFormat.parse(hour); // Parse hour thành DateTime
      // Kết hợp ngày và giờ thành một đối tượng DateTime
      DateTime selectedDateTime = DateTime(
          selectedDay.year,
          selectedDay.month,
          selectedDay.day,
          selectedHour.hour,
          selectedHour.minute
      );
      // Kiểm tra nếu thời gian đã chọn là quá khứ so với thời gian hiện tại
      if (selectedDateTime.isBefore(DateTime.now())) {
        return "Error: The selected date and time cannot be in the past.";
      }
      // Kiểm tra nếu đã có sự kiện trùng lặp trong Firestore
      bool isDuplicate = await _checkDuplicateEvent(
          uid, selectedDay, selectedHour);
      if (isDuplicate) {
        return "Error: A workout is already scheduled for this day and time.";
      }
      // Cập nhật lại tài liệu với ID của tài liệu vào trường 'id'
      await _firestore.collection('WorkoutSchedule').doc(id).update({
        'difficulty': difficulty,
        'hour': hour,
        'name': name,
        'repeat_interval': repeatInterval,
      });

      res = ("success");
    } catch (e) {
      return ("Error updating workout schedule: $e");
    }
    return res;
  }
}





import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../model/exercise_model.dart';
import '../model/step_exercise_model.dart';
import '../model/workout_schedule_model.dart';
import 'notification.dart';

class WorkoutService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NotificationServices notificationServices = NotificationServices();

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
          'difficulty': 'Beginner',
        });
        //} else {
        //print("No exercise names found for category $title.");
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
    String diff = 'Beginner';

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
            'difficulty': diff,
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
            doc['name']: Exercise.fromJson(
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
      data['calo'] = "$totalCalo Calo Burned";
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
    required bool notify,
  }) async {
    String res = "Có lỗi gì đó xảy ra";

    try {
      // Kiểm tra nếu name hoặc difficulty trống
      if (name.isEmpty || difficulty.isEmpty) {
        return ("Error: Name and difficulty must not be empty.");
      }

      QuerySnapshot snapshot = await _firestore
          .collection('CategoryWorkout')
          .where('name', isEqualTo: name)
          .get();

      var doc = snapshot.docs.first; // Lấy tài liệu đầu tiên
      String id_cate = doc.id;
      String pic = doc['pic'];

      // Chuyển đổi chuỗi ngày và giờ thành DateTime
      final DateFormat dateFormat = DateFormat('dd/MM/yyyy');
      final DateFormat hourFormat = DateFormat('hh:mm a');
      DateTime selectedDay = dateFormat.parse(day);
      DateTime selectedHour = hourFormat.parse(hour);

      DateTime selectedDateTime = DateTime(
        selectedDay.year,
        selectedDay.month,
        selectedDay.day,
        selectedHour.hour,
        selectedHour.minute,
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

      CollectionReference workoutScheduleRef = FirebaseFirestore.instance.collection('WorkoutSchedule');
      Map<String, dynamic> workoutData = {
        'day': day,
        'difficulty': difficulty,
        'hour': hour,
        'name': name,
        'repeat_interval': repeatInterval,
        'uid': uid,
        'notify': notify,
        'id_cate': id_cate,
        'pic': pic,
      };

      DocumentReference docRef = await workoutScheduleRef.add(workoutData);

      // Đặt lịch thông báo
      String id_notify = await notificationServices.scheduleWorkoutNotification(
        id: docRef.id,
        scheduledTime: selectedDateTime,
        workoutName: name,
        repeatInterval: repeatInterval,
        id_cate: id_cate,
        pic: pic,
        diff: difficulty,
      );

      await docRef.update({
        'id': docRef.id,
        'id_notify': id_notify,
      });

      res = "success";
    } catch (e) {
      return "Error adding workout schedule: $e";
    }

    return res;
  }

  Future<bool> _checkDuplicateEvent(String uid, DateTime day,
      DateTime hour) async {
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

  Future<bool> _checkDuplicateEventForUpdate(String uid, String id, DateTime day,
      DateTime hour) async {
    final DateFormat hourFormat = DateFormat('hh:mm a');

    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('WorkoutSchedule')
          .where('uid', isEqualTo: uid)
          .get();

      for (var doc in snapshot.docs) {
        DateTime eventDay = DateFormat('dd/MM/yyyy').parse(doc['day']);
        DateTime eventHour = hourFormat.parse(doc['hour']);

        if(doc.id == id) {continue;}
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

      QuerySnapshot snapshot = await _firestore
          .collection('WorkoutSchedule')
          .where('id', isEqualTo: scheduleId)
          .get();

      var doc = snapshot.docs.first;
      String id_notify = doc['id_notify'];

      await notificationServices.cancelNotificationById(int.parse(id_notify));

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
    DocumentSnapshot doc = await _firestore.collection("WorkoutSchedule")
        .doc(scheduleId)
        .get();
    return WorkoutSchedule.fromJson(doc.data() as Map<String, dynamic>);
  }

  Future<String> updateSchedule({
    required String id,
    required String day,
    required String difficulty,
    required String hour,
    required String name,
    required String repeatInterval,
    required String uid,
    required bool notify,
    required String id_notify,
  }) async {
    String res = "Có lỗi gì đó xảy ra";
    String newid_notify = id_notify;

    try {
      // Kiểm tra nếu name hoặc difficulty trống
      if (name.isEmpty || difficulty.isEmpty) {
        return ("Error: Name and difficulty must not be empty.");
      }

      QuerySnapshot snapshot = await _firestore
          .collection('CategoryWorkout')
          .where('name', isEqualTo: name)
          .get();

      var doc = snapshot.docs.first; // Lấy tài liệu đầu tiên
      String id_cate = doc.id;
      String pic = doc['pic'];

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
      bool isDuplicate = await _checkDuplicateEventForUpdate(
          uid, id, selectedDay, selectedHour);
      if (isDuplicate) {
        return "Error: A workout is already scheduled for this day and time.";
      }

      await notificationServices.cancelNotificationById(int.parse(id_notify));

      if(notify) { // Đặt lịch thông báo
        newid_notify = await notificationServices
            .scheduleWorkoutNotification(
          id: id,
          scheduledTime: selectedDateTime,
          workoutName: name,
          repeatInterval: repeatInterval,
          id_cate: id_cate,
          pic: pic,
          diff: difficulty,
        );
      }

      // Cập nhật lại tài liệu với ID của tài liệu vào trường 'id'
      await _firestore.collection('WorkoutSchedule').doc(id).update({
        'difficulty': difficulty,
        'hour': hour,
        'name': name,
        'repeat_interval': repeatInterval,
        'notify': notify,
        'id_cate': id_cate,
        'pic': pic,
        'id_notify': newid_notify,
      });

      res = ("success");
    } catch (e) {
      return ("Error updating workout schedule: $e");
    }
    return res;
  }

  Future<String> createEmptyWorkoutHistory({
    required String uid,
    required String idCate,
    required List<Exercise> exercisesArr,
    required String difficulty,
  }) async {
    final historyData = {
      'uid': uid,
      'id_cate': idCate,
      'exercisesArr': exercisesArr.map((e) => e.toFirestore()).toList(),
      'index': 0,
      'duration': 0,
      'caloriesBurned': 0,
      'completedAt': null,
      'difficulty': difficulty,
    };

    // Lưu vào Firestore (hoặc MongoDB tùy vào cấu trúc database của bạn)
    final docRef = await FirebaseFirestore.instance
        .collection('WorkoutHistory')
        .add(historyData);

    await FirebaseFirestore.instance
        .collection('WorkoutHistory')
        .doc(docRef.id)
        .update({
      'id': docRef.id,
    });

    return docRef.id; // Trả về workoutId
  }

  Future<void> updateWorkoutHistory({
    required String historyId,
    required int index,
    required int duration,
    required int caloriesBurned,
    required DateTime completedAt,
  }) async {
    final collection = FirebaseFirestore.instance.collection('WorkoutHistory');

    // Lấy dữ liệu hiện tại của lịch sử
    final historyDoc = await collection.doc(historyId).get();

    final data = historyDoc.data();

    // Lấy tổng thời gian và calo đã lưu trước đó
    int previousTotalTime = data?['duration'] ?? 0;
    int previousTotalCalo = data?['caloriesBurned'] ?? 0;

    // print('calo: $previousTotalCalo');
    // print('time: $previousTotalTime');

    // Cộng dồn thời gian và calo
    int newTotalTime = previousTotalTime + duration;
    int newTotalCalo = previousTotalCalo + caloriesBurned;

    // print('New calo: $newTotalCalo');
    // print('New time: $newTotalTime');

    await FirebaseFirestore.instance
        .collection('WorkoutHistory')
        .doc(historyId)
        .update({
      'index': index,
      'duration': newTotalTime,
      'caloriesBurned': newTotalCalo,
      'completedAt': completedAt,
    });
  }

  Future<Map<String, int>> getWorkoutHistory({
    required String historyId,
  }) async {
    final collection = FirebaseFirestore.instance.collection('WorkoutHistory');

    try {
      // Lấy dữ liệu từ Firestore bằng historyId
      final historyDoc = await collection.doc(historyId).get();

      // Kiểm tra nếu tài liệu tồn tại
      if (historyDoc.exists) {
        final data = historyDoc.data();

        // Lấy giá trị caloriesBurned và duration từ dữ liệu
        int caloriesBurned = data?['caloriesBurned'] ?? 0;
        int duration = data?['duration'] ?? 0;

        return {
          'caloriesBurned': caloriesBurned,
          'duration': duration,
        };
      } else {
        // Trường hợp không tìm thấy tài liệu
        print('No workout history found for the given ID');
        return {
          'caloriesBurned': 0,
          'duration': 0,
        };
      }
    } catch (e) {
      print('Error fetching workout history: $e');
      return {
        'caloriesBurned': 0,
        'duration': 0,
      };
    }
  }

  Future<List<Map<String, dynamic>>> fetchWorkoutHistory({
    required String uid,
  }) async {
    List<Map<String, dynamic>> resultList = [];

    try {
      // Lấy danh sách tài liệu từ WorkoutHistory theo uid
      QuerySnapshot workoutSnapshot = await FirebaseFirestore.instance
          .collection('WorkoutHistory')
          .where('uid', isEqualTo: uid)
          .orderBy('completedAt', descending: true)
          .get();

      for (var doc in workoutSnapshot.docs) {
        final historyData = doc.data() as Map<String, dynamic>;

        // Lấy thông tin từ id_cate trong CategoryWorkout
        String idCate = historyData['id_cate'];
        DocumentSnapshot categorySnapshot = await FirebaseFirestore.instance
            .collection('CategoryWorkout')
            .doc(idCate)
            .get();

        final categoryData = categorySnapshot.data() as Map<String, dynamic>?;

        // Chuyển đổi exercisesArr từ List<dynamic> thành List<Exercise>
        List<Exercise> exercisesArr = (historyData['exercisesArr'] as List)
            .map((exercise) => Exercise.fromJson(exercise))
            .toList();

        // Tính toán 'process'
        int index = historyData['index'] ?? 0;
        double progress = exercisesArr.isNotEmpty ? ((index + 1) / exercisesArr.length) : 0.0;

        // Thêm vào danh sách kết quả
        resultList.add({
          'id': doc.id,
          'name': categoryData?['name'] ?? 'No Name',
          'image': categoryData?['pic'] ?? '',
          'index': index,
          'progress': progress,
          'exercisesArr': exercisesArr,
          'calo': historyData['caloriesBurned'] ?? 0,
          'time': (historyData['duration']! / 60) ?? 0,
          'completedAt': historyData['completedAt'],
        });
      }
    } catch (e) {
      print('Error fetching workout history: $e');
    }
    return resultList;
  }

  Future<List<WorkoutSchedule>> getClosestWorkoutSchedules({
    required String uid,
  }) async {
    try {
      // Lấy toàn bộ danh sách theo uid
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('WorkoutSchedule')
          .where('uid', isEqualTo: uid)
          .get();
      // Chuyển đổi dữ liệu
      List<WorkoutSchedule> workoutSchedules = querySnapshot.docs
          .map((doc) => WorkoutSchedule.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
      // Lọc và sắp xếp
      List<WorkoutSchedule> filteredSchedules = workoutSchedules.where((doc) {
        DateTime? time = parseDate(doc.day, doc.hour);
        return time != null && !(time.isBefore(DateTime.now()) && doc.repeatInterval == 'no');
      }).toList();
      // Sắp xếp theo ngày tăng dần
      filteredSchedules.sort((a, b) {
        DateTime dateA = parseDate(a.day, a.hour)!;
        DateTime dateB = parseDate(b.day, b.hour)!;
        return dateA.compareTo(dateB);
      });

      return filteredSchedules.take(2).toList();
    } catch (e) {
      print("Lỗi khi lấy WorkoutSchedule: $e");
      return [];
    }
  }

  DateTime? parseDate(String day, String hour) {
    try {
      return DateFormat("dd/MM/yyyy h:mm a").parse("$day $hour");
    } catch (e) {
      print("Lỗi khi parse ngày giờ: $e");
      return null;
    }
  }

  Future<Map<String, List<FlSpot>>> generateWeeklyData({
    required String uid,
  }) async {
    DateTime now = DateTime.now();
    DateTime startOfWeek = now.subtract(Duration(days: now.weekday-1));
    DateTime endOfWeek = startOfWeek.add(Duration(days: 6));

    Map<int, double> caloriesByDay = {for (int i = 1; i <= 7; i++) i: 0};
    Map<int, double> durationByDay = {for (int i = 1; i <= 7; i++) i: 0};

    QuerySnapshot workoutSnapshot = await FirebaseFirestore.instance
        .collection('WorkoutHistory')
        .where('uid', isEqualTo: uid)
        .where('completedAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfWeek))
        .where('completedAt', isLessThanOrEqualTo: Timestamp.fromDate(endOfWeek))
        .get();

    for (var doc in workoutSnapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      DateTime completedAt = DateTime.fromMillisecondsSinceEpoch(data['completedAt'].seconds * 1000);
      int weekday = completedAt.weekday;

      caloriesByDay[weekday] = caloriesByDay[weekday]! + (data['caloriesBurned'] ?? 0.0);
      durationByDay[weekday] = durationByDay[weekday]! + (data['duration'] ?? 0.0);
    }

    List<FlSpot> calorieSpots = [];
    List<FlSpot> durationSpots = [];
    for (int i = 1; i <= 7; i++) {
      calorieSpots.add(FlSpot(i.toDouble(), caloriesByDay[i]!));
      durationSpots.add(FlSpot(i.toDouble(), durationByDay[i]!));
    }

    return {
      'calories': calorieSpots,
      'duration': durationSpots,
    };
  }
}





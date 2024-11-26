import 'dart:async';
import 'package:fitness_workout_app/view/workout_tracker/ready_view.dart';
import 'package:fitness_workout_app/view/workout_tracker/workout_tracker_view.dart';
import 'package:flutter/material.dart';
import 'package:fitness_workout_app/view/workout_tracker/breaktime_view.dart';
import 'package:provider/provider.dart';
import '../../model/exercise_model.dart';
import '../../services/workout_tracker.dart';
import 'finished_workout_view.dart';

class WorkOutDet extends StatelessWidget {
  final List<Exercise> exercises;
  final int index;
  final String historyId;

  const WorkOutDet({
    Key? key,
    required this.exercises,
    required this.index,
    required this.historyId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentExercise = exercises[index];
    final WorkoutService _workoutService = WorkoutService();

    return ChangeNotifierProvider<TimerModelSec>(
      create: (context) => TimerModelSec(context, currentExercise.time, exercises, index, historyId),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            Container(
              child: Column(
                children: [
                  Container(
                    height: 350,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: NetworkImage(currentExercise.pic.toString()),
                      ),
                    ),
                  ),
                  Spacer(),
                  Text(
                    currentExercise.name.toString(),
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 35),
                  ),
                  Spacer(),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 80),
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 25),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: currentExercise.rep == 0
                        ? Consumer<TimerModelSec>(
                      builder: (context, myModel, child) {
                        int minutes = myModel.countdown ~/ 60;
                        int seconds = myModel.countdown % 60;
                        return Text(
                          "${minutes.toString().padLeft(2, '0')} : ${seconds.toString().padLeft(2, '0')}",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 30,
                            color: Colors.white,
                          ),
                        );
                      },
                    )
                        : Text(
                      "x${currentExercise.rep}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Spacer(),
                  SizedBox(height: 30,),
                  Consumer<TimerModelSec>(
                    builder: (context, myModel, child) {
                      return ElevatedButton(onPressed: () {
                        myModel.show();
                      }, child: Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 15),
                          child: Text(
                            "PAUSE", style: TextStyle(fontSize: 20),)));
                    },
                  ),
                  Spacer(),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        index != 0
                            ? Consumer<TimerModelSec>(
                          builder: (context, myModel, child) {
                            return TextButton(
                              onPressed: () async {
                                // Tính toán thời gian thực tế và lượng calo
                                final currentExercise = exercises[index];
                                final realTime = currentExercise.time - myModel.countdown; // Thời gian thực tế
                                final caloriesBurned = (realTime * currentExercise.calo) ~/ currentExercise.time; // Tính calo

                                // Cập nhật lịch sử trước khi chuyển bài
                                await _workoutService.updateWorkoutHistory(
                                  historyId: historyId,
                                  index: index,
                                  duration: realTime,
                                  caloriesBurned: caloriesBurned,
                                  completedAt: DateTime.now(),
                                );

                                myModel.Pass(); // Dừng bộ đếm thời gian
                                await Future.delayed(Duration(seconds: 1));
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => BreakTime(
                                      exercises: exercises,
                                      index: index,
                                      historyId: historyId,
                                    ),
                                  ),
                                );
                              },
                              child: Text(
                                "Previous",
                                style: const TextStyle(fontSize: 16),
                              ),
                            );
                          },
                        )
                            : Container(),
                        Consumer<TimerModelSec>(
                          builder: (context, myModel, child) {
                            return TextButton(
                              onPressed: () async {
                                // Tính toán thời gian thực tế và lượng calo
                                final currentExercise = exercises[index];
                                final realTime = currentExercise.time - myModel.countdown; // Thời gian thực tế
                                final caloriesBurned = (realTime * currentExercise.calo) ~/ currentExercise.time; // Tính calo

                                // Cập nhật lịch sử trước khi chuyển bài
                                await _workoutService.updateWorkoutHistory(
                                  historyId: historyId,
                                  index: index,
                                  duration: realTime,
                                  caloriesBurned: caloriesBurned,
                                  completedAt: DateTime.now(),
                                );

                                myModel.Pass(); // Dừng bộ đếm thời gian
                                await Future.delayed(Duration(seconds: 1));

                                // Kiểm tra nếu đây là bài tập cuối cùng
                                if (index == exercises.length - 1) {
                                  // Nếu là bài tập cuối cùng, điều hướng đến FinishedWorkoutView
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => FinishedWorkoutView(historyId: historyId,),
                                    ),
                                  );
                                } else {
                                  // Nếu không, điều hướng đến bài tập tiếp theo
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => BreakTime(
                                        exercises: exercises,
                                        index: index + 1,
                                        historyId: historyId,
                                      ),
                                    ),
                                  );
                                }
                              },
                              child: Text(
                                index == exercises.length - 1 ? "Finish" : "Next",
                                style: TextStyle(fontSize: 16),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  Divider(thickness: 2,),
                  Align(
                      alignment: Alignment.bottomLeft,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 15),
                        child: Text("Next: ${index != exercises.length - 1 ? exercises[index+1].name : 'Finish'}",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                      ))
                ],
              ),
            ),
            Consumer<TimerModelSec>(
              builder: (context, myModel, child) {
                return Visibility(
                    visible: myModel.visible,
                    child: Container(
                      color: Colors.blueAccent.withOpacity(0.9),
                      height: MediaQuery
                          .of(context)
                          .size
                          .height,
                      width: MediaQuery
                          .of(context)
                          .size
                          .width,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Pause", style: TextStyle(fontSize: 40,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),),
                          SizedBox(height: 30,),
                          OutlinedButton(
                            onPressed: () {
                              // Hiển thị hộp thoại xác nhận
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text("Xác nhận"),
                                    content: Text("Bạn có chắc chắn muốn khởi động lại không?"),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () {
                                          // Nếu người dùng nhấn "Không", đóng hộp thoại
                                          Navigator.of(context).pop();
                                        },
                                        child: Text("Không"),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          // Nếu người dùng nhấn "Có", điều hướng đến ReadyView
                                          Navigator.of(context).pop(); // Đóng hộp thoại trước
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => ReadyView(exercises: exercises, index: 0, historyId: historyId,),
                                            ),
                                          );
                                        },
                                        child: Text("Có"),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: Container(
                              width: 180,
                              child: Text(
                                "Restart",
                                style: TextStyle(color: Colors.white),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          OutlinedButton(
                            onPressed: () {
                              // Hiển thị hộp thoại xác nhận
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text("Xác nhận"),
                                    content: Text("Bạn có chắc chắn muốn thoát không?"),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () {
                                          // Nếu người dùng nhấn "Không", đóng hộp thoại
                                          Navigator.of(context).pop();
                                        },
                                        child: Text("Không"),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          // Tính toán thời gian thực tế và lượng calo
                                          final currentExercise = exercises[index];
                                          final realTime = currentExercise.time - myModel.countdown; // Thời gian thực tế
                                          final caloriesBurned = (realTime * currentExercise.calo) ~/ currentExercise.time; // Tính calo

                                          // Cập nhật lịch sử trước khi chuyển bài
                                          await _workoutService.updateWorkoutHistory(
                                            historyId: historyId,
                                            index: index,
                                            duration: realTime,
                                            caloriesBurned: caloriesBurned,
                                            completedAt: DateTime.now(),
                                          );

                                          // Nếu người dùng nhấn "Có", điều hướng đến WorkoutTrackerView
                                          Navigator.of(context).pop(); // Đóng hộp thoại trước
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => FinishedWorkoutView(historyId: historyId),
                                            ),
                                          );
                                        },
                                        child: Text("Có"),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: Container(
                              width: 180,
                              child: Text(
                                "Quit",
                                style: TextStyle(color: Colors.white),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          OutlinedButton(onPressed: () {
                            myModel.hide();
                          }, child: Container(
                            width: 180,
                            child: Text("RESUME", textAlign: TextAlign.center,),
                          ), style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(
                                  Colors.white)),)
                        ],
                      ),
                    ));
              },
            )
          ],
        ),
      ),);
  }
}

class TimerModelSec with ChangeNotifier {
  int countdown;
  bool visible = false;
  bool isPassed = false;
  Timer? _timer;
  final String historyId;
  final WorkoutService _workoutService = WorkoutService();

  TimerModelSec(BuildContext context, int initialTime, List<Exercise> exercises, int index, this.historyId) : countdown = initialTime {
    _startTimer(context, exercises, index);
  }

  void _startTimer(BuildContext context, List<Exercise> exercises, int index) {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (!visible && !isPassed) {
        countdown--;
        notifyListeners();

        if (countdown <= 0) {
          timer.cancel();

          // Cập nhật lịch sử tập luyện sau khi hoàn thành bài tập
          final exercise = exercises[index];
          await _workoutService.updateWorkoutHistory(
            historyId: historyId,
            index: index,
            duration: exercise.time,
            caloriesBurned: exercise.calo,
            completedAt: DateTime.now(),
          );
          if (index >= exercises.length - 1) {
            // Nếu là bài tập cuối cùng, chuyển đến FinishedWorkoutView
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) =>
                  FinishedWorkoutView(historyId: historyId,)),
            );
          } else {
            // Chuyển đến bài tập tiếp theo
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    BreakTime(
                      exercises: exercises,
                      index: index + 1,
                      historyId: historyId,
                    ),
              ),
            );
          }
        }
      } else if (isPassed) {
        timer.cancel();
      }
    });
  }


  void show() {
    visible = true;
    notifyListeners();
  }

  void hide() {
    visible = false;
    notifyListeners();
  }

  void Pass() {
    isPassed = true;
    _timer?.cancel();
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();  // Hủy bỏ timer khi không sử dụng
    super.dispose();
  }
}

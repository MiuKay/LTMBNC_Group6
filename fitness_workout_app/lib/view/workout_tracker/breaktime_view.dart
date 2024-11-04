import 'dart:async';
import 'package:fitness_workout_app/view/workout_tracker/workout_start_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../model/exercise_model.dart';
import '../home/finished_workout_view.dart';

class BreakTime extends StatelessWidget {
  final List<Exercise> exercises;
  final int index;

  const BreakTime({
    Key? key,
    required this.exercises,
    required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<TimerModelSec>(
      create: (context) => TimerModelSec(context, 10, exercises, index),
      child: Scaffold(
        body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.cover,
              image: AssetImage("assets/img/breaktime.jpg"),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Spacer(),
              Text(
                "Break Time",
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              Consumer<TimerModelSec>(
                builder: (context, myModel, child) {
                  return Text(
                    myModel.countdown.toString(),
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 55, color: Colors.white),
                  );
                },
              ),
              SizedBox(height: 20),
              Consumer<TimerModelSec>(
                builder: (context, timerModel, child) {
                  return ElevatedButton(
                    onPressed: () {
                      timerModel.addTime(10); // Gọi addTime từ Consume
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 24),
                      child: Text("+10 sec", style: TextStyle(fontSize: 19)),
                    ),
                  );
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
                            myModel.Pass();
                            await Future.delayed(Duration(seconds: 1));
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => WorkOutDet(
                                  exercises: exercises,
                                  index: index - 1,
                                ),
                              ),
                            );
                          },
                          child: Text(
                            "Previous",
                            style: const TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        );
                      },
                    )
                        : Container(),
                    Consumer<TimerModelSec>(
                      builder: (context, myModel, child) {
                        return TextButton(
                          onPressed: () async {
                            myModel.Pass();
                            await Future.delayed(Duration(seconds: 1));
                            // Nếu không, điều hướng đến bài tập tiếp
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => WorkOutDet(
                                  exercises: exercises,
                                  index: index,
                                ),
                              ),
                            );
                          },
                          child: Text(
                            "Skip",
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              Divider(thickness: 2),
              Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  child: Text(
                    "Next: ${index != exercises.length - 1 ? exercises[index].name : 'Finish'}",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TimerModelSec with ChangeNotifier {
  int countdown;
  bool visible = false;
  bool isPassed = false;
  Timer? _timer;

  TimerModelSec(BuildContext context, int initialTime, List<Exercise> exercises, int index)
      : countdown = initialTime {
    _startTimer(context, exercises, index);
  }

  void _startTimer(BuildContext context, List<Exercise> exercises, int index) {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (!visible && !isPassed) {  // Đếm ngược nếu không tạm dừng hoặc chuyển bài
        countdown--;
        notifyListeners();

        if (countdown <= 0) {
          timer.cancel();

          if (index >= exercises.length - 1) {
            // Nếu đây là bài tập cuối cùng, chuyển đến FinishedWorkoutView
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => FinishedWorkoutView()),
            );
          } else {
            // Nếu còn bài tập tiếp theo, chuyển đến BreakTime
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => WorkOutDet(exercises: exercises, index: index),
              ),
            );
          }
        }
      } else if (isPassed) {
        timer.cancel();
      }
    });
  }

  void addTime(int seconds) {
    countdown += seconds;  // Tăng thời gian đếm ngược
    notifyListeners();     // Thông báo các widget cần cập nhật
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


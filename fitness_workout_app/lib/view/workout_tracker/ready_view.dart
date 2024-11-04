import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fitness_workout_app/view/workout_tracker/workout_start_view.dart';
import 'package:provider/provider.dart';
import '../../model/exercise_model.dart';

class ReadyView extends StatelessWidget {
  final List<Exercise> exercises;

  const ReadyView({Key? key, required this.exercises}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<TimerModel>(
      create: (context) => TimerModel(context, exercises), // Truyền exercises vào TimerModel
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: MediaQuery.of(context).size.height / 2 - 100),
                Text(
                  "ARE YOU READY?",
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 40),
                Consumer<TimerModel>(
                  builder: (context, myModel, child) {
                    return Text(
                      myModel.countdown.toString(),
                      style: TextStyle(fontSize: 48),
                    );
                  },
                ),
                Spacer(),
                Divider(thickness: 2),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                    child: Text(
                      "Next: ${exercises.isNotEmpty ? exercises[0].name : 'No Exercise'}",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TimerModel with ChangeNotifier {
  final List<Exercise> exercises;
  int countdown = 5;

  TimerModel(context, this.exercises) {
    MyTimer(context);
  }

  MyTimer(context) async {
    Timer.periodic(Duration(seconds: 1), (timer) {
      countdown--;
      if (countdown == 0) {
        timer.cancel();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WorkOutDet(
              exercises: exercises, // Truyền danh sách exercises
              index: 0, // Truyền chỉ số ban đầu
            ),
          ),
        );
      }
      notifyListeners();
    });
  }
}

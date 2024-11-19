import 'package:flutter/material.dart';

import '../../common/colo_extension.dart';
import '../../common_widget/round_button.dart';
import '../../services/workout_tracker.dart';
import 'workout_tracker_view.dart';

class FinishedWorkoutView extends StatefulWidget {
  final String historyId;
  const FinishedWorkoutView({Key? key, required this.historyId}) : super(key: key);

  @override
  State<FinishedWorkoutView> createState() => _FinishedWorkoutViewState();
}

class _FinishedWorkoutViewState extends State<FinishedWorkoutView> {
  final WorkoutService _workoutService = WorkoutService();
  int caloriesBurned = 0;
  double duration = 0;

  @override
  void initState() {
    super.initState();
    _getData();
  }

  void _getData() async{
    final historyData = await _workoutService.getWorkoutHistory(historyId: widget.historyId);
    setState(() {
      caloriesBurned = historyData['caloriesBurned']!;
      duration = (historyData['duration']! / 60);
    });
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: TColor.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              const SizedBox(height: 20,),
              Image.asset(
                "assets/img/complete_workout.png",
                height: media.width * 0.8,
                fit: BoxFit.fitHeight,
              ),

              const SizedBox(
                height: 30,
              ),

              Text(
                "Congratulations, You Have Finished Your Workout",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: TColor.black,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(
                height: 35,
              ),

              Container(
                margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 5),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 5,
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // Thống kê KCal
                    Column(
                      children: [
                        Icon(Icons.local_fire_department, color: Colors.redAccent, size: 40),
                        const SizedBox(height: 10),
                        Text(
                          caloriesBurned.toString(),
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const Text(
                          "KCal",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      height: 60,
                      width: 1,
                      color: Colors.grey[300],
                    ),
                    // Thống kê Minutes
                    Column(
                      children: [
                        Icon(Icons.timer, color: Colors.blueAccent, size: 40),
                        const SizedBox(height: 10),
                        Text(
                          duration.toStringAsFixed(2),
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const Text(
                          "Minutes",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Spacer(),
              RoundButton(
                  title: "Back To Home",
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (
                            context) => const WorkoutTrackerView(),
                      ),
                    );
                  }),

              const SizedBox(
                height: 50,
              ),

            ],
          ),
        ),
      ),
    );
  }
}
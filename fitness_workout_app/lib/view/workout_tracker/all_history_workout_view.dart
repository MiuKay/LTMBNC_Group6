import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness_workout_app/common/colo_extension.dart';
import 'package:flutter/material.dart';
import '../../common_widget/what_train_row.dart';
import '../../common_widget/workout_row.dart';
import '../../services/workout_tracker.dart';

class AllHistoryWorkoutView extends StatefulWidget {
  const AllHistoryWorkoutView({super.key});

  @override
  State<AllHistoryWorkoutView> createState() => _AllHistoryWorkoutViewState();
}

class _AllHistoryWorkoutViewState extends State<AllHistoryWorkoutView> {
  final WorkoutService _workoutService = WorkoutService();
  List<Map<String, dynamic>> lastWorkoutArr = [];

  @override
  void initState() {
    super.initState();
    _loadHistoryWorkout();
  }

  void _loadHistoryWorkout() async {
    List<Map<String, dynamic>> lastWorkout = await _workoutService.fetchWorkoutHistory(
        uid:FirebaseAuth.instance.currentUser!.uid);
    setState(() {
      lastWorkoutArr = lastWorkout;
    });
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Container(
      decoration:
      BoxDecoration(gradient: LinearGradient(colors: TColor.primaryG)),
      child: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              backgroundColor: Colors.transparent,
              centerTitle: true,
              elevation: 0,
              // pinned: true,
              leading: InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  margin: const EdgeInsets.all(8),
                  height: 40,
                  width: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: TColor.lightGray,
                      borderRadius: BorderRadius.circular(10)),
                  child: Image.asset(
                    "assets/img/black_btn.png",
                    width: 15,
                    height: 15,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              title: Text(
                "History Workout List",
                style: TextStyle(
                    color: TColor.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700),
              ),
            ),
          ];
        },
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
              color: TColor.white,
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(25), topRight: Radius.circular(25))),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  ListView.builder(
                      padding: EdgeInsets.zero,
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: lastWorkoutArr.length,
                      itemBuilder: (context, index) {
                        var wObj = lastWorkoutArr[index] as Map? ?? {};
                        return InkWell(
                            child: WorkoutRow(wObj: wObj));
                      }),
                  SizedBox(
                    height: media.width * 0.1,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
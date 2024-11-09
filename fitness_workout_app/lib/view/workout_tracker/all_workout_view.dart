import 'package:fitness_workout_app/common/colo_extension.dart';
import 'package:flutter/material.dart';
import '../../common_widget/what_train_row.dart';
import '../../services/workout_tracker.dart';

class AllWorkoutView extends StatefulWidget {
  const AllWorkoutView({super.key});

  @override
  State<AllWorkoutView> createState() => _AllWorkoutViewState();
}

class _AllWorkoutViewState extends State<AllWorkoutView> {
  final WorkoutService _workoutService = WorkoutService();
  List<Map<String, dynamic>> whatArr = [];

  @override
  void initState() {
    super.initState();
    _loadCategoryWorkouts();
  }

  Future<void> _loadCategoryWorkouts() async {
    List<Map<String, dynamic>> workouts = await _workoutService.fetchCategoryWorkoutList();
    setState(() {
      whatArr = workouts;
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
                "Workout List",
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
                      itemCount: whatArr.length,
                      itemBuilder: (context, index) {
                        var wObj = whatArr[index] as Map? ?? {};
                        return InkWell(
                            child:  WhatTrainRow(wObj: wObj) );
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
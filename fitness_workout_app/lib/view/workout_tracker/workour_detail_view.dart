import 'package:fitness_workout_app/common/colo_extension.dart';
import 'package:fitness_workout_app/common_widget/icon_title_next_row.dart';
import 'package:fitness_workout_app/common_widget/round_button.dart';
import 'package:fitness_workout_app/view/workout_tracker/exercises_step_details.dart';
import 'package:fitness_workout_app/view/workout_tracker/ready_view.dart';
import 'package:fitness_workout_app/view/workout_tracker/workout_schedule_view.dart';
import 'package:flutter/material.dart';

import '../../common_widget/exercises_row.dart';
import '../../common_widget/exercises_set_section.dart';
import '../../model/exercise_model.dart';
import '../../services/category_workout.dart';

class WorkoutDetailView extends StatefulWidget {
  final Map dObj;
  const WorkoutDetailView({super.key, required this.dObj});

  @override
  State<WorkoutDetailView> createState() => _WorkoutDetailViewState();
}

class _WorkoutDetailViewState extends State<WorkoutDetailView> {
  final TextEditingController selectedDifficulity = TextEditingController();
  final WorkoutService _workoutService = WorkoutService();
  List<Map<String, dynamic>> youArr = [];
  String selectedDiffDefault = "Beginner";

  List latestArr = [
    {
      "image": "assets/img/Workout1.png",
      "title": "Full body Workout",
      "time": "Today, 03:00pm"
    },
    {
      "image": "assets/img/Workout2.png",
      "title": "Upperbody Workout",
      "time": "June 05, 02:00pm"
    },
  ];

  List<Exercise> exercisesArr = [];

  @override
  void initState() {
    super.initState();
    _loadToolOfCategoryWorkout();
    selectedDifficulity.text = selectedDiffDefault;
    _loadExercises();
  }

  void _loadToolOfCategoryWorkout() async {
    String categoryId = widget.dObj["id"].toString();
    List<Map<String, dynamic>> tools = await _workoutService.fetchToolsForCategory(categoryId);
    setState(() {
      youArr = tools;
    });
  }

  void _loadExercises() async {
    String categoryId = widget.dObj["id"].toString();
    List<Exercise> exercises = await _workoutService
        .fetchExercisesByCategoryAndDifficulty(
      categoryId: categoryId,
      difficulty: selectedDifficulity.text.trim(),
    );
    setState(() {
      exercisesArr = exercises;
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
            ),
            SliverAppBar(
              backgroundColor: Colors.transparent,
              centerTitle: true,
              elevation: 0,
              leadingWidth: 0,
              leading: Container(),
              expandedHeight: media.width * 0.5,
              flexibleSpace: Align(
                alignment: Alignment.center,
                child: Image.network(
                  widget.dObj["image"].toString(),
                  width: media.width * 0.75,
                  height: media.width * 0.8,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.error,
                      color: Colors.red,
                      size: 90,
                    );
                  },
                ),
              ),
            ),
          ];
        },
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
              color: TColor.white,
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(25), topRight: Radius.circular(25))),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Stack(
              children: [
                SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      Container(
                        width: 50,
                        height: 4,
                        decoration: BoxDecoration(
                            color: TColor.gray.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(3)),
                      ),
                      SizedBox(
                        height: media.width * 0.05,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.dObj["title"].toString(),
                                  style: TextStyle(
                                      color: TColor.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700),
                                ),
                                Text(
                                  "${widget.dObj["exercises"].toString()} | ${widget.dObj["time"].toString()} | ${widget.dObj["calo"].toString()}",
                                  style: TextStyle(
                                      color: TColor.gray, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: media.width * 0.05,
                      ),
                      Container(
                        decoration: BoxDecoration(
                            color: TColor.secondaryColor2.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(15)),
                        child: Row(
                          children: [
                            Container(
                              alignment: Alignment.center,
                              width: 50,
                              height: 50,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 15),
                              child: Image.asset(
                                "assets/img/difficulity.png",
                                width: 20,
                                height: 20,
                                fit: BoxFit.contain,
                                color: TColor.gray,
                              ),
                            ),

                            Expanded(
                              child: TextField(
                                controller: selectedDifficulity,
                                readOnly: true,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: TColor.black,
                                ),
                                decoration: InputDecoration(
                                  hintText: "Difficulity",
                                  hintStyle: TextStyle(
                                      color: TColor.gray, fontSize: 12),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),

                            DropdownButtonHideUnderline(
                              child: DropdownButton(
                                items: ["Beginner", "Normal", "Professional"]
                                    .map((name) =>
                                    DropdownMenuItem(
                                      value: name,
                                      child: Text(
                                        name,
                                        style: TextStyle(
                                            color: TColor.gray, fontSize: 12),
                                      ),
                                    )).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    selectedDifficulity.text = value.toString();
                                    _loadExercises();
                                  });
                                },
                                icon: Icon(Icons.arrow_drop_down,
                                    color: TColor.gray),
                                isExpanded: false,
                              ),
                            ),

                            const SizedBox(width: 8),
                          ],
                        ),),
                      SizedBox(
                        height: media.width * 0.02,
                      ),
                      IconTitleNextRow(
                          icon: "assets/img/time.png",
                          title: "Schedule Workout",
                          time: "Add to Schedule",
                          color: TColor.primaryColor2.withOpacity(0.3),
                          onPressed: () {

                            Navigator.push(context, MaterialPageRoute(builder: (context) => const WorkoutScheduleView() )  );
                          }),
                      SizedBox(
                        height: media.width * 0.05,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "You'll Need",
                            style: TextStyle(
                                color: TColor.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w700),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: Text(
                              "${youArr.length} Items",
                              style:
                              TextStyle(color: TColor.gray, fontSize: 12),
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: media.width * 0.5,
                        child: ListView.builder(
                            padding: EdgeInsets.zero,
                            scrollDirection: Axis.horizontal,
                            shrinkWrap: true,
                            itemCount: youArr.length,
                            itemBuilder: (context, index) {
                              var yObj = youArr[index] as Map? ?? {};
                              return Container(
                                  margin: const EdgeInsets.all(8),
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        height: media.width * 0.35,
                                        width: media.width * 0.35,
                                        decoration: BoxDecoration(
                                            color: TColor.lightGray,
                                            borderRadius:
                                            BorderRadius.circular(15)),
                                        alignment: Alignment.center,
                                        child: Image.network(
                                          yObj["image"].toString(),
                                          width: media.width * 0.2,
                                          height: media.width * 0.2,
                                          fit: BoxFit.contain,
                                          loadingBuilder: (context, child, loadingProgress) {
                                            if (loadingProgress == null) return child;
                                            return Center(
                                              child: CircularProgressIndicator(
                                                value: loadingProgress.expectedTotalBytes != null
                                                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                                    : null,
                                              ),
                                            );
                                          },
                                          errorBuilder: (context, error, stackTrace) {
                                            return Icon(
                                              Icons.error,
                                              color: Colors.red,
                                              size: 90,
                                            );
                                          },
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          yObj["title"].toString(),
                                          style: TextStyle(
                                              color: TColor.black,
                                              fontSize: 12),
                                        ),
                                      )
                                    ],
                                  ));
                            }),
                      ),
                      SizedBox(
                        height: media.width * 0.05,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Exercises",
                            style: TextStyle(
                                color: TColor.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w700),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: Text(
                                "${exercisesArr.length.toString()} Exercises",
                              style:
                              TextStyle(color: TColor.gray, fontSize: 12),
                            ),
                          )
                        ],
                      ),
                      ListView.builder(
                        padding: EdgeInsets.zero,
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: exercisesArr.length,
                        itemBuilder: (context, index) {
                          Exercise eObj = exercisesArr[index];
                          return ExercisesRow(
                            eObj: eObj,
                          );
                        },
                      ),
                      SizedBox(
                        height: media.width * 0.1,
                      ),
                    ],
                  ),
                ),
                SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      RoundButton(title: "Start Workout", onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ReadyView(exercises: exercisesArr),
                          ),
                        );
                      })
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
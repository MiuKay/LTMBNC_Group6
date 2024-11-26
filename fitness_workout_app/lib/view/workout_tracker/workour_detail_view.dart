import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness_workout_app/common/colo_extension.dart';
import 'package:fitness_workout_app/common_widget/icon_title_next_row.dart';
import 'package:fitness_workout_app/common_widget/round_button.dart';
import 'package:fitness_workout_app/view/workout_tracker/ready_view.dart';
import 'package:fitness_workout_app/view/workout_tracker/workout_schedule_view.dart';
import 'package:flutter/material.dart';

import '../../common_widget/exercises_row.dart';
import '../../model/exercise_model.dart';
import '../../model/user_model.dart';
import '../../services/auth.dart';
import '../../services/workout_tracker.dart';
import '../main_tab/main_tab_view.dart';

class WorkoutDetailView extends StatefulWidget {
  final Map dObj;
  const WorkoutDetailView({super.key, required this.dObj});

  @override
  State<WorkoutDetailView> createState() => _WorkoutDetailViewState();
}

class _WorkoutDetailViewState extends State<WorkoutDetailView> {
  final TextEditingController selectedDifficulty = TextEditingController();
  final WorkoutService _workoutService = WorkoutService();
  List<Map<String, dynamic>> youArr = [];
  List<Exercise> exercisesArr = [];
  Map<String, String> listInfo = {};

  @override
  void initState() {
    super.initState();
    _loadToolOfCategoryWorkout();
    selectedDifficulty.text = widget.dObj["difficulty"];
    _loadExercises();
    _loadCaloAndTime();
  }

  void _loadToolOfCategoryWorkout() async {
    String categoryId = widget.dObj["id"].toString();
    List<Map<String, dynamic>> tools = await _workoutService
        .fetchToolsForCategory(categoryId);
    setState(() {
      youArr = tools;
    });
  }

  void _loadCaloAndTime() async {
    String categoryId = widget.dObj["id"].toString();
    Map<String, String> list = await _workoutService.fetchTimeAndCalo(
      categoryId: categoryId,
      difficulty: selectedDifficulty.text.trim(),
    );
    setState(() {
      listInfo = list;
    });
  }

  void _loadExercises() async {
    String categoryId = widget.dObj["id"].toString();
    List<Exercise> exercises = await _workoutService
        .fetchExercisesByCategoryAndDifficulty(
      categoryId: categoryId,
      difficulty: selectedDifficulty.text.trim(),
    );
    setState(() {
      exercisesArr = exercises;
    });
  }

  void _showDifficultySelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: ["Beginner", "Normal", "Professional"].map((difficulty) {
              return ListTile(
                title: Text(
                  difficulty,
                  style: TextStyle(color: TColor.gray, fontSize: 14),
                ),
                onTap: () {
                  setState(() {
                    selectedDifficulty.text = difficulty;
                    _loadExercises();
                    _loadCaloAndTime();
                  });
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void getUserInfo() async {
    try {
      // Lấy thông tin người dùng
      UserModel? user = await AuthService().getUserInfo(
          FirebaseAuth.instance.currentUser!.uid);

      if (user != null) {
        // Điều hướng đến HomeView với user
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MainTabView(user: user, initialTab: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Có lỗi xảy ra')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi xảy ra: $e')),
      );
    }
  }

  void _createHistory() async {
    // Tạo một WorkoutHistory rỗng
    String historyId = await _workoutService.createEmptyWorkoutHistory(
      uid: FirebaseAuth.instance.currentUser!.uid,
      idCate: widget.dObj["id"].toString(),
      exercisesArr: exercisesArr,
      difficulty: selectedDifficulty.text,
    );

    // Chuyển sang trang ReadyView
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReadyView(
          exercises: exercisesArr,
          historyId: historyId,
          index: 0,// Truyền Id để cập nhật sau
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery
        .of(context)
        .size;
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
                            ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
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
                                  "${exercisesArr.length
                                      .toString()} Exercises | ${listInfo["time"]
                                      .toString()} | ${listInfo["calo"]
                                      .toString()}",
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
                      InkWell(
                        onTap: () {
                          _showDifficultySelector(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 15),
                          decoration: BoxDecoration(
                            color: TColor.primary,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 30,
                                height: 30,
                                alignment: Alignment.center,
                                child: Image.asset(
                                  "assets/img/difficulity.png",
                                  width: 16,
                                  height: 16,
                                  fit: BoxFit.contain,
                                ),
                              ),

                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  "Difficulty",
                                  style: TextStyle(
                                      color: TColor.gray, fontSize: 12),
                                ),
                              ),

                              SizedBox(
                                width: 120,
                                child: Text(
                                  selectedDifficulty.text,
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                      color: TColor.gray, fontSize: 12),
                                ),
                              ),

                              // Icon hiển thị ở bên phải
                              Container(
                                width: 25,
                                height: 25,
                                alignment: Alignment.center,
                                child: Image.asset(
                                  "assets/img/p_next.png",
                                  width: 12,
                                  height: 12,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),


                      SizedBox(
                        height: media.width * 0.02,
                      ),
                      IconTitleNextRow(
                          icon: "assets/img/time.png",
                          title: "Schedule Workout",
                          time: "Add to Schedule",
                          color: TColor.primaryColor2.withOpacity(0.3),
                          onPressed: getUserInfo
                      ),
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
                                          loadingBuilder: (context, child,
                                              loadingProgress) {
                                            if (loadingProgress == null)
                                              return child;
                                            return Center(
                                              child: CircularProgressIndicator(
                                                value: loadingProgress
                                                    .expectedTotalBytes != null
                                                    ? loadingProgress
                                                    .cumulativeBytesLoaded /
                                                    loadingProgress
                                                        .expectedTotalBytes!
                                                    : null,
                                              ),
                                            );
                                          },
                                          errorBuilder: (context, error,
                                              stackTrace) {
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
                      RoundButton(title: "Start Workout",
                          onPressed: _createHistory
                      )
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
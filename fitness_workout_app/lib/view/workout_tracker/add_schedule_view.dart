import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness_workout_app/view/workout_tracker/select_workout_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../common/colo_extension.dart';
import '../../common/common.dart';
import '../../common_widget/icon_title_next_row.dart';
import '../../common_widget/repetition_row.dart';
import '../../common_widget/round_button.dart';
import '../../services/workout_tracker.dart';

class AddScheduleView extends StatefulWidget {
  final DateTime date;
  const AddScheduleView({super.key, required this.date});

  @override
  State<AddScheduleView> createState() => _AddScheduleViewState();
}

class _AddScheduleViewState extends State<AddScheduleView> {
  final WorkoutService _workoutService = WorkoutService();
  final TextEditingController selectedDifficulty = TextEditingController();
  final TextEditingController selectedWorkout = TextEditingController();
  final TextEditingController selectedRepetition = TextEditingController();
  String day = "";
  String hour = "";
  bool isLoading = false;
  bool isNotificationEnabled = true;

  @override
  void initState() {
    super.initState();
    selectedRepetition.text = "no";
    day = dateToString(widget.date, formatStr: "d/M/yyyy");
    hour = dateToString(DateTime.now(), formatStr: "h:mm a");
  }

  @override
  void dispose() {
    super.dispose();
    selectedDifficulty.dispose();
    selectedWorkout.dispose();
    selectedRepetition.dispose();
  }

  void _onTimeChanged(DateTime newDate) {
    setState(() {
      // Lấy giờ và phút từ DateTime và định dạng lại
      hour = DateFormat('h:mm a').format(newDate);
      ;
    });
  }

  void _handleAddSchedule() async {
    try {
      setState(() {
        isLoading = true;
      });
      String uid = FirebaseAuth.instance.currentUser!.uid;
      String res = await _workoutService.addWorkoutSchedule(
          day: day,
          difficulty: selectedDifficulty.text.trim(),
          hour: hour,
          name: selectedWorkout.text.trim(),
          repeatInterval: selectedRepetition.text.trim(),
          uid: uid,
          notify: isNotificationEnabled);


      if (res == "success") {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Workout schedule added successfully')));

        Navigator.pop(context, true);

        setState(() {
          isLoading = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$res')),);
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi xảy ra: $e')),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showDifficultySelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: ["Beginner", "Normal", "Professional"].map((
                difficulty) {
              return ListTile(
                title: Text(
                  difficulty,
                  style: TextStyle(color: TColor.gray, fontSize: 14),
                ),
                onTap: () {
                  setState(() {
                    selectedDifficulty.text = difficulty;
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

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery
        .of(context)
        .size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: TColor.white,
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
              "assets/img/closed_btn.png",
              width: 15,
              height: 15,
              fit: BoxFit.contain,
            ),
          ),
        ),
        title: Text(
          "Add Schedule",
          style: TextStyle(
              color: TColor.black, fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      backgroundColor: TColor.white,
      body: Stack(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(
                children: [
                  Image.asset(
                    "assets/img/date.png",
                    width: 21,
                    height: 21,
                  ),
                  const SizedBox(
                    width: 12,
                  ),
                  Text(
                    dateToString(widget.date, formatStr: "E, dd MMMM yyyy"),
                    style: TextStyle(color: TColor.gray, fontSize: 15),
                  ),
                ],
              ),
              SizedBox(
                height: media.width * 0.04,
              ),
              Text(
                "Time",
                style: TextStyle(
                    color: TColor.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w500),
              ),
              SizedBox(
                height: media.width * 0.35,
                child: CupertinoDatePicker(
                  onDateTimeChanged: _onTimeChanged,
                  initialDateTime: DateTime.now(),
                  use24hFormat: false,
                  minuteInterval: 1,
                  mode: CupertinoDatePickerMode.time,
                ),
              ),
              SizedBox(
                height: media.width * 0.06,
              ),
              Text(
                "Details Workout",
                style: TextStyle(
                    color: TColor.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w500),
              ),
              SizedBox(
                height: media.width * 0.03,
              ),
              IconTitleNextRow(
                icon: "assets/img/choose_workout.png",
                title: "Choose Workout",
                time: selectedWorkout.text,
                color: TColor.lightGray,
                onPressed: () async {
                  // Chuyển sang trang SelectWorkoutView và chờ kết quả
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SelectWorkoutView()),
                  );
                  if (result != null && result is String) {
                    setState(() {
                      selectedWorkout.text = result;
                    });
                  }
                },
              ),
              SizedBox(
                height: media.width * 0.03,
              ),
              InkWell(
                onTap: () {
                  _showDifficultySelector(context);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 8, horizontal: 15),
                  decoration: BoxDecoration(
                    color: TColor.lightGray,
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
                          style: TextStyle(color: TColor.gray, fontSize: 12),
                        ),
                      ),

                      SizedBox(
                        width: 120,
                        child: Text(
                          selectedDifficulty.text,
                          textAlign: TextAlign.right,
                          style: TextStyle(color: TColor.gray, fontSize: 12),
                        ),
                      ),

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
                height: media.width * 0.03,
              ),
              RepetitionsRow(
                icon: "assets/img/repetitions.png",
                title: "Custom Repetitions",
                color: TColor.lightGray,
                repetitionController: selectedRepetition,
              ),
              SizedBox(
                height: media.width * 0.03,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Enable Notifications",
                    style: TextStyle(
                      color: TColor.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Switch(
                    value: isNotificationEnabled,
                    activeColor: TColor.primaryColor1,
                    onChanged: (value) {
                      setState(() {
                        isNotificationEnabled = value;
                      });
                    },
                  ),
                ],
              ),

              Spacer(),
              RoundButton(
                  title: "Save",
                  onPressed: _handleAddSchedule),
              const SizedBox(
                height: 20,
              ),
            ]),
          ),
          if (isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
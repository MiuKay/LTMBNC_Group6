import 'package:fitness_workout_app/view/workout_tracker/select_workout_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../common/colo_extension.dart';
import '../../common/common.dart';
import '../../common_widget/icon_title_next_row.dart';
import '../../common_widget/repetition_row.dart';
import '../../common_widget/round_button.dart';

class AddScheduleView extends StatefulWidget {
  final DateTime date;
  const AddScheduleView({super.key, required this.date});

  @override
  State<AddScheduleView> createState() => _AddScheduleViewState();
}

class _AddScheduleViewState extends State<AddScheduleView> {
  final TextEditingController selectedDifficulty = TextEditingController();
  final TextEditingController selectedWorkout = TextEditingController();
  final TextEditingController selectedRepetition = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedRepetition.text = "no";
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery
        .of(context)
        .size;

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
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
          const SizedBox(
            height: 20,
          ),
          Text(
            "Time",
            style: TextStyle(
                color: TColor.black, fontSize: 15, fontWeight: FontWeight.w500),
          ),
          SizedBox(
            height: media.width * 0.35,
            child: CupertinoDatePicker(
              onDateTimeChanged: (newDate) {},
              initialDateTime: DateTime.now(),
              use24hFormat: false,
              minuteInterval: 1,
              mode: CupertinoDatePickerMode.time,
            ),
          ),
          const SizedBox(
            height: 24,
          ),
          Text(
            "Details Workout",
            style: TextStyle(
                color: TColor.black, fontSize: 15, fontWeight: FontWeight.w500),
          ),
          const SizedBox(
            height: 10,
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
          const SizedBox(
            height: 12,
          ),
          InkWell(
            onTap: () {
              _showDifficultySelector(context);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
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

          const SizedBox(
            height: 12,
          ),
          RepetitionsRow(
            icon: "assets/img/repetitions.png",
            title: "Custom Repetitions",
            color: TColor.lightGray,
            repetitionController: selectedRepetition,
          ),

          Spacer(),
          RoundButton(title: "Save", onPressed: () {}),
          const SizedBox(
            height: 20,
          ),
        ]),
      ),
    );
  }
}
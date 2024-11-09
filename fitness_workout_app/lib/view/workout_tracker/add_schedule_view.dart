import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../common/colo_extension.dart';
import '../../common/common.dart';
import '../../common_widget/icon_title_next_row.dart';
import '../../common_widget/round_button.dart';

class AddScheduleView extends StatefulWidget {
  final DateTime date;
  const AddScheduleView({super.key, required this.date});

  @override
  State<AddScheduleView> createState() => _AddScheduleViewState();
}

class _AddScheduleViewState extends State<AddScheduleView> {
  final TextEditingController selectedDifficulty = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

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
              time: "Upperbody",
              color: TColor.lightGray,
              onPressed: () {}),
          const SizedBox(
            height: 12,
          ),
          Container(
            decoration: BoxDecoration(
                color: TColor.lightGray,
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
                    width: 18,
                    height: 18,
                    fit: BoxFit.contain,
                    color: TColor.gray,
                  ),
                ),

                Expanded(
                  child: TextField(
                    controller: selectedDifficulty,
                    readOnly: true,
                    style: TextStyle(
                      fontSize: 16,
                      color: TColor.black,
                    ),
                    decoration: InputDecoration(
                      hintText: "Difficulty",
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
                            style: TextStyle(color: TColor.gray,
                                fontSize: 14),
                          ),
                        )).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedDifficulty.text = value.toString();
                      });
                    },
                    icon: SizedBox(
                      width: 25,
                      height: 25,
                      child:  Container(
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
                    ),
                    isExpanded: false,
                  ),
                ),

                const SizedBox(width: 8),
              ],
            ),),
          const SizedBox(
            height: 12,
          ),
          IconTitleNextRow(
              icon: "assets/img/repetitions.png",
              title: "Custom Repetitions",
              time: "",
              color: TColor.lightGray,
              onPressed: () {}),
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
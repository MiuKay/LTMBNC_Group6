import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:fitness_workout_app/common/colo_extension.dart';
import 'package:flutter/material.dart';

import '../model/workout_schedule_model.dart';
import '../view/workout_tracker/edit_schedule_view.dart';

class UpcomingWorkoutRow extends StatefulWidget {
  final WorkoutSchedule wObj;
  final VoidCallback onRefresh; // Định nghĩa onRefresh đúng kiểu

  const UpcomingWorkoutRow({
    Key? key,
    required this.wObj,
    required this.onRefresh,
  }) : super(key: key);

  @override
  State<UpcomingWorkoutRow> createState() => _UpcomingWorkoutRowState();
}

class _UpcomingWorkoutRowState extends State<UpcomingWorkoutRow> {
  bool positive = true;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EditScheduleView(schedule: widget.wObj),
          ),
        );
        if (result == true) {
          widget.onRefresh();
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: TColor.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Image.network(
                widget.wObj.pic.toString(),  // Đây là URL của ảnh từ mạng
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                  if (loadingProgress == null) {
                    return child; // Hiển thị ảnh khi tải xong
                  } else {
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                            (loadingProgress.expectedTotalBytes ?? 1)
                            : null,
                      ),
                    );
                  }
                },
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.wObj.name.toString(),
                    style: TextStyle(
                      color: TColor.black,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    widget.wObj.repeatInterval.toString() == "Everyday"
                        ? "Everyday"
                        : widget.wObj.repeatInterval.contains(",")
                        ? "Repeat: ${widget.wObj.repeatInterval
                            .split(",")
                            .map((day) {
                          // Chuyển đổi tên ngày thành số thứ tự (nếu cần)
                          switch (day) {
                            case "Monday":
                              return "2";
                            case "Tuesday":
                              return "3";
                            case "Wednesday":
                              return "4";
                            case "Thursday":
                              return "5";
                            case "Friday":
                              return "6";
                            case "Saturday":
                              return "7";
                            case "Sunday":
                              return "CN";
                            default:
                              return day;
                          }
                        })
                            .join(",")}"
                        : widget.wObj.day.toString(),
                    style: TextStyle(
                      color: TColor.gray,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    widget.wObj.hour.toString(),
                    style: TextStyle(
                      color: TColor.gray,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            AbsorbPointer(
              absorbing: true,
              child: SizedBox(
                height: 40,
                child: Transform.scale(
                  scale: 0.8,
                  child: CustomAnimatedToggleSwitch<bool>(
                    current: widget.wObj.notify,
                    values: [false, true],
                    indicatorSize: Size.square(40.0),
                    animationDuration: const Duration(milliseconds: 200),
                    animationCurve: Curves.linear,
                    onChanged: (b) => setState(() => positive = b),
                    iconBuilder: (context, local, global) {
                      return const SizedBox();
                    },
                    iconsTappable: true,
                    wrapperBuilder: (context, global, child) {
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          Positioned(
                            left: 15.0,
                            right: 15.0,
                            height: 40.0,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(colors: TColor.thirdG),
                                borderRadius:
                                const BorderRadius.all(Radius.circular(50.0)),
                              ),
                            ),
                          ),
                          child,
                        ],
                      );
                    },
                    foregroundIndicatorBuilder: (context, global) {
                      return SizedBox.fromSize(
                        size: const Size(20, 20),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: TColor.white,
                            borderRadius:
                            const BorderRadius.all(Radius.circular(25.0)),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black38,
                                spreadRadius: 0.1,
                                blurRadius: 2.0,
                                offset: Offset(0.0, 1.0),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

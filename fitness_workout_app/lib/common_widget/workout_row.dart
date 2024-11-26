import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitness_workout_app/common/colo_extension.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:simple_animation_progress_bar/simple_animation_progress_bar.dart';

import '../view/workout_tracker/ready_view.dart';

class WorkoutRow extends StatelessWidget {
  final Map wObj;
  const WorkoutRow({super.key, required this.wObj});

  String formatCompletedAt(Timestamp timestamp) {
    try {
      // Chuyển đổi Timestamp thành DateTime
      DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(
          timestamp.seconds * 1000 + timestamp.nanoseconds ~/ 1000000);

      // Định dạng DateTime theo yêu cầu
      String formattedDate = DateFormat('dd/MM/yyyy').format(dateTime);
      String formattedTime = DateFormat('hh:mm a').format(dateTime);

      // Kết hợp ngày và giờ
      return '$formattedDate at $formattedTime';
    } catch (e) {
      return 'Invalid timestamp';
    }
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
        padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 25),
        decoration: BoxDecoration(
            color: TColor.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)]),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Image.network(
                wObj["image"].toString(),
                width: 60,
                height: 60,
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
                    size: 60,
                  );
                },
              ),
            ),

            const SizedBox(width: 15,),
            Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      wObj["name"].toString(),
                      style: TextStyle(
                          color: TColor.black,
                          fontSize: 13),
                    ),
                    const SizedBox(height: 1,),
                    Text(
                      "${ (wObj["index"] + 1).toString() }/${ wObj["exercisesArr"].length.toString() } Ex | "
                          "${ wObj["calo"].toString() } Calo Burned | ${wObj["time"].toStringAsFixed(2)} Mins",
                      style: TextStyle(
                        color: TColor.gray,
                        fontSize: 11,),
                    ),
                    const SizedBox(height: 1,),
                    Text(
                      formatCompletedAt(wObj["completedAt"]),
                      style: TextStyle(
                        color: TColor.gray,
                        fontSize: 11,),
                    ),

                    const SizedBox(height: 5,),

                    SimpleAnimationProgressBar(
                      height: 15,
                      width: media.width * 0.5,
                      backgroundColor: Colors.grey.shade100,
                      foregrondColor: Colors.purple,
                      ratio: wObj["progress"] as double? ?? 0.0,
                      direction: Axis.horizontal,
                      curve: Curves.fastLinearToSlowEaseIn,
                      duration: const Duration(seconds: 3),
                      borderRadius: BorderRadius.circular(7.5),
                      gradientColor: LinearGradient(
                          colors: TColor.primaryG,
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight),
                    ),

                  ],
                )),
            IconButton(
                onPressed: () {
                  // Kiểm tra xem người dùng đã hoàn thành bài tập chưa
                  if (wObj["exercisesArr"].length - 1 == wObj["index"]) {
                    // Hiện thông báo bạn đã hoàn thành bài tập
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("Hoàn thành"),
                        content:
                        const Text("Bạn đã hoàn thành toàn bộ bài tập!"),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text("OK"),
                          ),
                        ],
                      ),
                    );
                  } else {
                    // Hiện thông báo bạn muốn tiếp tục bài tập này không
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("Tiếp tục bài tập"),
                        content: const Text("Bạn muốn tiếp tục bài tập này không?"),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text("Không"),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(); // Đóng dialog
                              // Điều hướng đến màn hình ReadyView
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ReadyView(
                                    exercises: wObj["exercisesArr"],
                                    historyId: wObj["id"],
                                    index: wObj["index"],
                                  ),
                                ),
                              );
                            },
                            child: const Text("Có"),
                          ),
                        ],
                      ),
                    );
                  }
                },
                icon: Image.asset(
                  "assets/img/next_icon.png",
                  width: 30,
                  height: 30,
                  fit: BoxFit.contain,
                ))
          ],
        ));
  }
}
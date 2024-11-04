import 'package:fitness_workout_app/common/colo_extension.dart';
import 'package:flutter/material.dart';

import '../model/exercise_model.dart';
import '../view/workout_tracker/exercises_step_details.dart';

class ExercisesRow extends StatelessWidget {
  final Exercise eObj;
  const ExercisesRow({super.key, required this.eObj});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: Image.network( // Đổi sang Image.network để load ảnh từ URL
              eObj.pic, // Sử dụng `eObj.pic` thay vì `eObj["image"]`
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    eObj.name, // Sử dụng `eObj.name` thay vì `eObj["title"]`
                    style: TextStyle(color: TColor.black, fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    eObj.rep == 0
                        ? "${eObj.time} sec | ${eObj.calo} cal" // Hiển thị thời gian và calo nếu rep là 0
                        : "${eObj.rep}x | ${eObj.calo} cal", // Hiển thị rep và calo nếu rep khác 0
                    style: TextStyle(color: TColor.gray, fontSize: 12),
                  ),
                ],
              )),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ExercisesStepDetails(eObj: eObj), // Truyền eObj vào trang chi tiết
                ),
              );
            },
            icon: Image.asset(
              "assets/img/next_go.png",
              width: 20,
              height: 20,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}

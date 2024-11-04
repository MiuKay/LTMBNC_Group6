import 'package:dotted_dashed_line/dotted_dashed_line.dart';
import 'package:fitness_workout_app/model/step_exercise_model.dart';
import 'package:flutter/material.dart';
import 'package:readmore/readmore.dart';

import '../common/colo_extension.dart';

class StepDetailRow extends StatelessWidget {
  final StepExercise sObj;
  final bool isLast;
  const StepDetailRow({super.key, required this.sObj, this.isLast = false});

  @override
  Widget build(BuildContext context) {

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 25,
          child: Text(
            sObj.step.toString(),
            style: TextStyle(
              color: TColor.secondaryColor1,
              fontSize: 14,
            ),
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(

              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: TColor.secondaryColor1,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Container(

                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  border: Border.all(color: TColor.white, width: 3),
                  borderRadius: BorderRadius.circular(9),
                ),) ,
            ),
            if (!isLast)
              DottedDashedLine(
                  height: 80,
                  width: 0,
                  dashColor: TColor.secondaryColor1,
                  axis: Axis.vertical)
          ],
        ),
        const SizedBox(
          width: 10,
        ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                sObj.title.toString(),
                style: TextStyle(
                  color: TColor.black,
                  fontSize: 14,
                ),
              ),
              ReadMoreText(
                sObj.detail.toString(),
                trimLines: 3,
                colorClickableText: TColor.black,
                trimMode: TrimMode.Line,
                trimCollapsedText: ' Read More ...',
                trimExpandedText: ' Read Less',
                style: TextStyle(
                  color: TColor.gray,
                  fontSize: 12,
                ),
                moreStyle:
                const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        )
      ],
    );
  }
}
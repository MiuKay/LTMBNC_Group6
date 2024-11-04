  // import 'dart:math';
  //
  // import 'package:flutter/material.dart';
  //
  // import '../common/colo_extension.dart';
  // import 'exercises_row.dart';
  //
  // class ExercisesSetSection extends StatelessWidget {
  // final Map sObj;
  // final Function(Map obj) onPressed;
  // const ExercisesSetSection ({super.key, required this.sObj, required this.onPressed});
  //
  // @override
  // Widget build(BuildContext context) {
  //   //var exercisesArr = sObj["set"] as List? ?? [];
  //
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     mainAxisSize: MainAxisSize.min,
  //     children: [
  //       ListView.builder(
  //           padding: EdgeInsets.zero,
  //           physics: const NeverScrollableScrollPhysics(),
  //           shrinkWrap: true,
  //           itemCount: sObj.length,
  //           itemBuilder: (context, index) {
  //             var eObj = sObj[index] as Map? ?? {};
  //             return ExercisesRow(eObj: eObj, onPressed: (){
  //               onPressed(eObj);
  //             },);
  //           }),
  //     ],
  //   );
  // }
  // }
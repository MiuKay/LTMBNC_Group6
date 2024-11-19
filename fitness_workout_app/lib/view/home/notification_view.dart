import 'package:flutter/material.dart';

import '../../common/colo_extension.dart';
import '../../common_widget/notification_row.dart';

class NotificationView extends StatefulWidget {
  const NotificationView({super.key});
  static const route = '/notification-screen';

  @override
  State<NotificationView> createState() => _NotificationViewState();
}

class _NotificationViewState extends State<NotificationView> {
  List notificationArr = [
    {"image": "assets/img/Workout1.png", "title": "Hey, it’s time for lunch", "time": "About 1 minutes ago"},
    {"image": "assets/img/Workout2.png", "title": "Don’t miss your lowerbody workout", "time": "About 3 hours ago"},
    {"image": "assets/img/Workout3.png", "title": "Hey, let’s add some meals for your b", "time": "About 3 hours ago"},
    {"image": "assets/img/Workout1.png", "title": "Congratulations, You have finished A..", "time": "29 May"},
    {"image": "assets/img/Workout2.png", "title": "Hey, it’s time for lunch", "time": "8 April"},
    {"image": "assets/img/Workout3.png", "title": "Ups, You have missed your Lowerbo...", "time": "8 April"},
  ];

  @override
  Widget build(BuildContext context) {
    final message = ModalRoute.of(context)!.settings.arguments;
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
              "assets/img/black_btn.png",
              width: 15,
              height: 15,
              fit: BoxFit.contain,
            ),
          ),
        ),
        title: Text(
          "Notification",
          style: TextStyle(
              color: TColor.black, fontSize: 22, fontWeight: FontWeight.w700),
        ),
      ),
      backgroundColor: TColor.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('${message}'),
          ],
        ),
      )
      // ListView.separated(
      //     padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
      //     itemBuilder: ((context, index) {
      //       var nObj = notificationArr[index] as Map? ?? {};
      //       return NotificationRow(nObj: nObj);
      //     }), separatorBuilder: (context, index){
      //   return Divider(color: TColor.gray.withOpacity(0.5), height: 1, );
      // }, itemCount: notificationArr.length),
    );
  }
}
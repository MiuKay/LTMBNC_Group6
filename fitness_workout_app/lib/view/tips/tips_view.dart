import 'package:fitness_workout_app/services/tips.dart';
import 'package:fitness_workout_app/view/tips/tips_details_view.dart';
import 'package:flutter/material.dart';

import '../../common/colo_extension.dart';
import '../../common_widget/tip_row.dart';
import '../../model/tip_model.dart';

class TipsView extends StatefulWidget {
  const TipsView({super.key});

  @override
  State<TipsView> createState() => _TipsViewState();
}

class _TipsViewState extends State<TipsView> {
  final TipsService _tipService = TipsService();
  List<Tip> tipArr = [];

  @override
  void initState() {
    super.initState();
    _loadTips();
  }

  void _loadTips() async {
    List<Tip> tips = await _tipService.fetchStips();
    setState(() {
      tipArr = tips;
    });
  }


  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.sizeOf(context);
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
          "Tips",
          style: TextStyle(
              color: TColor.black, fontSize: 22, fontWeight: FontWeight.w700),
        ),
      ),
      backgroundColor: TColor.white,
      body: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          itemBuilder: (context, index) {
            Tip tObj = tipArr[index];
            return TipRow(
              tObj: tObj,
              isActive: index == 0,
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => TipsDetailView( stipsObj: tObj) ));
              },
            );
          },
          separatorBuilder: (context, index) {
            return const Divider(
              color: Colors.black26,
              height: 1,
            );
          },
          itemCount: tipArr.length),
    );
  }
}
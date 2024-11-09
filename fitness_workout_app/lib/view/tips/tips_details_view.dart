import 'package:flutter/material.dart';

import '../../common/colo_extension.dart';
import '../../services/workout_tracker.dart';
import '../../model/tip_model.dart';

class TipsDetailView extends StatefulWidget {
  final Tip stipsObj;
  const TipsDetailView({super.key, required this.stipsObj});

  @override
  State<TipsDetailView> createState() => _TipsDetailViewState();
}

class _TipsDetailViewState extends State<TipsDetailView> {
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            widget.stipsObj.pic.isNotEmpty
                ? Image.network(
              widget.stipsObj.pic,
              width: media.width,
              height: media.width * 0.55,
              fit: BoxFit.contain, // Ensures the image fits without being cut off
              errorBuilder: (context, error, stackTrace) {
                // Display a placeholder image from URL if loading fails
                return Image.asset(
                    "assets/img/1.png",
                  width: media.width,
                  height: media.width * 0.55,
                  fit: BoxFit.contain,
                );
              },
            )
                : Image.asset(
              // Display a placeholder image if `pic` is empty
              "assets/img/1.png",
              width: media.width,
              height: media.width * 0.55,
              fit: BoxFit.contain,
            ),
            const SizedBox(
              height: 15,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      widget.stipsObj.name,
                      style: TextStyle(
                          color: TColor.secondaryText,
                          fontSize: 20,
                          fontWeight: FontWeight.w700),
                      maxLines: 2, // Giới hạn tối đa 2 dòng
                      overflow: TextOverflow.ellipsis, // Thêm dấu ba chấm nếu vượt quá
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                widget.stipsObj.detail,
                style: TextStyle(color: TColor.secondaryText, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

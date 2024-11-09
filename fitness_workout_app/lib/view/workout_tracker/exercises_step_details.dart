import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:readmore/readmore.dart';
import 'package:video_player/video_player.dart';

import '../../common/colo_extension.dart';
import '../../common_widget/step_detail_row.dart';
import '../../model/exercise_model.dart';
import '../../model/step_exercise_model.dart';
import '../../services/workout_tracker.dart';

class ExercisesStepDetails extends StatefulWidget {
  final Exercise eObj;
  const ExercisesStepDetails({super.key, required this.eObj});

  @override
  State<ExercisesStepDetails> createState() => _ExercisesStepDetailsState();
}

class _ExercisesStepDetailsState extends State<ExercisesStepDetails> {
  final WorkoutService _workoutService = WorkoutService();
  List<StepExercise> stepArr = [];
  late VideoPlayerController _controller;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _loadStepExercises();
    _controller = VideoPlayerController.network(widget.eObj.video)
      ..initialize().then((_) {
        setState(() {}); // Cập nhật UI sau khi video đã sẵn sàng
      });

    // Lắng nghe khi video kết thúc
    _controller.addListener(() {
      if (_controller.value.position == _controller.value.duration) {
        setState(() {
          _isPlaying = false; // Đặt lại trạng thái khi video kết thúc
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _loadStepExercises() async {
    String name = widget.eObj.name.toString();
    List<StepExercise> step_exercises = await _workoutService.fetchStepExercises(
      name: name,
    );
    setState(() {
      stepArr = step_exercises;
    });
  }

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
      ),
      backgroundColor: TColor.white,
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    if (_isPlaying) {
                      _controller.pause();
                    } else {
                      _controller.play();
                    }
                    _isPlaying = !_isPlaying; // Chuyển đổi trạng thái phát
                  });
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: media.width,
                      height: media.width * 0.43,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: TColor.primaryG),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: _controller.value.isInitialized
                          ? VideoPlayer(_controller)
                          : Center(child: CircularProgressIndicator()), // Hiển thị khi đang tải video
                    ),
                    // Không có lớp phủ ở đây
                    if (!_isPlaying) // Chỉ hiển thị biểu tượng khi video không đang phát
                      const Icon(
                        Icons.play_arrow,
                        size: 30,
                        color: Colors.white,
                      ),
                    if (_isPlaying && _controller.value.position < _controller.value.duration) // Hiện biểu tượng pause khi video đang phát
                      const Icon(
                        Icons.pause,
                        size: 30,
                        color: Colors.white,
                      ),
                  ],
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              Text(
                widget.eObj.name.toString(),
                style: TextStyle(
                    color: TColor.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w700),
              ),
              const SizedBox(
                height: 4,
              ),
              Text(
                "${widget.eObj.difficulty} | ${widget.eObj.calo} Calories Burn",
                style: TextStyle(
                  color: TColor.gray,
                  fontSize: 12,
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              Text(
                "Descriptions",
                style: TextStyle(
                    color: TColor.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w700),
              ),
              const SizedBox(
                height: 4,
              ),
              ReadMoreText(
                widget.eObj.descriptions.toString(),
                trimLines: 4,
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
              const SizedBox(
                height: 15,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "How To Do It",
                    style: TextStyle(
                        color: TColor.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w700),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      "${stepArr.length} Steps",
                      style: TextStyle(color: TColor.gray, fontSize: 12),
                    ),
                  )
                ],
              ),
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: stepArr.length,
                itemBuilder: ((context, index) {
                  StepExercise sObj = stepArr[index];

                  return StepDetailRow(
                    sObj: sObj,
                    isLast: stepArr.last == sObj,
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
import 'package:calendar_agenda/calendar_agenda.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness_workout_app/view/workout_tracker/workout_tracker_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../common/colo_extension.dart';
import '../../common/common.dart';
import '../../model/workout_schedule_model.dart';
import '../../services/workout_tracker.dart';
import 'add_schedule_view.dart';
import 'edit_schedule_view.dart';

class WorkoutScheduleView extends StatefulWidget {
  final Function? onScheduleAdded;
  const WorkoutScheduleView({
    super.key,
    this.onScheduleAdded,
  });

  @override
  State<WorkoutScheduleView> createState() => _WorkoutScheduleViewState();
}

class _WorkoutScheduleViewState extends State<WorkoutScheduleView> {
  CalendarAgendaController _calendarAgendaControllerAppBar = CalendarAgendaController();
  late DateTime _selectedDateAppBBar;
  final WorkoutService _workoutService = WorkoutService();
  List<Map<String, dynamic>> eventArr = [];
  List selectDayEventArr = [];

  @override
  void initState() {
    super.initState();
    _selectedDateAppBBar = DateTime.now();
    _loadWorkOutSchedule();
    _setDayEventWorkoutList();
  }

  void _loadWorkOutSchedule() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    List<Map<String, dynamic>> schedule = await _workoutService
        .fetchWorkoutSchedule(userId: uid);
    setState(() {
      eventArr = schedule;
    });
    _setDayEventWorkoutList();
  }

  void _setDayEventWorkoutList() {
    var date = dateToStartDate(_selectedDateAppBBar);
    selectDayEventArr = eventArr.map((wObj) {
      return {
        "name": wObj["name"],
        "start_time": wObj["start_time"],
        "id": wObj["id"],
        "date": stringToDate(wObj["start_time"].toString(),
            formatStr: "dd/MM/yyyy hh:mm aa")
      };
    }).where((wObj) {
      return dateToStartDate(wObj["date"] as DateTime) == date;
    }).toList();

    if (mounted) {
      setState(() {});
    }
  }

  void _confirmDeleteSchedule(String Id) async {
    // Hiển thị một hộp thoại xác nhận trước khi xoá
    bool? confirm = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text(
              'Are you sure you want to delete this workout schedule?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
    // Nếu người dùng xác nhận, gọi hàm xoá lịch bài tập
    if (confirm == true) {
      String res = await _workoutService.deleteWorkoutSchedule(scheduleId: Id);
      if (res == "success") {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Workout schedule deleted successfully')));

        // Tải lại danh sách lịch sau khi xoá thành công
        _loadWorkOutSchedule();
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$res')),);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery
        .of(context)
        .size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: TColor.white,
        centerTitle: true,
        elevation: 0,
        leadingWidth: 0,
        leading: const SizedBox(),
        title: Text(
          "Workout Schedule",
          style: TextStyle(
              color: TColor.black, fontSize: 22, fontWeight: FontWeight.w700),
        ),
      ),
      backgroundColor: TColor.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CalendarAgenda(
            controller: _calendarAgendaControllerAppBar,
            appbar: false,
            selectedDayPosition: SelectedDayPosition.center,
            leading: IconButton(
                onPressed: () {},
                icon: Image.asset(
                  "assets/img/ArrowLeft.png",
                  width: 15,
                  height: 15,
                )),
            training: IconButton(
                onPressed: () {},
                icon: Image.asset(
                  "assets/img/ArrowRight.png",
                  width: 15,
                  height: 15,
                )),
            weekDay: WeekDay.short,
            dayNameFontSize: 12,
            dayNumberFontSize: 16,
            dayBGColor: Colors.grey.withOpacity(0.15),
            titleSpaceBetween: 15,
            backgroundColor: Colors.transparent,
            // fullCalendar: false,
            fullCalendarScroll: FullCalendarScroll.horizontal,
            fullCalendarDay: WeekDay.short,
            selectedDateColor: Colors.white,
            dateColor: Colors.black,
            locale: 'en',

            initialDate: DateTime.now(),
            calendarEventColor: TColor.primaryColor2,
            firstDate: DateTime.now().subtract(const Duration(days: 140)),
            lastDate: DateTime.now().add(const Duration(days: 60)),

            onDateSelected: (date) {
              _selectedDateAppBBar = date;
              _setDayEventWorkoutList();
            },
            selectedDayLogo: Container(
              width: double.maxFinite,
              height: double.maxFinite,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: TColor.primaryG,
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter),
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: media.width * 1.5,
                child: ListView.separated(
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    var timelineDataWidth = (media.width * 1.5) - (80 + 40);
                    var availWidth = (media.width * 1.2) - (80 + 40);
                    var slotArr = selectDayEventArr.where((wObj) {
                      return (wObj["date"] as DateTime).hour == index;
                    }).toList();

                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      height: 40,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 80,
                            child: Text(
                              getTime(index * 60),
                              style: TextStyle(
                                color: TColor.black,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          if (slotArr.isNotEmpty)
                            Expanded(
                              child: Stack(
                                alignment: Alignment.centerLeft,
                                children: slotArr.map((sObj) {
                                  var min = (sObj["date"] as DateTime).minute;
                                  // (0 to 2)
                                  var pos = (min / 60) * 2 - 1;

                                  // Kiểm tra nếu ngày đã qua
                                  DateTime eventDate = sObj["date"] as DateTime;
                                  bool isEventPast = eventDate.isBefore(
                                      DateTime.now());

                                  // Kiểm tra điều kiện để vô hiệu hóa nút và gạch ngang
                                  bool shouldStrikethrough = isEventPast;

                                  return Align(
                                    alignment: Alignment(pos, 0),
                                    child: InkWell(
                                      onTap: () {
                                        if (!shouldStrikethrough) {
                                          showDialog(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                backgroundColor: Colors
                                                    .transparent,
                                                contentPadding: EdgeInsets.zero,
                                                content: Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 15,
                                                      horizontal: 20),
                                                  decoration: BoxDecoration(
                                                    color: TColor.white,
                                                    borderRadius: BorderRadius
                                                        .circular(20),
                                                  ),
                                                  child: Column(
                                                    mainAxisSize: MainAxisSize
                                                        .min,
                                                    crossAxisAlignment: CrossAxisAlignment
                                                        .start,
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment
                                                            .spaceBetween,
                                                        children: [
                                                          InkWell(
                                                            onTap: () {
                                                              Navigator.pop(
                                                                  context);
                                                            },
                                                            child: Container(
                                                              margin: const EdgeInsets
                                                                  .all(8),
                                                              height: 40,
                                                              width: 40,
                                                              alignment: Alignment
                                                                  .center,
                                                              decoration: BoxDecoration(
                                                                color: TColor
                                                                    .lightGray,
                                                                borderRadius: BorderRadius
                                                                    .circular(
                                                                    10),
                                                              ),
                                                              child: Image
                                                                  .asset(
                                                                "assets/img/closed_btn.png",
                                                                width: 15,
                                                                height: 15,
                                                                fit: BoxFit
                                                                    .contain,
                                                              ),
                                                            ),
                                                          ),
                                                          Text(
                                                            "Workout Schedule",
                                                            style: TextStyle(
                                                                color: TColor
                                                                    .black,
                                                                fontSize: 16,
                                                                fontWeight: FontWeight
                                                                    .w700),),

                                                          PopupMenuButton<String>(
                                                            icon: Container(
                                                              margin: const EdgeInsets.all(8),
                                                              height: 40,
                                                              width: 40,
                                                              alignment: Alignment.center,
                                                              decoration: BoxDecoration(
                                                                color: TColor.lightGray,
                                                                borderRadius: BorderRadius.circular(10),
                                                              ),
                                                              child: Image.asset(
                                                                "assets/img/more_btn.png",
                                                                width: 15,
                                                                height: 15,
                                                                fit: BoxFit
                                                                    .contain,
                                                              ),
                                                            ),
                                                            onSelected: (value) async {
                                                              if (value == 'edit') {
                                                                WorkoutSchedule schedule = await _workoutService
                                                                    .getWorkoutScheduleById(scheduleId: sObj["id"]);
                                                                final result = await Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                    builder: (context) => EditScheduleView(schedule: schedule,),
                                                                  ),
                                                                );
                                                                if (result == true) {
                                                                  _loadWorkOutSchedule();
                                                                  Navigator.pop(context);
                                                                }
                                                              } else
                                                              if (value == 'delete') {
                                                                print('Remove clicked');
                                                                _confirmDeleteSchedule(sObj["id"]);
                                                              }
                                                            },
                                                            itemBuilder: (BuildContext context) =>
                                                            <PopupMenuEntry<String>>[const PopupMenuItem<String>(
                                                                value: 'edit',
                                                                child: Text('Edit'),
                                                              ),
                                                              const PopupMenuItem<String>(
                                                                value: 'delete',
                                                                child: Text('Delete'),
                                                              ),
                                                            ],
                                                          )
                                                        ],
                                                      ),
                                                      const SizedBox(
                                                          height: 15),
                                                      Text(
                                                        sObj["name"].toString(),
                                                        style: TextStyle(
                                                            color: TColor.black,
                                                            fontSize: 14,
                                                            fontWeight: FontWeight
                                                                .w700),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Row(
                                                        children: [
                                                          Image.asset(
                                                            "assets/img/time_workout.png",
                                                            height: 20,
                                                            width: 20,
                                                          ),
                                                          const SizedBox(
                                                              width: 8),
                                                          Text(
                                                            "${getDayTitle(sObj["start_time"].toString())}|${getStringDateToOtherFormate(
                                                                sObj["start_time"].toString(), outFormatStr: "h:mm aa")}",
                                                            style: TextStyle(
                                                                color: TColor.gray,
                                                                fontSize: 12),
                                                          )
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          );
                                        }
                                      },
                                      child: Container(
                                        height: 35,
                                        width: availWidth * 0.55,
                                        padding: const EdgeInsets.symmetric(horizontal: 8),
                                        alignment: Alignment.centerLeft,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(colors: TColor.secondaryG),
                                          borderRadius: BorderRadius.circular(17.5),
                                        ),
                                        child: Text(
                                          "${sObj["name"]
                                              .toString()}, ${getStringDateToOtherFormate(
                                              sObj["start_time"].toString(),
                                              outFormatStr: "h:mm aa")}",
                                          maxLines: 1,
                                          style: TextStyle(
                                            color: TColor.white,
                                            fontSize: 12,
                                            decoration: shouldStrikethrough
                                                ? TextDecoration.lineThrough
                                                : null, // Gạch ngang nếu đã hoàn thành hoặc ngày đã qua
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            )
                        ],
                      ),
                    );
                  },
                  separatorBuilder: (context, index) {
                    return Divider(
                      color: TColor.gray.withOpacity(0.2),
                      height: 1,
                    );
                  },
                  itemCount: 24,
                ),
              ),
            ),
          )

        ],
      ),
      floatingActionButton: InkWell(
        onTap: () async {
          //print('Gio hien tai: $_selectedDateAppBBar');
          DateTime now = DateTime.now();
          DateTime startOfDay = DateTime(now.year, now.month, now.day);
          //print('Gio kiem tra: $startOfDay');
          // Kiểm tra nếu ngày được chọn là quá khứ so với thời gian hiện tại
          if (_selectedDateAppBBar.isBefore(startOfDay)) {
            return;
          }
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddScheduleView(
                date: _selectedDateAppBBar,
              ),
            ),
          );
          if (result == true) {
            _loadWorkOutSchedule();
          }
        },
        child: Container(
          width: 55,
          height: 55,
          decoration: BoxDecoration(
              gradient: LinearGradient(colors: TColor.secondaryG),
              borderRadius: BorderRadius.circular(27.5),
              boxShadow: const [
                BoxShadow(
                    color: Colors.black12, blurRadius: 5, offset: Offset(0, 2))
              ]
          ),
          alignment: Alignment.center,
          child: Icon(
            Icons.add,
            size: 20,
            color: TColor.white,
          ),
        ),
      ),
    );
  }
}
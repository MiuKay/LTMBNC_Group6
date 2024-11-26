import 'package:fitness_workout_app/common/colo_extension.dart';
import 'package:fitness_workout_app/common_widget/tab_button.dart';
import 'package:flutter/material.dart';
import 'package:fitness_workout_app/model/user_model.dart';
import '../profile/profile_view.dart';
import '../workout_tracker/all_workout_view.dart';
import '../workout_tracker/workout_schedule_view.dart';
import '../workout_tracker/workout_tracker_view.dart';

class MainTabView extends StatefulWidget {
  final UserModel user;
  final int initialTab;
  const MainTabView({super.key, required this.user, this.initialTab = 0});

  @override
  State<MainTabView> createState() => _MainTabViewState();
}

class _MainTabViewState extends State<MainTabView> {
  int selectTab = 0;
  final PageStorageBucket pageBucket = PageStorageBucket();
  late Widget currentTab;

  @override
  void initState() {
    super.initState();
    selectTab = widget.initialTab;
    currentTab = _getTab(selectTab);
  }

  // Hàm để lấy tab dựa vào index
  Widget _getTab(int index) {
    switch (index) {
      case 0:
        return WorkoutTrackerView(user: widget.user);
      case 1:
        return const AllWorkoutView();
      case 2:
        return const WorkoutScheduleView();
      case 3:
        return ProfileView(user: widget.user);
      default:
        return WorkoutTrackerView(user: widget.user);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.white,
      body: PageStorage(bucket: pageBucket, child: currentTab),
      bottomNavigationBar: BottomAppBar(
          child: Container(
            decoration: BoxDecoration(color: TColor.white, boxShadow: const [
              BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, -2))
            ]),
            height: kToolbarHeight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TabButton(
                    icon: "assets/img/home_tab.png",
                    selectIcon: "assets/img/home_tab_select.png",
                    isActive: selectTab == 0,
                    onTap: () {
                      selectTab = 0;
                      currentTab = _getTab(selectTab);
                      if (mounted) {
                        setState(() {});
                      }
                    }),
                TabButton(
                    icon: "assets/img/activity_tab.png",
                    selectIcon: "assets/img/activity_tab_select.png",
                    isActive: selectTab == 1,
                    onTap: () {
                      selectTab = 1;
                      currentTab = _getTab(selectTab);
                      if (mounted) {
                        setState(() {});
                      }
                    }),
                TabButton(
                    icon: "assets/img/p_calendar.png",
                    selectIcon: "assets/img/p_select_alendar.png",
                    isActive: selectTab == 2,
                    onTap: () {
                      selectTab = 2;
                      currentTab = _getTab(selectTab);
                      if (mounted) {
                        setState(() {});
                      }
                    }),
                TabButton(
                    icon: "assets/img/profile_tab.png",
                    selectIcon: "assets/img/profile_tab_select.png",
                    isActive: selectTab == 3,
                    onTap: () {
                      selectTab = 3;
                      currentTab = _getTab(selectTab);
                      if (mounted) {
                        setState(() {});
                      }
                    })
              ],
            ),
          )
      ),
    );
  }
}

import 'package:fitness_workout_app/common/colo_extension.dart';
import 'package:fitness_workout_app/common_widget/tab_button.dart';
import 'package:fitness_workout_app/view/main_tab/search_view.dart';
import 'package:fitness_workout_app/view/main_tab/select_view.dart';
import 'package:flutter/material.dart';
import 'package:fitness_workout_app/model/user_model.dart';

import '../home/home_view.dart';
import '../photo_progress/photo_progress_view.dart';
import '../profile/profile_view.dart';


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
        return HomeView(user: widget.user);
      case 1:
        return const SelectView();
      case 2:
        return PhotoProgressView(user: widget.user);
      case 3:
        return ProfileView(user: widget.user);
      case 4:
        return const SearchView();
      default:
        return HomeView(user: widget.user);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.white,
      body: PageStorage(bucket: pageBucket, child: currentTab),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: SizedBox(
        width: 70,
        height: 70,
        child: InkWell(
          onTap: () {
            setState(() {
              selectTab = 4;
              currentTab = _getTab(selectTab);
            });
          },
          child: Container(
            width: 65,
            height: 65,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: TColor.primaryG,
              ),
              borderRadius: BorderRadius.circular(35),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 2,
                )
              ],
            ),
            child: Icon(Icons.search, color: TColor.white, size: 35),
          ),
        ),
      ),

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
                const SizedBox(width: 40,),
                TabButton(
                    icon: "assets/img/camera_tab.png",
                    selectIcon: "assets/img/camera_tab_select.png",
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

import 'package:flutter/material.dart';

import '../../common/colo_extension.dart';
import '../meal_planner/meal_planner_view.dart';
import '../sleep_tracker/sleep_tracker_view.dart';
import '../tips/tips_view.dart';
import '../workout_tracker/workout_tracker_view.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  TextEditingController txtSearch = TextEditingController();
  List<String> allActivities = [
    "Workout Tracker",
    "Meal Planner",
    "Sleep Tracker",
    "Tips"
  ];
  List<String> filteredActivities = [];

  @override
  void initState() {
    super.initState();
    txtSearch.addListener(() {
      setState(() {
        // Lọc danh sách dựa trên giá trị trong TextField
        filteredActivities = txtSearch.text.isEmpty
            ? [] // Nếu chưa nhập gì, không hiển thị gì cả
            : allActivities
            .where((activity) =>
            activity.toLowerCase().contains(txtSearch.text.toLowerCase()))
            .toList();
      });
    });
  }

  void navigateToActivity(String activity) {
    switch (activity) {
      case "Workout Tracker":
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const WorkoutTrackerView(),
          ),
        );
        break;
      case "Meal Planner":
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const MealPlannerView()));
        break;
      case "Sleep Tracker":
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const SleepTrackerView()));
        break;
      case "Tips":
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const TipsView()));
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: TColor.white,
        centerTitle: true,
        elevation: 0,
        leadingWidth: 0,
        leading: const SizedBox(),
        title: Text(
          "Search Activity",
          style: TextStyle(
              color: TColor.black, fontSize: 22, fontWeight: FontWeight.w700),
        ),
      ),
      backgroundColor: TColor.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
                color: TColor.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: const [
                  BoxShadow(
                      color: Colors.black12,
                      blurRadius: 2,
                      offset: Offset(0, 1))
                ]),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: txtSearch,
                    decoration: InputDecoration(
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        prefixIcon: Image.asset(
                          "assets/img/search.png",
                          width: 25,
                          height: 25,
                        ),
                        hintText: "Search here..."),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // ListView to display filtered results
          Expanded(
            child: txtSearch.text.isEmpty
                ? Container() // Không hiển thị gì khi chưa nhập
                : (filteredActivities.isEmpty
                ? Center(child: Text("No activities found", style: TextStyle(color: TColor.black, fontSize: 16)))
                : ListView.builder(
              itemCount: filteredActivities.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(filteredActivities[index]),
                  onTap: () => navigateToActivity(filteredActivities[index]),
                );
              },
            )),
          ),
        ],
      ),
    );
  }
}


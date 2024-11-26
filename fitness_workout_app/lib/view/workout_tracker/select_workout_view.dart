import 'package:fitness_workout_app/common/colo_extension.dart';
import 'package:fitness_workout_app/common_widget/select_train_row.dart';
import 'package:flutter/material.dart';
import '../../services/workout_tracker.dart';

class SelectWorkoutView extends StatefulWidget {
  const SelectWorkoutView({super.key});

  @override
  State<SelectWorkoutView> createState() => _SelectWorkoutViewState();
}

class _SelectWorkoutViewState extends State<SelectWorkoutView> {
  final WorkoutService _workoutService = WorkoutService();
  List<Map<String, dynamic>> whatArr = [];
  List<Map<String, dynamic>> filteredArr = [];
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCategoryWorkouts();
    _searchController.addListener(_filterWorkouts);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCategoryWorkouts() async {
    List<Map<String, dynamic>> workouts = await _workoutService.fetchCategoryWorkoutList();
    setState(() {
      whatArr = workouts;
      filteredArr = workouts;
    });
  }

  void _filterWorkouts() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      filteredArr = whatArr.where((workout) {
        // Tìm kiếm dựa trên tên hoặc các thuộc tính khác
        return workout["title"].toLowerCase().contains(query); // Giả sử mỗi phần tử có trường 'name'
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Container(
      decoration: BoxDecoration(gradient: LinearGradient(colors: TColor.primaryG)),
      child: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              backgroundColor: Colors.transparent,
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
                "Workout List",
                style: TextStyle(
                    color: TColor.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700),
              ),
            ),
          ];
        },
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
              color: TColor.white,
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(25), topRight: Radius.circular(25))),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      width: double.infinity,
                      child: TextField(
                        controller: _searchController,
                        style: TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          hintText: 'Search...',
                          hintStyle: TextStyle(color: Colors.black.withOpacity(0.7)),
                          filled: true,
                          fillColor: Colors.grey.withOpacity(0.1),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                        ),
                      ),
                    ),
                  ),
                  ListView.builder(
                      padding: EdgeInsets.zero,
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: filteredArr.length,
                      itemBuilder: (context, index) {
                        var wObj = filteredArr[index] as Map? ?? {};
                        return SelectTrainRow(
                          wObj: wObj,
                          onSelect: (selectedTitle) {
                            Navigator.pop(context, selectedTitle);
                          },
                        );
                      }),
                  SizedBox(height: media.width * 0.1),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

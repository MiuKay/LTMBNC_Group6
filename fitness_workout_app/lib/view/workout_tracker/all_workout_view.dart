import 'package:fitness_workout_app/common/colo_extension.dart';
import 'package:flutter/material.dart';
import '../../common_widget/what_train_row.dart';
import '../../services/workout_tracker.dart';

class AllWorkoutView extends StatefulWidget {
  const AllWorkoutView({super.key});

  @override
  State<AllWorkoutView> createState() => _AllWorkoutViewState();
}

class _AllWorkoutViewState extends State<AllWorkoutView> {
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
      filteredArr = workouts; // Hiển thị tất cả ban đầu
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
              leadingWidth: 0,
              leading: const SizedBox(),
              title: Text(
                "Workout List",
                style: TextStyle(color: TColor.black, fontSize: 22, fontWeight: FontWeight.w700),
              ),
            ),
          ];
        },
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: TColor.white,
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25)),
          ),
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

                  // Hiển thị danh sách các workout
                  ListView.builder(
                    padding: EdgeInsets.zero,
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: filteredArr.length,
                    itemBuilder: (context, index) {
                      var wObj = filteredArr[index] as Map? ?? {};
                      return InkWell(
                        child: WhatTrainRow(wObj: wObj),
                      );
                    },
                  ),
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

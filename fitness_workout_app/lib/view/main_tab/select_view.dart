import 'package:fitness_workout_app/common_widget/round_button.dart';
import 'package:fitness_workout_app/view/meal_planner/meal_planner_view.dart';
import 'package:fitness_workout_app/view/workout_tracker/workout_tracker_view.dart';
import 'package:flutter/material.dart';

import '../sleep_tracker/sleep_tracker_view.dart';

class SelectView extends StatelessWidget {
  const SelectView({super.key});
<<<<<<< Updated upstream

  @override
  Widget build(BuildContext context) {
    // var media = MediaQuery.of(context).size;

=======
  @override
  State<SelectView> createState() => _SelectViewState();
}

class _SelectViewState extends State<SelectView> {
  List menuArr = [
    {
      "name": "Workout Tracker",
      "image": "assets/img/menu_exercises.png",
      "tag": "1"
    },
    {
      "name": "Meal Planner",
      "image": "assets/img/menu_meal_plan.png",
      "tag": "2"
    },
    {"name": "Sleep Tracker", "image": "assets/img/menu_clock.png", "tag": "3"},
    {"name": "Tips", "image": "assets/img/menu_tips.png", "tag": "4"},
  ];

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery
        .of(context)
        .size;
>>>>>>> Stashed changes
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RoundButton(
                title: "Workout Tracker",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const WorkoutTrackerView(),
                    ),
                  );
                }),

            const SizedBox(height: 15,),

            RoundButton(
                title: "Meal Planner",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MealPlannerView(),
                    ),
                  );
                }),

            const SizedBox(height: 15,),

            RoundButton(
                title: "Sleep Tracker",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SleepTrackerView(),
                    ),
                  );
                })
          ],
        ),
      ),
<<<<<<< Updated upstream
=======
      backgroundColor: TColor.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 4),
            Padding(
              padding:
              const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Container(
                width: double.maxFinite,
                padding: const EdgeInsets.all(20),
                height: media.width * 0.4,
                decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      TColor.primaryColor2.withOpacity(0.4),
                      TColor.primaryColor1.withOpacity(0.4)
                    ]),
                    borderRadius: BorderRadius.circular(20)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 15,
                          ),
                          Text(
                            "Workout Tracker",
                            style: TextStyle(
                              color: TColor.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            "Train your body",
                            style: TextStyle(
                                color: TColor.primaryColor2,
                                fontSize: 14,
                                fontWeight: FontWeight.w500),
                          ),
                          const Spacer(),
                          SizedBox(
                            width: 110,
                            height: 35,
                            child: RoundButton(
                                title: "Start",
                                fontSize: 12,
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (
                                          context) => const WorkoutTrackerView(),
                                    ),
                                  );
                                }),
                          )
                        ]),
                    Image.asset(
                      "assets/img/welcome.png",
                      width: media.width * 0.35,
                    )
                  ],
                ),
              ),
            ),
            SizedBox(height: 0.02),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Container(
                width: double.maxFinite,
                padding: const EdgeInsets.all(20),
                height: media.width * 0.4,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    TColor.primaryColor2.withOpacity(0.4),
                    TColor.primaryColor1.withOpacity(0.4)
                  ]),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset(
                      "assets/img/pancake_1.png",
                      width: media.width * 0.35,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 15,
                        ),
                        Text(
                          "Meal Tracker",
                          style: TextStyle(
                            color: TColor.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          "Manage your meal",
                          style: TextStyle(
                            color: TColor.primaryColor2,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        SizedBox(
                          width: 110,
                          height: 35,
                          child: RoundButton(
                            title: "Start",
                            fontSize: 12,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const MealPlannerView(),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 0.01),
            Padding(
              padding:
              const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Container(
                width: double.maxFinite,
                padding: const EdgeInsets.all(20),
                height: media.width * 0.4,
                decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      TColor.primaryColor2.withOpacity(0.4),
                      TColor.primaryColor1.withOpacity(0.4)
                    ]),
                    borderRadius: BorderRadius.circular(20)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 15,
                          ),
                          Text(
                            "Sleep Tracker",
                            style: TextStyle(
                              color: TColor.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            "Manage your sleep",
                            style: TextStyle(
                                color: TColor.primaryColor2,
                                fontSize: 14,
                                fontWeight: FontWeight.w500),
                          ),
                          const Spacer(),
                          SizedBox(
                            width: 110,
                            height: 35,
                            child: RoundButton(
                                title: "Start",
                                fontSize: 12,
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (
                                          context) => const SleepTrackerView(),
                                    ),
                                  );
                                }),
                          )
                        ]),
                    Image.asset(
                      "assets/img/sleep_schedule.png",
                      width: media.width * 0.35,
                    )
                  ],
                ),
              ),
            ),
            SizedBox(height: 0.01),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Container(
                width: double.maxFinite,
                padding: const EdgeInsets.all(20),
                height: media.width * 0.4,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    TColor.primaryColor2.withOpacity(0.4),
                    TColor.primaryColor1.withOpacity(0.4)
                  ]),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset(
                      "assets/img/tips.png",
                      width: media.width * 0.35,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 15,
                        ),
                        Text(
                          "Tips",
                          style: TextStyle(
                            color: TColor.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          "Helpful tips for you",
                          style: TextStyle(
                            color: TColor.primaryColor2,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        SizedBox(
                          width: 110,
                          height: 35,
                          child: RoundButton(
                            title: "Learn More",
                            fontSize: 12,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const TipsView(),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
>>>>>>> Stashed changes
    );
  }
}
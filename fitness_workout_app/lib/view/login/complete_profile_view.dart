import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness_workout_app/common/colo_extension.dart';
import 'package:fitness_workout_app/view/login/what_your_goal_view.dart';
import 'package:flutter/material.dart';

import '../../common_widget/round_button.dart';
import '../../common_widget/round_textfield.dart';
import '../../common_widget/selectDate.dart';
import '../../services/auth.dart';
import 'package:fitness_workout_app/model/user_model.dart';

class CompleteProfileView extends StatefulWidget {
  const CompleteProfileView({super.key});

  @override
  State<CompleteProfileView> createState() => _CompleteProfileViewState();
}

class _CompleteProfileViewState extends State<CompleteProfileView> {
  final TextEditingController selectDate = TextEditingController();
  final TextEditingController selectedGender = TextEditingController();
  final TextEditingController selectWeight = TextEditingController();
  final TextEditingController selectHeight = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    super.dispose();
    selectDate.dispose();
    selectedGender.dispose();
    selectWeight.dispose();
    selectHeight.dispose();
  }

  void completeUserProfile() async {
    setState(() {
      isLoading = true;
    });
    String uid = FirebaseAuth.instance.currentUser!.uid;

    String res = await AuthService().completeUserProfile(
      uid: uid,
      dateOfBirth: selectDate.text,
      gender: selectedGender.text,
      weight: selectWeight.text,
      height: selectHeight.text,
    );

    if (res == "success") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const WhatYourGoalView(),
        ),
      );
      setState(() {
        isLoading = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res)),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery
        .of(context)
        .size;
    return Scaffold(
      backgroundColor: TColor.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  children: [
                    Image.asset(
                      "assets/img/complete_profile.png",
                      width: media.width,
                      fit: BoxFit.fitWidth,
                    ),
                    SizedBox(
                      height: media.width * 0.05,
                    ),
                    Text(
                      "Let’s complete your profile",
                      style: TextStyle(
                          color: TColor.black,
                          fontSize: 20,
                          fontWeight: FontWeight.w700),
                    ),
                    Text(
                      "It will help us to know more about you!",
                      style: TextStyle(color: TColor.gray, fontSize: 12),
                    ),
                    SizedBox(
                      height: media.width * 0.05,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                                color: TColor.lightGray,
                                borderRadius: BorderRadius.circular(15)),
                            child: Row(
                              children: [
                                Container(
                                  alignment: Alignment.center,
                                  width: 50,
                                  height: 50,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15),
                                  child: Image.asset(
                                    "assets/img/gender.png",
                                    width: 20,
                                    height: 20,
                                    fit: BoxFit.contain,
                                    color: TColor.gray,
                                  ),
                                ),

                                Expanded(
                                  child: TextField(
                                    controller: selectedGender,
                                    readOnly: true,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: TColor.black,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: "Choose Gender",
                                      hintStyle: TextStyle(
                                          color: TColor.gray, fontSize: 12),
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),

                                DropdownButtonHideUnderline(
                                  child: DropdownButton(
                                    items: ["Male", "Female"]
                                        .map((name) =>
                                        DropdownMenuItem(
                                          value: name,
                                          child: Text(
                                            name,
                                            style: TextStyle(color: TColor.gray,
                                                fontSize: 14),
                                          ),
                                        )).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        selectedGender.text = value.toString();
                                      });
                                    },
                                    icon: Icon(Icons.arrow_drop_down,
                                        color: TColor.gray),
                                    isExpanded: false,
                                  ),
                                ),

                                const SizedBox(width: 8),
                              ],
                            ),),
                          SizedBox(
                            height: media.width * 0.04,
                          ),
                          InkWell(
                            onTap: () {
                              DatePickerHelper.selectDate(context, selectDate);
                            },
                            child: IgnorePointer(
                              child: RoundTextField(
                                controller: selectDate,
                                hitText: "Date of Birth",
                                icon: "assets/img/date.png",
                              ),
                            ),
                          ),

                          SizedBox(
                            height: media.width * 0.04,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: RoundTextField(
                                  controller: selectWeight,
                                  hitText: "Your Weight",
                                  icon: "assets/img/weight.png",
                                ),
                              ),
                              const SizedBox(
                                width: 8,
                              ),
                              Container(
                                width: 50,
                                height: 50,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: TColor.secondaryG,
                                  ),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Text(
                                  "KG",
                                  style:
                                  TextStyle(color: TColor.white, fontSize: 12),
                                ),
                              )
                            ],
                          ),
                          SizedBox(
                            height: media.width * 0.04,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: RoundTextField(
                                  controller: selectHeight,
                                  hitText: "Your Height",
                                  icon: "assets/img/hight.png",
                                ),
                              ),
                              const SizedBox(
                                width: 8,
                              ),
                              Container(
                                width: 50,
                                height: 50,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: TColor.secondaryG,
                                  ),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Text(
                                  "CM",
                                  style:
                                  TextStyle(color: TColor.white, fontSize: 12),
                                ),
                              )
                            ],
                          ),
                          SizedBox(
                            height: media.width * 0.07,
                          ),
                          RoundButton(
                            title: "Next >",
                            onPressed: completeUserProfile,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
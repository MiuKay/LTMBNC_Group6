import 'package:fitness_workout_app/common/colo_extension.dart';
import 'package:fitness_workout_app/view/login/reset_password_view.dart';
import 'package:fitness_workout_app/view/login/what_your_goal_view.dart';
import 'package:flutter/material.dart';

import '../../common_widget/round_button.dart';
import '../../common_widget/round_textfield.dart';
import '../../common_widget/selectDate.dart';

class EditProfileView extends StatefulWidget {
  const EditProfileView({super.key});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  TextEditingController selectDate = TextEditingController();
  TextEditingController selectedGender = TextEditingController();
  TextEditingController selectWeight = TextEditingController();
  TextEditingController selectHeight = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: TColor.white,
      appBar: AppBar(
        backgroundColor: TColor.white,
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
              borderRadius: BorderRadius.circular(10),
            ),
            child: Image.asset(
              "assets/img/black_btn.png",
              width: 15,
              height: 15,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children: [
                Text(
                  "Hey there,",
                  style: TextStyle(color: TColor.gray, fontSize: 16),
                ),
                Text(
                  "Edit Your Profile",
                  style: TextStyle(
                      color: TColor.black,
                      fontSize: 20,
                      fontWeight: FontWeight.w700),
                ),
                SizedBox(
                  height: media.width * 0.05,
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(media.width * 0.2),
                  child: Image.asset(
                    "assets/img/u2.png",
                    width: media.width * 0.35,
                    height: media.width * 0.35,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(
                  height: media.width * 0.05,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Column(
                    children: [
                      const RoundTextField(
                        hitText: "First Name",
                        icon: "assets/img/user_text.png",
                        //controller: fnameController,
                      ),
                      SizedBox(
                        height: media.width * 0.04,
                      ),
                      const RoundTextField(
                        hitText: "Last Name",
                        icon: "assets/img/user_text.png",
                        //controller: lnameController,
                      ),
                      SizedBox(
                        height: media.width * 0.04,
                      ),
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
                              padding: const EdgeInsets.symmetric(horizontal: 15),
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
                                  hintStyle: TextStyle(color: TColor.gray, fontSize: 12),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),

                            DropdownButtonHideUnderline(
                              child: DropdownButton(
                                items: ["Male", "Female"]
                                    .map((name) => DropdownMenuItem(
                                  value: name,
                                  child: Text(
                                    name,
                                    style: TextStyle(color: TColor.gray, fontSize: 14),
                                  ),
                                )).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    selectedGender.text = value.toString(); // Update text when gender is selected
                                  });
                                },
                                icon: Icon(Icons.arrow_drop_down, color: TColor.gray),
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
                        height: media.width * 0.06,
                      ),
                      RoundButton(
                          title: "Upload your image",
                          onPressed: () {

                          }),
                      SizedBox(
                        height: media.width * 0.04,
                      ),
                      RoundButton(
                          title: "Save",
                          onPressed: () {

                          }),
                      SizedBox(
                        height: media.width * 0.04,
                      ),
                      RoundButton(
                          title: "Change Password",
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                    const ResetPasswordView()));
                          }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
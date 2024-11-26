import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fitness_workout_app/common/colo_extension.dart';
import 'package:fitness_workout_app/view/login/reset_password_view.dart';
import 'package:fitness_workout_app/view/main_tab/main_tab_view.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../common_widget/round_button.dart';
import '../../common_widget/round_textfield.dart';
import '../../common_widget/selectDate.dart';
import '../../model/user_model.dart';
import '../../services/auth.dart';

class EditProfileView extends StatefulWidget {
  final UserModel user;
  const EditProfileView({super.key, required this.user});
  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  final TextEditingController selectDate = TextEditingController();
  final TextEditingController selectedGender = TextEditingController();
  final TextEditingController selectWeight = TextEditingController();
  final TextEditingController selectHeight = TextEditingController();
  final TextEditingController fnameController = TextEditingController();
  final TextEditingController lnameController = TextEditingController();
  String currentPic = '';
  final ImagePicker _picker = ImagePicker();

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fnameController.text = widget.user.fname;
    lnameController.text = widget.user.lname;
    selectWeight.text = widget.user.weight;
    selectHeight.text = widget.user.height;
    selectDate.text = widget.user.dateOfBirth;
    selectedGender.text = widget.user.gender;
    currentPic =
    widget.user.pic.isNotEmpty ? widget.user.pic : "assets/img/u2.png";
  }

  @override
  void dispose() {
    fnameController.dispose();
    lnameController.dispose();
    selectWeight.dispose();
    selectHeight.dispose();
    selectDate.dispose();
    selectedGender.dispose();
    super.dispose();
  }

  void uploadImage() async {
    setState(() {
      isLoading = true;
    });

    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      try {
        String filePath = 'profile_images/${widget.user.uid}.png';
        File file = File(image.path);

        // Upload ảnh lên Firebase
        TaskSnapshot snapshot = await FirebaseStorage.instance.ref(filePath)
            .putFile(file);
        String downloadUrl = await snapshot.ref.getDownloadURL();

        // Gán ảnh trên Firebase vào người dùng
        String uid = widget.user.uid;
        await AuthService().updateUserProfileImage(uid, downloadUrl);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload successful!')),
        );

        // Cập nhật ảnh trong trạng thái hiện tại
        setState(() {
          currentPic = downloadUrl;
          isLoading = false;
        });
      } catch (e) {
        // Xử lý lỗi
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e')),
        );
        setState(() {
          isLoading = false;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No image selected.')),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  void getUserInfo() async {
    try {
      // Lấy thông tin người dùng
      UserModel? user = await AuthService().getUserInfo(
          FirebaseAuth.instance.currentUser!.uid);

      if (user != null) {
        // Điều hướng đến HomeView với user
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MainTabView(user: user, initialTab: 3),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Có lỗi xảy ra')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi xảy ra: $e')),
      );
    }
  }

  void updateUserProfile() async {
    setState(() {
      isLoading = true;
    });
    String uid = widget.user.uid;

    String res = await AuthService().updateUserProfile(
      uid: uid,
      fname: fnameController.text,
      lname: lnameController.text,
      dateOfBirth: selectDate.text,
      gender: selectedGender.text,
      weight: selectWeight.text,
      height: selectHeight.text,
    );

    if (res == "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Complete update your profile')),
      );
      setState(() {
        isLoading = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $res')),
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
      appBar: AppBar(
        backgroundColor: TColor.white,
        elevation: 0,
        leading: InkWell(
          onTap: getUserInfo,
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
      body: Stack(
        children: [
          SingleChildScrollView(
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
                      child: currentPic.startsWith('http')
                          ? Image.network(
                        currentPic,
                        width: media.width * 0.35,
                        height: media.width * 0.35,
                        fit: BoxFit.cover,
                      )
                          : Image.asset(
                        currentPic,
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
                          RoundTextField(
                            hitText: "First Name",
                            icon: "assets/img/user_text.png",
                            controller: fnameController,
                          ),
                          SizedBox(
                            height: media.width * 0.04,
                          ),
                          RoundTextField(
                            hitText: "Last Name",
                            icon: "assets/img/user_text.png",
                            controller: lnameController,
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
                            height: media.width * 0.06,
                          ),
                          RoundButton(
                            title: "Upload your image",
                            onPressed: uploadImage,
                          ),
                          SizedBox(
                            height: media.width * 0.04,
                          ),
                          RoundButton(
                            title: "Save",
                            onPressed: updateUserProfile,
                          ),
                          SizedBox(
                            height: media.width * 0.04,
                          ),
                          RoundButton(
                            title: "Change Password",
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (
                                      context) => const ResetPasswordView(),
                                ),
                              );
                            },
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
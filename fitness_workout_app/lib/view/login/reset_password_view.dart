import 'package:fitness_workout_app/common/colo_extension.dart';
import 'package:fitness_workout_app/common_widget/round_button.dart';
import 'package:fitness_workout_app/common_widget/round_textfield.dart';
import 'package:fitness_workout_app/view/login/login_view.dart';
import 'package:flutter/material.dart';
import 'package:fitness_workout_app/services/auth.dart';

class ResetPasswordView extends StatefulWidget {
  const ResetPasswordView({super.key});

  @override
  State<ResetPasswordView> createState() => _ResetPasswordView();
}

class _ResetPasswordView extends State<ResetPasswordView> {
  final TextEditingController emailController = TextEditingController();
  bool isCheck = false;

  void handleResetpassword() async {
    setState(() {
      isCheck = true;
    });

    try {
      await AuthService().resetPassword(emailController.text.trim());
      setState(() {
        isCheck = false;
      });

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Success"),
            content: Text("Password reset email sent successfully!"),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Đóng bảng thông báo
                },
                child: Text("OK"),
              ),
            ],
          );
        },
      );
    } catch (e) {
      setState(() {
        isCheck = false;
      });

      // Hiển thị lỗi nếu có vấn đề xảy ra
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }


  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
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
      body: Stack(
        children: [
          SingleChildScrollView(
            child: SafeArea(
              child: Container(
                height: media.height * 0.9,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: media.width * 0.01,
                    ),
                    Text(
                      "Reset password",
                      style: TextStyle(color: TColor.black,
                          fontSize: 24,
                          fontWeight: FontWeight.w700),
                    ),
                    Text(
                      "Please enter your email to reset the password",
                      style: TextStyle(
                          color: TColor.gray, fontSize: 13),
                    ),
                    SizedBox(
                      height: media.width * 0.5,
                    ),
                    Text(
                      "Your Email",
                      style: TextStyle(color: TColor.black,
                          fontSize: 18,
                          fontWeight: FontWeight.w700),
                    ),
                    SizedBox(
                      height: media.width * 0.01,
                    ),
                    RoundTextField(
                      hitText: "Email",
                      icon: "assets/img/email.png",
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    SizedBox(
                      height: media.width * 0.04,
                    ),
                    RoundButton(
                        title: "Reset Password",
                        onPressed: handleResetpassword
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (isCheck)
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

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
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPassController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  bool isCheck = false;
  bool obscureText = true;
  bool obscureText1 = true;

  void getOTP() async {
    setState(() {
      isCheck = true;
    });

    try {
      if (emailController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Vui lòng nhập email để nhận OTP')),
        );
        setState(() {
          isCheck = false;
        });
      } else {
        String res = await AuthService().sendOtpEmailResetPass(
            emailController.text.trim());
        if (res == "success") {
          setState(() {
            isCheck = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('OTP đã được gửi đến email của bạn')),
          );
        } else {
          setState(() {
            isCheck = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(res)),
          );
        }
      }
    }catch (e) {
      setState(() {
        isCheck = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi xảy ra: $e')),
      );
    }
  }

  void handleResetpassword() async {
    setState(() {
      isCheck = true;
    });

    try {
      if (emailController.text.isEmpty || passwordController.text.isEmpty
          || confirmPassController.text.isEmpty || otpController.text.isEmpty) {
        setState(() {
          isCheck = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Vui lòng điền đầy đủ thông tin')),
        );
      } else
      if (passwordController.text.trim() != confirmPassController.text.trim()) {
        setState(() {
          isCheck = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Xác nhận mật khẩu không chính xác')),
        );
      } else {
        String res = await AuthService().resetPassword(
            emailController.text.trim(),
            passwordController.text.trim(),
            otpController.text.trim());
        if (res == "success") {
          setState(() {
            isCheck = false;
          });
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Success"),
                content: Text("Password reset successfully!"),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LoginView()));
                    },
                    child: Text("OK"),
                  ),
                ],
              );
            },
          );
        }
        else {
          setState(() {
            isCheck = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(res)),
          );
        }
      }
    } catch (e) {
      setState(() {
        isCheck = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }


  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPassController.dispose();
    otpController.dispose();
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
                      height: media.width * 0.02,
                    ),
                    Text(
                      "Reset password",
                      style: TextStyle(color: TColor.black,
                          fontSize: 24,
                          fontWeight: FontWeight.w700),
                    ),
                    Text(
                      "Please enter your email and new password to reset the password",
                      style: TextStyle(
                          color: TColor.gray, fontSize: 13),
                    ),
                    SizedBox(
                      height: media.width * 0.05,
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
                    RoundTextField(
                      hitText: "New Password",
                      icon: "assets/img/lock.png",
                      controller: passwordController,
                      obscureText: obscureText,
                      rigtIcon: TextButton(
                        onPressed: () {
                          setState(() {
                            obscureText = !obscureText;
                          });
                        },
                        child: Container(
                          alignment: Alignment.center,
                          width: 20,
                          height: 20,
                          child: Image.asset(
                            obscureText
                                ? "assets/img/hide_password.png"
                                : "assets/img/show_password.png",
                            // Cập nhật icon
                            width: 20,
                            height: 20,
                            fit: BoxFit.contain,
                            color: TColor.gray,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: media.width * 0.04,
                    ),
                    RoundTextField(
                      hitText: "Confirm New Password",
                      icon: "assets/img/lock.png",
                      controller: confirmPassController,
                      obscureText: obscureText1,
                      rigtIcon: TextButton(
                        onPressed: () {
                          setState(() {
                            obscureText1 = !obscureText1;
                          });
                        },
                        child: Container(
                          alignment: Alignment.center,
                          width: 20,
                          height: 20,
                          child: Image.asset(
                            obscureText1
                                ? "assets/img/hide_password.png"
                                : "assets/img/show_password.png",
                            // Cập nhật icon
                            width: 20,
                            height: 20,
                            fit: BoxFit.contain,
                            color: TColor.gray,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: media.width * 0.04,
                    ),
                    Row(
                      children: [
                        // Expanded để RoundTextField chiếm phần lớn không gian
                        Expanded(
                          child: RoundTextField(
                            hitText: "OTP",
                            icon: "assets/img/otp.png",
                            controller: otpController,
                          ),
                        ),
                        SizedBox(width: 10),
                        Container(
                          width: 100,
                          child: RoundButton(
                            type: RoundButtonType.bgSGradient,
                            title: "Get OTP",
                            onPressed: getOTP,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: media.width * 0.06,
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

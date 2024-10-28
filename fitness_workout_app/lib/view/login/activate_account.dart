import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness_workout_app/common/colo_extension.dart';
import 'package:fitness_workout_app/common_widget/round_button.dart';
import 'package:fitness_workout_app/common_widget/round_textfield.dart';
import 'package:fitness_workout_app/view/login/welcome_view.dart';
import 'package:flutter/material.dart';
import 'package:fitness_workout_app/services/auth.dart';

class ActivateAccountView extends StatefulWidget {
  const ActivateAccountView({super.key});

  @override
  State<ActivateAccountView> createState() => _ActivateAccountView();
}

class _ActivateAccountView extends State<ActivateAccountView> {
  final TextEditingController otpController = TextEditingController();
  bool isCheck = false;

  void verifyOTP() async {
    setState(() {
      isCheck = true;
    });
    String uid = FirebaseAuth.instance.currentUser!.uid;

    String res = await AuthService().verifyOtp(
        uid: uid,
        otp: otpController.text,
    );

    if (res == "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Verify OTP success!')),
      );
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const WelcomeView(),
        ),
      );
      setState(() {
        isCheck = false;
      });
    }else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res)),
      );
      setState(() {
        isCheck = false;
      });
    }
  }

  void sendOTP() async {
    setState(() {
      isCheck = true;
    });
    String uid = FirebaseAuth.instance.currentUser!.uid;

    String res = await AuthService().sendOtpEmail(uid);

    if (res == "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('OTP đã được gửi đến email của bạn')),
      );
      setState(() {
        isCheck = false;
      });
    }else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res)),
      );
      setState(() {
        isCheck = false;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    otpController.dispose();
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
              child: Container(
                height: media.height * 0.9,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: media.width * 0.1,
                    ),
                    Text(
                      "Activate Account",
                      style: TextStyle(color: TColor.black,
                          fontSize: 24,
                          fontWeight: FontWeight.w700),
                    ),
                    Text(
                      "Please enter the OTP sent to your email",
                      style: TextStyle(
                          color: TColor.gray, fontSize: 13),
                    ),
                    SizedBox(
                      height: media.width * 0.05,
                    ),
                    RoundTextField(
                      hitText: "OTP",
                      icon: "assets/img/otp.png",
                      controller: otpController,
                    ),
                    SizedBox(
                      height: media.width * 0.05,
                    ),
                    RoundButton(
                        title: "Confirm OTP",
                        onPressed: verifyOTP
                    ),
                    SizedBox(
                      height: media.width * 0.04,
                    ),
                    RoundButton(
                        title: "Send OTP",
                        onPressed: sendOTP
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

import 'package:fitness_workout_app/common/colo_extension.dart';
import 'package:flutter/material.dart';

class PrivacyPolicyandTermOfUseView extends StatefulWidget {
  const PrivacyPolicyandTermOfUseView({super.key});

  @override
  State<PrivacyPolicyandTermOfUseView> createState() => _PrivacyPolicyandTermOfUseViewState();
}

class _PrivacyPolicyandTermOfUseViewState extends State<PrivacyPolicyandTermOfUseView> {

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
                  "Privacy Policy and Term of Use",
                  style: TextStyle(
                      color: TColor.black,
                      fontSize: 20,
                      fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


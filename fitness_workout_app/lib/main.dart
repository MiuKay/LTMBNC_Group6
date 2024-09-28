import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:fitness_workout_app/view/main_tab/main_tab_view.dart';
import 'package:fitness_workout_app/view/on_boarding/started_view.dart';
import 'package:fitness_workout_app/view/login/login_view.dart';
import 'package:fitness_workout_app/view/login/signup_view.dart';
import 'package:fitness_workout_app/view/home/home_view.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fitness_workout_app/view/login/complete_profile_view.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'common/colo_extension.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();


  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fitness 3 in 1',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: TColor.primaryColor1,
        fontFamily: "Poppins",
      ),
      // Thiết lập route mặc định
      initialRoute: '/start', // Trang khởi đầu là trang StartedView
      // Cấu hình các routes
      routes: {
        '/start': (context) => const StartedView(),
        '/login': (context) => const LoginView(),
        '/signup': (context) => const SignUpView(),
        '/main_home': (context) => const MainTabView(), // Màn hình chính có tab
        '/completeProfile': (context) => const CompleteProfileView(),

      },
    );
  }
}

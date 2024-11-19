import 'package:fitness_workout_app/services/auth.dart';
import 'package:fitness_workout_app/services/notification.dart';
import 'package:fitness_workout_app/view/home/notification_view.dart';
import 'package:fitness_workout_app/view/main_tab/main_tab_view.dart';
import 'package:fitness_workout_app/view/on_boarding/started_view.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'common/colo_extension.dart';
import 'model/user_model.dart';

final navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  await NotificationServices().initNotifications();

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
       home:
      FutureBuilder<Widget>(
        future: _getInitialScreen(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Hiển thị màn hình chờ trong khi kiểm tra trạng thái đăng nhập
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // Xử lý lỗi nếu có
            return const Center(child: Text("Something went wrong"));
          } else {
            // Nếu không có lỗi, hiển thị màn hình khởi đầu thích hợp
            return snapshot.data!;
          }
        },
      ),
    );
  }

  Future<Widget> _getInitialScreen() async {
    UserModel? user;
    if (FirebaseAuth.instance.currentUser != null) {
      user = await AuthService().getUserInfo(FirebaseAuth.instance.currentUser!.uid);
    }
    if (user != null) {
      // Người dùng đã đăng nhập
      return MainTabView(user: user);
    } else {
      // Người dùng chưa đăng nhập
      return const StartedView();
    }
  }
}

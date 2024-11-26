import 'package:fitness_workout_app/services/auth.dart';
import 'package:fitness_workout_app/services/notification.dart';
import 'package:fitness_workout_app/view/main_tab/main_tab_view.dart';
import 'package:fitness_workout_app/view/on_boarding/started_view.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'common/colo_extension.dart';
import 'model/user_model.dart';

final navigatorKey = GlobalKey<NavigatorState>();

final darkModeNotifier = ValueNotifier<bool>(false); // Trạng thái toàn cục

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await NotificationServices().initNotifications();

  // Đọc trạng thái Dark Mode từ SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  darkModeNotifier.value = prefs.getBool('isDarkMode') ?? false;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: darkModeNotifier,
      builder: (context, isDarkMode, child) {
        return MaterialApp(
          title: 'Fitness 3 in 1',
          debugShowCheckedModeBanner: false,
          navigatorKey: navigatorKey,
          theme: isDarkMode ? _darkTheme : _lightTheme, // Chọn theme
          home: FutureBuilder<Widget>(
            future: _getInitialScreen(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return const Center(child: Text("Something went wrong"));
              } else {
                return snapshot.data!;
              }
            },
          ),
        );
      },
    );
  }

  Future<Widget> _getInitialScreen() async {
    UserModel? user;
    if (FirebaseAuth.instance.currentUser != null) {
      user = await AuthService().getUserInfo(FirebaseAuth.instance.currentUser!.uid);
    }
    if (user != null) {
      return MainTabView(user: user);
    } else {
      return const StartedView();
    }
  }
}

final ThemeData _lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: TColor.primaryColor1,
);

final ThemeData _darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: TColor.primaryColor1,
);



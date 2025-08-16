import 'package:famconnect/features/auth/ui/screens/login_screen.dart';
import 'package:famconnect/features/auth/ui/screens/sign_up_screen.dart';
import 'package:famconnect/features/auth/ui/screens/splash_screen.dart';
import 'package:famconnect/features/home/ui/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:famconnect/app/app_theme_data.dart';


class FamConnectApp extends StatefulWidget {
  const FamConnectApp({super.key});

  @override
  State<FamConnectApp> createState() => _FamConnectAppState();
}

class _FamConnectAppState extends State<FamConnectApp> {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FamConnect',
      theme: AppThemeData.lightThemeData,
      darkTheme: AppThemeData.darkThemeData,
      themeMode: ThemeMode.system,
      initialRoute: '/',
      onGenerateRoute: (RouteSettings settings) {
        late Widget page;

        if (settings.name == '/') {
          page = const SplashScreen();
        } else if (settings.name == LogInScreen.name) {
          page = const LogInScreen();
        } else if (settings.name == SignUpScreen.name) {
          page = const SignUpScreen();
        } else if (settings.name == HomeScreen.name) {
          page = const HomeScreen();
        } else {
          // fallback route
          page = Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          );
        }

        return MaterialPageRoute(builder: (_) => page);
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'core/constants/app_colors.dart';
import 'core/constants/app_styles.dart';
import 'screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return MaterialApp(
          title: 'Fablead ERP',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            fontFamily: AppStyles.fontFamily,
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.primary,
              primary: AppColors.primary,
            ),
            scaffoldBackgroundColor: AppColors.background,
          ),
          home: const SplashScreen(),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';

import 'constants/app_constants.dart';

import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/category_screen.dart';
import 'screens/write_screen.dart';
import 'screens/lock_screen.dart';
import 'screens/reward_screen.dart';
import 'screens/wall_screen.dart';
import 'screens/about_screen.dart';
import 'screens/why_screen.dart';
import 'screens/final_truth_screen.dart';
import 'screens/sealed_screen.dart';
import 'screens/global_wall_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: AppColors.void_,
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  runApp(const LimitedApp());
}

class LimitedApp extends StatelessWidget {
  const LimitedApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LIMITED',
      theme: _buildTheme(),
      initialRoute: '/',
      routes: {
        '/': (_) => const SplashScreen(),
        '/onboarding': (_) => const OnboardingScreen(),
        '/category': (_) => const CategoryScreen(),
        '/write': (_) => const WriteScreen(),
        '/lock': (_) => const LockScreen(),
        '/reward': (_) => const RewardScreen(),
        '/wall': (_) => const WallScreen(),
        '/about': (_) => const AboutScreen(),
        '/why': (_) => const WhyScreen(),
        '/final': (_) => const FinalTruthScreen(),
        '/sealed': (_) => const SealedScreen(),
        '/global': (_) => const GlobalWallScreen(),
      },
    );
  }

  ThemeData _buildTheme() {
    final base = ThemeData.dark();
    
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.void_,
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.sacred,
        secondary: AppColors.sacred,
        surface: AppColors.voidSurface,
      ),
      textTheme: base.textTheme.apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.void_,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTypography.headlineMedium.copyWith(
          color: AppColors.sacred,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.voidSurface,
        contentTextStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.sacred,
          foregroundColor: AppColors.void_,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          minimumSize: const Size.fromHeight(56),
          textStyle: AppTypography.labelLarge,
          elevation: 0,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.sacred,
          textStyle: AppTypography.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.frost,
        hintStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.textMuted,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.frostBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.sacred, width: 1),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.sacred,
      ),
    );
  }
}

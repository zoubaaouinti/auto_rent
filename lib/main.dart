import 'package:flutter/material.dart';
import 'Screens/SplashScreen.dart';
import 'Screens/LoginScreen.dart';
import 'Screens/SignUpScreen.dart';
import 'Screens/ForgotPasswordScreen.dart';
import 'Screens/ForgotPasswordOtpScreen.dart';
import 'Screens/ResetPasswordScreen.dart';
import 'Screens/SignUpOTPVerificationScreen.dart';
import 'Screens/ProfileScreen.dart';
import 'Screens/MainAppScreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Auto Rent',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF5689FF)),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/forgotpass': (context) => const ForgotPasswordScreen(),
        '/forgotpassotp': (context) => const OTPVerificationScreen(),
        '/resetpass': (context) => const ResetPasswordScreen(),
        '/signup-otp': (context) => const SignUpOTPVerificationScreen(),
        '/profile': (context) =>  ProfileScreen(),
        '/main': (context) => const MainAppScreen(),
      },
    );
  }
}
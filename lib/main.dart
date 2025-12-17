// Packages externes
import 'package:auto_rent/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Écrans
import 'Screens/SplashScreen.dart';
import 'Screens/LoginScreen.dart';
import 'Screens/SignUpScreen.dart';
import 'Screens/SignUpOTPVerificationScreen.dart';
import 'Screens/ForgotPasswordScreen.dart';
import 'Screens/ForgotPasswordOtpScreen.dart' show OTPVerificationScreen;
import 'Screens/ResetPasswordScreen.dart';
import 'Screens/ProfileScreen.dart';
import 'Screens/MainAppScreen.dart';
import 'Screens/assistance_screen.dart';

// Thème
import 'presentation/themes/app_theme.dart';

void main() async {
  // Assurez-vous que les bindings Flutter sont initialisés
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialisation des variables d'environnement
    await dotenv.load(fileName: ".env");
    print('Fichier .env chargé avec succès: ${dotenv.env['BASE_URL']}');
  } catch (e) {
    print('Erreur lors du chargement du fichier .env: $e');
    // Utiliser une URL par défaut en cas d'erreur
    dotenv.env['BASE_URL'] = 'http://10.0.2.2:8080';
  }
  
  // Initialisation des préférences partagées
  final prefs = await SharedPreferences.getInstance();
  
  // Créer le conteneur de fournisseurs avec les surcharges nécessaires
  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
    ],
  );

  // Lancer l'application avec le conteneur de fournisseurs
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Écouter les changements d'état d'authentification
    final authState = ref.watch(authStateProvider);
    
    return MaterialApp(
      title: 'Auto Rent',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/forgot-password-otp': (context) {
          final email = ModalRoute.of(context)!.settings.arguments as String;
          return OTPVerificationScreen(email: email);
        },
        '/reset-password': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return ResetPasswordScreen(
            email: args['email'],
            otp: args['otp'],
          );
        },
        '/otp-verification': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return SignUpOTPVerificationScreen(
            email: args['email'],
            password: args['password'],
          );
        },
        '/profile': (context) => const ProfileScreen(),
        '/main': (context) => const MainAppScreen(),
        '/assistance': (context) => const AssistanceScreen(),
      },
      // Pas besoin de builder ici - SplashScreen gère la redirection
    );
  }
}
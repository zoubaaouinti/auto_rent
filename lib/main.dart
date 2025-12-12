// Packages externes
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

// Fichiers de configuration
import 'Screens/ForgotPasswordOtpScreen.dart';
import 'Screens/SignUpOTPVerificationScreen.dart';
import 'firebase_options.dart';

// Services
import 'services/auth_service.dart';

// Thème
import 'package:auto_rent/presentation/themes/app_theme.dart';

// Écrans
import 'Screens/SplashScreen.dart';
import 'Screens/LoginScreen.dart';
import 'Screens/SignUpScreen.dart';
import 'Screens/ForgotPasswordScreen.dart';
import 'Screens/ResetPasswordScreen.dart';
import 'Screens/ProfileScreen.dart';
import 'Screens/MainAppScreen.dart';
import 'Screens/assistance_screen.dart';

// Modèles
import 'models/user_model.dart';

void main() async {
  try {
    // Initialisation de Flutter
    WidgetsFlutterBinding.ensureInitialized();
    
    // Initialisation de Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    // Configuration de Facebook
    // await FacebookAuth.i.webAndDesktopInitialize(
    //   appId: "YOUR_FACEBOOK_APP_ID", // Remplacez par votre ID d'application Facebook
    //   cookie: true,
    //   xfbml: true,
    //   version: "v12.0",
    // );
    
    // Création des services
    final authService = AuthService();
    
    // Initialisation de l'utilisateur actuel
    await authService.getCurrentUser();
    
    // Lancement de l'application avec les providers
    runApp(
      MultiProvider(
        providers: [
          Provider<AuthService>.value(value: authService),
          // Ajoutez d'autres providers si nécessaire
        ],
        child: const MyApp(),
      ),
    );
  } catch (error, stackTrace) {
    // Gestion des erreurs d'initialisation
    debugPrint('Erreur d\'initialisation: $error');
    debugPrint('Stack trace: $stackTrace');
    // Ici, vous pourriez afficher une page d'erreur personnalisée
    runApp(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text(
              'Une erreur est survenue lors du chargement de l\'application.\nVeuillez réessayer plus tard.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Auto Rent',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/forgotpass': (context) => const ForgotPasswordScreen(),
        '/forgotpassotp': (context) => const OTPVerificationScreen(),
        '/resetpass': (context) => const ResetPasswordScreen(),
        '/signup-otp': (context) => const SignUpOTPVerificationScreen(email: '', password: '',),
        '/profile': (context) =>  ProfileScreen(),
        '/main': (context) => const MainAppScreen(),
        '/complaints': (context) => const AssistanceScreen(),
      },
    );
  }
}
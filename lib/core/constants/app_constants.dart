import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  // Charger les variables d'environnement
  static String get baseUrl => dotenv.get('BASE_URL', fallback: 'http://10.0.2.2:8080');
  
  static const String appName = 'Auto Rent';
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration pageTransitionDuration = Duration(milliseconds: 200);
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 12.0;
  
  // Initialiser les variables d'environnement
  static Future<void> init() async {
    await dotenv.load(fileName: ".env");
  }
}

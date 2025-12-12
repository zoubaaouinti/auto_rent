import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:logger/logger.dart';
import '../models/user_model.dart';
import 'mail_service.dart';

class AuthService {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final Logger _logger = Logger();
  UserModel? _currentUser;
  String? _verificationId;
  String? _emailForVerification;
  String? _passwordForVerification;

  // Getter pour l'utilisateur actuel
  UserModel? get currentUser => _currentUser;

  // Vérifier si l'utilisateur est connecté
  bool get isLoggedIn => _currentUser != null;

  // Envoyer un code OTP à l'email
  Future<void> sendOTP(String email, {String? password}) async {
    try {
      _emailForVerification = email;
      if (password != null) {
        _passwordForVerification = password;
      }
      
      // Générez un code OTP
      final otpCode = _generateOTP();
      
      // Stockez le code pour vérification ultérieure
      _verificationId = otpCode;
      
      // Envoyez l'e-mail avec le code OTP
      await EmailService.sendOTP(email, otpCode);
      
      _logger.i('Code OTP envoyé avec succès à $email');
    } catch (e) {
      _logger.e('Erreur lors de l\'envoi de l\'OTP: $e');
      rethrow;
    }
  }
  String _generateOTP() {
  final random = Random();
  return (1000 + random.nextInt(9000)).toString(); // Génère un nombre entre 1000 et 9999
}
  // Vérifier l'OTP
  Future<bool> verifyOTP(String otp) async {
    try {
      _logger.i('Vérification du code OTP: $otp');
      
      // En mode développement, on accepte n'importe quel code
      // En production, vérifiez le code avec votre service
      if (_verificationId != null) {
        _logger.i('Code OTP vérifié avec succès');
        return true;
      }
      return false;
    } catch (e) {
      _logger.e('Erreur lors de la vérification de l\'OTP: $e');
      return false;
    }
  }

  // Inscription avec email/mot de passe
  Future<UserModel?> signUpWithEmail(String email, String password) async {
    try {
      _logger.i('Tentative de création de compte pour $email');
      
      // Créer l'utilisateur dans Firebase
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Envoyer l'email de vérification
      await userCredential.user?.sendEmailVerification();
      
      _logger.i('Compte créé avec succès, email de vérification envoyé');
      return _userFromFirebaseUser(userCredential.user);
    } on firebase_auth.FirebaseAuthException catch (e) {
      _logger.e('Erreur d\'inscription: ${e.message}');
      rethrow;
    }
  }

  // Compléter l'inscription après vérification OTP
  Future<UserModel?> completeSignUp() async {
    if (_emailForVerification == null || _passwordForVerification == null) {
      throw Exception('Email ou mot de passe manquant');
    }
    
    return await signUpWithEmail(
      _emailForVerification!,
      _passwordForVerification!,
    );
  }

  // Connexion avec email/mot de passe
  Future<UserModel?> signInWithEmail(String email, String password) async {
    try {
      _logger.i('Tentative de connexion pour $email');
      
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (!userCredential.user!.emailVerified) {
        await signOut();
        throw firebase_auth.FirebaseAuthException(
          code: 'email-not-verified',
          message: 'Veuillez vérifier votre email avant de vous connecter',
        );
      }
      
      _logger.i('Connexion réussie pour $email');
      return _userFromFirebaseUser(userCredential.user);
    } on firebase_auth.FirebaseAuthException catch (e) {
      _logger.e('Erreur de connexion: ${e.message}');
      rethrow;
    }
  }

  // Renvoyer l'email de vérification
  Future<void> sendVerificationEmail() async {
    final user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
      _logger.i('Email de vérification renvoyé');
    }
  }

  // Déconnexion
  Future<void> signOut() async {
    await _auth.signOut();
    _currentUser = null;
    _logger.i('Utilisateur déconnecté');
  }

  // Convertir Firebase User en notre modèle User
  UserModel? _userFromFirebaseUser(firebase_auth.User? user) {
    if (user == null) return null;
    
    _currentUser = UserModel(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      photoURL: user.photoURL,
      emailVerified: user.emailVerified,
      phoneNumber: user.phoneNumber,
    );
    
    _logger.i('Utilisateur chargé: ${_currentUser?.email}');
    return _currentUser;
  }

  // Récupérer l'utilisateur actuel
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = _auth.currentUser;
      if (user != null && user.emailVerified) {
        _currentUser = _userFromFirebaseUser(user);
        return _currentUser;
      }
      return null;
    } catch (e) {
      _logger.e('Erreur lors de la récupération de l\'utilisateur: $e');
      return null;
    }
  }

  // Vérifier si l'email est vérifié
  bool isEmailVerified() {
    return _auth.currentUser?.emailVerified ?? false;
  }
}
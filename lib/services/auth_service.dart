import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import '../core/constants/app_constants.dart';
import '../models/user_model.dart';

// Classe pour gérer les erreurs d'API personnalisées
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class AuthService extends ChangeNotifier {
  final SharedPreferences prefs;
  final Dio _dio = Dio(BaseOptions(
    baseUrl: AppConstants.baseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
  ));

  String? _authToken;
  String? get authToken => _authToken;

  bool get isAuthenticated => _authToken != null;

  AuthService(this.prefs) {
    // Ajouter un interceptor pour logger les requêtes/réponses
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          print('DEBUG [REQUEST] ${options.method} ${options.path}');
          print('DEBUG [HEADERS] ${options.headers}');
          print('DEBUG [DATA] ${options.data}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          print('DEBUG [RESPONSE] statusCode: ${response.statusCode}');
          print('DEBUG [RESPONSE DATA] ${response.data}');
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          print('DEBUG [ERROR] statusCode: ${e.response?.statusCode}');
          print('DEBUG [ERROR DATA] ${e.response?.data}');
          return handler.next(e);
        },
      ),
    );
    
    // Récupérer le token au démarrage
    _authToken = prefs.getString('auth_token');
    // Si un token est présent au démarrage, l'ajouter aux headers Dio
    if (_authToken != null) {
      _dio.options.headers['Authorization'] = 'Bearer $_authToken';
    }
  }

  // Sauvegarder le token
  Future<void> _saveToken(String token) async {
    _authToken = token;
    await prefs.setString('auth_token', token);
    // Ajouter le header Authorization pour les requêtes suivantes
    _dio.options.headers['Authorization'] = 'Bearer $token';
    notifyListeners();
  }

  // Effacer le token
  Future<void> _clearToken() async {
    _authToken = null;
    await prefs.remove('auth_token');
    await prefs.remove('remember_me');
    // Retirer le header Authorization
    _dio.options.headers.remove('Authorization');
    notifyListeners();
  }

  // Sauvegarder la session "Remember me"
  Future<void> saveRememberMe(bool rememberMe) async {
    await prefs.setBool('remember_me', rememberMe);
  }

  // Récupérer le flag "Remember me"
  bool getRememberMe() {
    return prefs.getBool('remember_me') ?? false;
  }

  // Charger la session persistante au démarrage
  bool hasRememberedSession() {
    return getRememberMe() && _authToken != null;
  }

Future<UserModel> register({
  required String email,
  required String password,
}) async {
  try {
    // Create a new Dio instance without default headers for this call
    final dioNoAuth = Dio(BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ));
    
    final response = await dioNoAuth.post<Map<String, dynamic>>(
      '/api/v1/auth/register',
      data: {
        'email': email,
        'password': password,
        'displayName': email.split('@').first, // Crée un nom d'affichage basé sur l'email
        'role': 'CLIENT_AUTH', // Rôle par défaut
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      if (response.data == null) {
        throw ApiException('Réponse du serveur invalide');
      }
      
      final user = UserModel.fromJson(response.data!);
      if (user.token != null) {
        await _saveToken(user.token!);
      }
      return user;
    } else {
      final errorMessage = _extractErrorMessage(response.data);
      throw ApiException(
        errorMessage.isNotEmpty ? errorMessage : 'Échec de l\'inscription',
        statusCode: response.statusCode,
      );
    }
  } on DioException catch (e) {
    print('DEBUG: DioException on register - statusCode: ${e.response?.statusCode}, response: ${e.response?.data}');
    throw ApiException(_handleDioError(e));
  } catch (e) {
    print('DEBUG: Exception on register - $e');
    throw ApiException('Erreur lors de l\'inscription: $e');
  }
}

  // Vérifier l'email avec OTP
Future<void> verifyEmail({
  required String email,
  required String otp,
}) async {
  try {
    // Create a new Dio instance without default headers for this call
    final dioNoAuth = Dio(BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ));
    
    final response = await dioNoAuth.post(
      '/api/v1/auth/verify-email',
      queryParameters: {
        'email': email,
        'otp': otp,
      },
    );

    if (response.statusCode != 200) {
      final errorMessage = _extractErrorMessage(response.data);
      print('DEBUG: verifyEmail error - statusCode: ${response.statusCode}, message: $errorMessage, data: ${response.data}');
      throw ApiException(
        errorMessage.isNotEmpty ? errorMessage : 'Échec de la vérification',
        statusCode: response.statusCode,
      );
    }
  } on DioException catch (e) {
    print('DEBUG: DioException on verifyEmail - statusCode: ${e.response?.statusCode}, response: ${e.response?.data}');
    throw ApiException(_handleDioError(e));
  } catch (e) {
    print('DEBUG: Exception on verifyEmail - $e');
    throw ApiException('Erreur lors de la vérification: $e');
  }
}

  // Se connecter avec email et mot de passe
  Future<UserModel> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/v1/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        if (response.data == null) {
          throw ApiException('Réponse du serveur invalide');
        }
        
        final user = UserModel.fromJson(response.data!);
        if (user.token != null) {
          await _saveToken(user.token!);
          // Sauvegarder le flag "Remember me"
          await saveRememberMe(rememberMe);
        }
        return user;
      } else {
        final errorMessage = _extractErrorMessage(response.data);
        throw ApiException(
          errorMessage.isNotEmpty ? errorMessage : 'Email ou mot de passe incorrect',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ApiException(_handleDioError(e));
    } catch (e) {
      throw ApiException('Erreur lors de la connexion: $e');
    }
  }

  // Demander une réinitialisation de mot de passe
  Future<void> forgotPassword(String email) async {
    try {
      // Create a new Dio instance without default headers for this call
      final dioNoAuth = Dio(BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ));
      
      print('DEBUG: forgotPassword - Sending request for email: $email');
      final response = await dioNoAuth.post(
        '/api/v1/auth/forgot-password',
        queryParameters: {'email': email},
      );

      print('DEBUG: forgotPassword - Response statusCode: ${response.statusCode}');
      print('DEBUG: forgotPassword - Response data: ${response.data}');
      print('DEBUG: forgotPassword - Response headers: ${response.headers}');

      // Accepter tous les codes 2xx (200-299) ou null (succès)
      if (response.statusCode != null && response.statusCode! >= 300) {
        final errorMessage = _extractErrorMessage(response.data);
        print('DEBUG: forgotPassword - Error: $errorMessage with status ${response.statusCode}');
        throw ApiException(
          errorMessage.isNotEmpty 
              ? errorMessage 
              : 'Impossible d\'envoyer le code OTP de réinitialisation',
          statusCode: response.statusCode,
        );
      }
      print('DEBUG: forgotPassword - Success!');
    } on DioException catch (e) {
      print('DEBUG: DioException in forgotPassword - type: ${e.type}');
      print('DEBUG: DioException in forgotPassword - statusCode: ${e.response?.statusCode}');
      print('DEBUG: DioException in forgotPassword - message: ${e.message}');
      print('DEBUG: DioException in forgotPassword - error: ${e.error}');
      print('DEBUG: DioException in forgotPassword - response: ${e.response?.data}');
      throw ApiException(_handleDioError(e));
    } catch (e) {
      print('DEBUG: Exception in forgotPassword - $e');
      throw ApiException('Erreur lors de la demande de réinitialisation: $e');
    }
  }

  // Réinitialiser le mot de passe avec OTP
  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    try {
      // Create a new Dio instance without default headers for this call
      final dioNoAuth = Dio(BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ));
      
      print('DEBUG: resetPassword - Sending request');
      final response = await dioNoAuth.post(
        '/api/v1/auth/reset-password',
        queryParameters: {
          'email': email,
          'otp': otp,
          'newPassword': newPassword,
        },
      );

      print('DEBUG: resetPassword - Response statusCode: ${response.statusCode}');
      print('DEBUG: resetPassword - Response data: ${response.data}');

      // Accepter tous les codes 2xx (200-299) ou null (succès)
      if (response.statusCode != null && response.statusCode! >= 300) {
        final errorMessage = _extractErrorMessage(response.data);
        throw ApiException(
          errorMessage.isNotEmpty 
              ? errorMessage 
              : 'Échec de la réinitialisation du mot de passe',
          statusCode: response.statusCode,
        );
      }
      print('DEBUG: resetPassword - Success!');
    } on DioException catch (e) {
      print('DEBUG: DioException in resetPassword - type: ${e.type}');
      print('DEBUG: DioException in resetPassword - error: ${e.error}');
      throw ApiException(_handleDioError(e));
    } catch (e) {
      print('DEBUG: Exception in resetPassword - $e');
      throw ApiException('Erreur lors de la réinitialisation du mot de passe: $e');
    }
  }

  // Méthodes utilitaires pour la gestion des erreurs
  String _extractErrorMessage(dynamic responseData) {
    if (responseData == null) return '';
    
    try {
      if (responseData is Map) {
        return responseData['message']?.toString() ?? 
               responseData['error']?.toString() ?? 
               '';
      } else if (responseData is String) {
        // Essayer de parser la réponse comme JSON
        try {
          final json = jsonDecode(responseData) as Map<String, dynamic>;
          return json['message']?.toString() ?? 
                 json['error']?.toString() ?? 
                 '';
        } catch (_) {
          return responseData;
        }
      }
      return '';
    } catch (_) {
      return '';
    }
  }

  // Gestion des erreurs Dio
  String _handleDioError(DioException e) {
    if (e.response != null) {
      // Erreur de réponse du serveur (4xx, 5xx)
      final statusCode = e.response?.statusCode;
      final responseData = e.response?.data;
      
      if (statusCode == 401) {
        return 'Non autorisé. Veuillez vous reconnecter.';
      } else if (statusCode == 403) {
        return 'Accès refusé. Vous n\'avez pas les permissions nécessaires.';
      } else if (statusCode == 404) {
        return 'Ressource non trouvée.';
      } else if (statusCode == 500) {
        return 'Erreur interne du serveur. Veuillez réessayer plus tard.';
      } else if (responseData != null) {
        return _extractErrorMessage(responseData);
      }
    } else if (e.type == DioExceptionType.connectionTimeout ||
               e.type == DioExceptionType.receiveTimeout) {
      return 'Délai de connexion dépassé. Vérifiez votre connexion internet.';
    } else if (e.type == DioExceptionType.connectionError) {
      return 'Impossible de se connecter au serveur. Vérifiez votre connexion internet.';
    } else if (e.type == DioExceptionType.cancel) {
      return 'Requête annulée';
    }
    
    return 'Une erreur est survenue. Veuillez réessayer.';
  }

  // Changer le mot de passe
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final response = await _dio.post(
        '/api/v1/auth/change-password',
        data: {
          'oldPassword': oldPassword,
          'newPassword': newPassword,
        },
      );

      print('DEBUG: changePassword - statusCode: ${response.statusCode}');
      
      if (response.statusCode != null && response.statusCode! >= 300) {
        final errorMessage = _extractErrorMessage(response.data);
        throw ApiException(
          errorMessage.isNotEmpty 
              ? errorMessage 
              : 'Erreur lors du changement de mot de passe',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      print('DEBUG: DioException in changePassword - ${e.type}');
      throw ApiException(_handleDioError(e));
    } catch (e) {
      print('DEBUG: Exception in changePassword - $e');
      throw ApiException('Erreur lors du changement de mot de passe: $e');
    }
  }

  // Mettre à jour le profil
  Future<Map<String, dynamic>> updateProfile({
    required String displayName,
    required String phoneNumber,
    required String address,
    required String bio,
    required String dateOfBirth,
    required String email,
  }) async {
    try {
      final response = await _dio.put(
        '/api/v1/auth/profile',
        data: {
          'displayName': displayName,
          'phoneNumber': phoneNumber,
          'address': address,
          'bio': bio,
          'dateOfBirth': dateOfBirth,
          'email': email,
        },
      );

      print('DEBUG: updateProfile - statusCode: ${response.statusCode}');
      print('DEBUG: updateProfile - response: ${response.data}');
      
      if (response.statusCode != null && response.statusCode! >= 300) {
        final errorMessage = _extractErrorMessage(response.data);
        throw ApiException(
          errorMessage.isNotEmpty 
              ? errorMessage 
              : 'Erreur lors de la mise à jour du profil',
          statusCode: response.statusCode,
        );
      }

      // Retourner les données mises à jour
      return response.data ?? {};
    } on DioException catch (e) {
      print('DEBUG: DioException in updateProfile - ${e.type}');
      throw ApiException(_handleDioError(e));
    } catch (e) {
      print('DEBUG: Exception in updateProfile - $e');
      throw ApiException('Erreur lors de la mise à jour du profil: $e');
    }
  }

  // Upload de la photo de profil
  Future<Map<String, dynamic>> uploadProfilePicture(File imageFile) async {
    try {
      final fileName = imageFile.path.split(Platform.pathSeparator).last;
      // detect mime type from file extension
      String ext = fileName.contains('.') ? fileName.split('.').last.toLowerCase() : '';
      String mimeType = 'application/octet-stream';
      if (ext == 'jpg' || ext == 'jpeg') mimeType = 'image/jpeg';
      else if (ext == 'png') mimeType = 'image/png';
      else if (ext == 'gif') mimeType = 'image/gif';

      final multipart = await MultipartFile.fromFile(
        imageFile.path,
        filename: fileName,
        contentType: MediaType(mimeType.split('/')[0], mimeType.split('/')[1]),
      );

      // Send multiple possible keys to accommodate backend expectations
      final formData = FormData.fromMap({
        'profilePicture': multipart,
        'file': multipart,
        'image': multipart,
        'photo': multipart,
      });

      // Try PUT first, if server rejects with 4xx/5xx, try POST as fallback
      Response? response;
      try {
        response = await _dio.put('/api/v1/auth/profile-picture', data: formData);
      } on DioException catch (e) {
        // If server returns a response (e.response) we may try POST fallback for 4xx errors
        if (e.response != null && (e.response!.statusCode == 400 || (e.response!.statusCode != null && e.response!.statusCode! >= 400))) {
          // try POST fallback
          response = await _dio.post('/api/v1/auth/profile-picture', data: formData);
        } else {
          rethrow;
        }
      }

      print('DEBUG: uploadProfilePicture - statusCode: ${response.statusCode}');
      print('DEBUG: uploadProfilePicture - response: ${response.data}');

      if (response.statusCode != null && response.statusCode! >= 300) {
        final errorMessage = _extractErrorMessage(response.data);
        throw ApiException(
          errorMessage.isNotEmpty 
              ? errorMessage 
              : 'Erreur lors de l\'upload de la photo',
          statusCode: response.statusCode,
        );
      }

      return response.data ?? {};
    } on DioException catch (e) {
      print('DEBUG: DioException in uploadProfilePicture - ${e.type}');
      throw ApiException(_handleDioError(e));
    } catch (e) {
      print('DEBUG: Exception in uploadProfilePicture - $e');
      throw ApiException('Erreur lors de l\'upload de la photo: $e');
    }
  }

  // Se déconnecter
  Future<void> logout() async {
    await _clearToken();
  }

  // Vérifier si l'utilisateur est connecté
  bool get isLoggedIn => _authToken != null;
  String? get token => _authToken;
}
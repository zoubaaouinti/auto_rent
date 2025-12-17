import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';
import '../services/auth_service.dart';

// Fournisseur pour les SharedPreferences
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferencesProvider was not initialized');
});

// Fournisseur pour le service d'authentification
final authServiceProvider = Provider<AuthService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return AuthService(prefs);
});

// Fournisseur pour l'état d'authentification
final authStateProvider = StateNotifierProvider<AuthNotifier, AsyncValue<UserModel?>>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService);
});

// Fournisseur pour accéder facilement à l'état d'authentification
final currentUserProvider = Provider<UserModel?>((ref) {
  final state = ref.watch(authStateProvider);
  return state.when(
    data: (user) => user,
    loading: () => null,
    error: (error, stack) => null,
  );
});

// Fournisseur pour vérifier si l'utilisateur est connecté
final isAuthenticatedProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user != null && user.token != null;
});

class AuthNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  final AuthService _authService;
  
  AuthNotifier(this._authService) : super(const AsyncValue.loading()) {
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    state = const AsyncValue.loading();
    try {
      final token = _authService.token;
      if (token != null) {
        // Pour le moment, on crée un utilisateur avec juste le token
        // Vous pouvez ajouter une méthode pour récupérer plus d'informations utilisateur
        state = AsyncValue.data(
          UserModel(
            id: 'temp-id',
            email: 'user@example.com',
            token: token,
            emailVerified: true,
          )
        );
      } else {
        state = const AsyncValue.data(null);
      }
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  Future<void> login(String email, String password, {bool rememberMe = false}) async {
    try {
      state = const AsyncValue.loading();
      final user = await _authService.login(email: email, password: password, rememberMe: rememberMe);
      state = AsyncValue.data(user);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  Future<void> register({
    required String email,
    required String password,
  }) async {
    try {
      state = const AsyncValue.loading();
      final user = await _authService.register(
        email: email,
        password: password,
      );
      state = AsyncValue.data(user);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  Future<void> verifyEmail(String email, String otp) async {
    try {
      state = const AsyncValue.loading();
      await _authService.verifyEmail(email: email, otp: otp);
      // Mettre à jour l'état de l'utilisateur après vérification
      if (state.hasValue && state.value != null) {
        state = AsyncValue.data(state.value!.copyWith(emailVerified: true));
      }
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  Future<void> forgotPassword(String email) async {
    try {
      state = const AsyncValue.loading();
      await _authService.forgotPassword(email);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    try {
      state = const AsyncValue.loading();
      await _authService.resetPassword(
        email: email,
        otp: otp,
        newPassword: newPassword,
      );
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      state = const AsyncValue.loading();
      await _authService.logout();
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }
}

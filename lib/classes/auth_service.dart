import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthResult {
  final User? user;
  final String? errorMessage;

  AuthResult({this.user, this.errorMessage});

  bool get success => user != null;
}

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;
  
  User? get currentUser => _supabase.auth.currentUser;

  Future<AuthResult> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'username': username},
      );
      
      if (response.user != null) {
        return AuthResult(user: response.user);
      } else {
        return AuthResult(errorMessage: 'Usuário não retornado após o cadastro.');
      }
    } on AuthException catch (e) {
      debugPrint("AuthException no SignUp: ${e.message}");
      return AuthResult(errorMessage: 'Falha no cadastro: ${e.message}');
    } catch (e) {
      debugPrint("Erro genérico no SignUp: $e");
      return AuthResult(errorMessage: 'Ocorreu um erro inesperado. Tente novamente.');
    }
  }

  Future<AuthResult> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      if (response.user != null) {
        return AuthResult(user: response.user);
      } else {
        return AuthResult(errorMessage: 'Usuário não retornado após o login.');
      }
    } on AuthException catch (e) {
      debugPrint("AuthException no SignIn: ${e.message}");
      return AuthResult(errorMessage: 'Falha no login: ${e.message}');
    } catch (e) {
      debugPrint("Erro genérico no SignIn: $e");
      return AuthResult(errorMessage: 'Ocorreu um erro inesperado. Tente novamente.');
    }
  }

  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      debugPrint("Erro ao fazer signOut: $e");
    }
  }
}
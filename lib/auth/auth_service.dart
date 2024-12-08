import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Метод для входа с использованием email и пароля
  Future<AuthResponse> signInWithEmailPassword(String email, String password) async {
    try {
      return await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow; // Перебрасываем ошибку для обработки на уровне вызывающего кода
    }
  }

  // Метод для регистрации с использованием email и пароля
  Future<AuthResponse> signUpWithEmailPassword(String email, String password) async {
    try {
      return await _supabase.auth.signUp(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow; // Перебрасываем ошибку для обработки на уровне вызывающего кода
    }
  }

  // Метод для выхода из системы
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      rethrow; // Перебрасываем ошибку для обработки на уровне вызывающего кода
    }
  }

  // Метод для получения текущего email пользователя
  String? getCurrenUserEmail() {
    final session = _supabase.auth.currentSession;
    final user = session?.user;
    return user?.email;
  }

  // Метод для получения текущего пользователя
  User? getCurrentUser() {
    final session = _supabase.auth.currentSession;
    return session?.user;
  }

  // Метод для проверки, вошел ли пользователь в систему
  bool isUserLoggedIn() {
    return _supabase.auth.currentSession != null;
  }

  // Метод для получения потока изменений состояния аутентификации
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;
}
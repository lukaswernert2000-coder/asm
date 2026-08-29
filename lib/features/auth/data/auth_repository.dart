import 'package:asm/core/errors/error_mapper.dart';
import 'package:asm/features/auth/domain/asm_user.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class AuthRepository {
  Stream<AsmUser?> authStateChanges();

  /// Roher Auth-Event-Stream — separat von [authStateChanges], weil nur hier
  /// zwischen einem normalen Login/Auth-Callback (`signedIn`) und einem
  /// Passwort-Reset-Link (`passwordRecovery`) unterschieden werden kann.
  /// Treibt das globale Redirect in `app.dart`.
  Stream<AuthChangeEvent> authEvents();
  Future<void> signUp({
    required String email,
    required String password,
    Map<String, dynamic>? data,
  });
  Future<void> signIn({required String email, required String password});
  Future<void> resendConfirmation(String email);
  Future<void> signOut();
  Future<void> resetPassword(String email);
  Future<void> updatePassword(String newPassword);
  Future<void> deleteAccount();
}

class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository(this._client);

  final SupabaseClient _client;

  @override
  Stream<AsmUser?> authStateChanges() {
    return _client.auth.onAuthStateChange.map(
      (state) => _toAsmUser(state.session?.user),
    );
  }

  @override
  Stream<AuthChangeEvent> authEvents() {
    return _client.auth.onAuthStateChange.map((state) => state.event);
  }

  AsmUser? _toAsmUser(User? user) {
    if (user == null) return null;
    return AsmUser(
      id: user.id,
      email: user.email ?? '',
      emailConfirmed: user.emailConfirmedAt != null,
    );
  }

  @override
  Future<void> signUp({
    required String email,
    required String password,
    Map<String, dynamic>? data,
  }) async {
    try {
      await _client.auth.signUp(email: email, password: password, data: data);
    } catch (error) {
      throw mapError(error);
    }
  }

  @override
  Future<void> signIn({required String email, required String password}) async {
    try {
      await _client.auth.signInWithPassword(email: email, password: password);
    } catch (error) {
      throw mapError(error);
    }
  }

  @override
  Future<void> resendConfirmation(String email) async {
    try {
      await _client.auth.resend(email: email, type: OtpType.signup);
    } catch (error) {
      throw mapError(error);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (error) {
      throw mapError(error);
    }
  }

  @override
  Future<void> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(
        email,
        redirectTo: 'asm://reset-password',
      );
    } catch (error) {
      throw mapError(error);
    }
  }

  @override
  Future<void> updatePassword(String newPassword) async {
    try {
      await _client.auth.updateUser(UserAttributes(password: newPassword));
    } catch (error) {
      throw mapError(error);
    }
  }

  @override
  Future<void> deleteAccount() async {
    try {
      await _client.functions.invoke('delete-account');
    } catch (error) {
      throw mapError(error);
    }
  }
}

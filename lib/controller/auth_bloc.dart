import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../core/services/auth_service.dart';

sealed class AuthEvent {}

class AuthStarted extends AuthEvent {}

class GoogleSignInPressed extends AuthEvent {}

class SignOutPressed extends AuthEvent {}

class AuthState {
  const AuthState({
    this.user,
    this.checking = false,
    this.busy = false,
    this.error,
  });

  final User? user;
  final bool checking;
  final bool busy;
  final String? error;
}

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(this._service) : super(const AuthState(checking: true)) {
    on<AuthStarted>((event, emit) async {
      await emit.forEach(
        _service.session,
        onData: (user) => AuthState(user: user),
      );
    });
    on<GoogleSignInPressed>(_signIn);
    on<SignOutPressed>(_signOut);
  }

  final AuthService _service;

  Future<void> _signIn(
    GoogleSignInPressed event,
    Emitter<AuthState> emit,
  ) async {
    if (state.busy || state.user != null) return;
    emit(const AuthState(busy: true));
    try {
      await _service.signIn();
    } on GoogleSignInException catch (error) {
      emit(
        AuthState(
          error: error.code == GoogleSignInExceptionCode.canceled
              ? null
              : 'Google sign-in is unavailable. Please try again.',
        ),
      );
    } catch (_) {
      emit(
        const AuthState(
          error: 'Could not sign in. Check your connection and try again.',
        ),
      );
    }
  }

  Future<void> _signOut(SignOutPressed event, Emitter<AuthState> emit) async {
    final user = state.user;
    if (state.busy || user == null) return;
    emit(AuthState(user: user, busy: true));
    try {
      await _service.signOut();
    } catch (_) {
      if (state.user != null) {
        emit(
          AuthState(user: user, error: 'Could not sign out. Please try again.'),
        );
      }
    }
  }
}

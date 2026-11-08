import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/user_model.dart';
import '../repositories/auth_repository.dart';

abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthRestoring extends AuthState {}
class Authenticated extends AuthState {
  final UserModel user;
  final String accessToken;
  const Authenticated(this.user, this.accessToken);
  @override
  List<Object?> get props => [user, accessToken];
}
class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
  @override
  List<Object?> get props => [message];
}

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository authRepository;
  AuthCubit(this.authRepository) : super(AuthInitial());

  /// Coba pulihkan sesi tersimpan agar user tidak perlu login ulang.
  Future<void> tryRestoreSession() async {
    emit(AuthRestoring());
    try {
      final session = await authRepository.restoreSession();
      if (session != null) {
        emit(Authenticated(session['user'] as UserModel, session['accessToken'] as String));
      } else {
        emit(AuthInitial());
      }
    } catch (_) {
      emit(AuthInitial());
    }
  }

  Future<void> login(String email, String password) async {
    if (email.trim().isEmpty || password.isEmpty) {
      emit(const AuthError('Email dan kata sandi wajib diisi.'));
      return;
    }
    emit(AuthLoading());
    try {
      final res = await authRepository.login(email.trim(), password);
      emit(Authenticated(res['user'] as UserModel, res['accessToken'] as String));
    } catch (e) {
      // AuthRepository sudah membungkus pesan ramah pengguna dalam Exception
      final raw = e.toString();
      emit(AuthError(raw.replaceFirst('Exception: ', '')));
    }
  }

  Future<void> logout() async {
    await authRepository.logout();
    emit(AuthInitial());
  }
}
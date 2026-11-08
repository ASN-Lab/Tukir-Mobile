import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import '../models/user_model.dart';

class AuthRepository {
  final Dio _dio = Dio(BaseOptions(baseUrl: AppConfig.apiBaseUrl));
  String? _accessToken;
  UserModel? _user;

  String? get accessToken => _accessToken;
  UserModel? get user => _user;

  static const _kToken = 'tukir_access_token';
  static const _kUserId = 'tukir_user_id';
  static const _kUserName = 'tukir_user_name';
  static const _kUserEmail = 'tukir_user_email';
  static const _kUserRole = 'tukir_user_role';

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dio.post('/auth/login', data: {'email': email, 'password': password});
      final data = response.data as Map<String, dynamic>;
      _accessToken = data['token'] as String;
      _user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
      await _persistSession();
      return {'user': _user, 'accessToken': _accessToken};
    } on DioException catch (e) {
      throw Exception(_friendlyMessage(e));
    }
  }

  /// Pulihkan sesi tersimpan (auto-login) saat app dibuka kembali.
  Future<Map<String, dynamic>?> restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_kToken);
    if (token == null || token.isEmpty) return null;

    _accessToken = token;
    _user = UserModel(
      id: prefs.getString(_kUserId) ?? '',
      name: prefs.getString(_kUserName) ?? '',
      email: prefs.getString(_kUserEmail) ?? '',
      role: prefs.getString(_kUserRole) ?? '',
    );
    return {'user': _user, 'accessToken': _accessToken};
  }

  Future<void> logout() async {
    _accessToken = null;
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kToken);
    await prefs.remove(_kUserId);
    await prefs.remove(_kUserName);
    await prefs.remove(_kUserEmail);
    await prefs.remove(_kUserRole);
  }

  Future<void> _persistSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kToken, _accessToken!);
    await prefs.setString(_kUserId, _user!.id);
    await prefs.setString(_kUserName, _user!.name);
    await prefs.setString(_kUserEmail, _user!.email);
    await prefs.setString(_kUserRole, _user!.role);
  }

  /// Terjemahkan DioException menjadi pesan ramah pengguna (Bahasa Indonesia).
  String _friendlyMessage(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return 'Koneksi ke server habis waktu. Periksa jaringan Anda dan coba lagi.';
    }
    if (e.type == DioExceptionType.connectionError) {
      return 'Tidak dapat terhubung ke server. Pastikan perangkat berada di jaringan yang sama.';
    }
    final status = e.response?.statusCode;
    if (status == 401) {
      return 'Email atau kata sandi salah. Periksa kembali kredensial Anda.';
    }
    if (status == 422) {
      return 'Data yang dikirim tidak valid. Periksa kembali isian Anda.';
    }
    if (status == 403) {
      return 'Anda tidak memiliki akses untuk tindakan ini.';
    }
    if (status != null && status >= 500) {
      return 'Terjadi masalah pada server. Coba lagi beberapa saat.';
    }
    return 'Terjadi kesalahan tak terduga. Silakan coba lagi.';
  }
}

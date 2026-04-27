import 'package:get/get.dart';

class ApiService extends GetConnect {
  static const String _baseUrl = 'https://unblended-jumble-striving.ngrok-free.dev/api/v1';

  @override
  void onInit() {
    httpClient.baseUrl = _baseUrl;
    httpClient.timeout = const Duration(seconds: 10);

    // Tambah default headers
    httpClient.addRequestModifier<dynamic>((request) {
      request.headers['Accept'] = 'application/json';
      request.headers['Content-Type'] = 'application/json';
      return request;
    });

    super.onInit();
  }

  // ─── LOGIN ─────────────────────────────────────────────
  Future<Response<dynamic>> login({
    required String email,
    required String password,
  }) {
    return post('/auth/login', {
      'email': email,
      'password': password,
    });
  }

  // ─── SEND OTP ──────────────────────────────────────────
  Future<Response<dynamic>> sendOtp({
    required String email,
  }) {
    return post('/auth/request-otp', {
      'email': email,
    });
  }

  // ─── VERIFY OTP ────────────────────────────────────────
  Future<Response<dynamic>> verifyOtp({
    required String email,
    required String otp,
  }) {
    return post('/auth/verify-otp', {
      'email': email,
      'otp': otp,
    });
  }

  // ─── REGISTER ──────────────────────────────────────────
  Future<Response<dynamic>> register({
    required String email,
    required String username,
    required String password,
    required String passwordConfirmation,
    required String otp,
  }) {
    return post('/auth/register', {
      'email': email,
      'username': username,
      'password': password,
      'password_confirmation': passwordConfirmation,
      'otp': otp,
    });
  }
}

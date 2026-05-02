import 'package:get/get.dart';

class ApiService extends GetConnect {
  static const String _baseUrl =
      'https://crumpled-judge-acetone.ngrok-free.dev/api/v1';

  @override
  void onInit() {
    httpClient.baseUrl = _baseUrl;
    httpClient.timeout = const Duration(seconds: 10);

    // Default headers
    httpClient.addRequestModifier<dynamic>((request) {
      request.headers['Accept'] = 'application/json';
      request.headers['Content-Type'] = 'application/json';
      request.headers['ngrok-skip-browser-warning'] = 'true';
      return request;
    });

    super.onInit();
  }

  // ─── AUTH ──────────────────────────────────────────────

  Future<Response<dynamic>> login({
    required String email,
    required String password,
  }) {
    return post('/auth/login', {
      'email': email,
      'password': password,
    });
  }

  Future<Response<dynamic>> sendOtp({required String email}) {
    return post('/auth/request-otp', {'email': email});
  }

  Future<Response<dynamic>> verifyOtp({
    required String email,
    required String otp,
  }) {
    return post('/auth/verify-otp', {'email': email, 'otp': otp});
  }

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

  // ─── USERS ─────────────────────────────────────────────

  Future<Response<dynamic>> getMe(String token) {
    return get('/users/me', headers: _auth(token));
  }

  Future<Response<dynamic>> updateMe(
      Map<String, dynamic> body, String token) {
    return patch('/users/me', body, headers: _auth(token));
  }

  /// Cari user by username (untuk tambah debt/group member)
  Future<Response<dynamic>> searchUser(String username, String token) {
    return get('/users/search?username=$username', headers: _auth(token));
  }

  // ─── PAYMENT METHODS ───────────────────────────────────

  Future<Response<dynamic>> getPaymentMethods(String token) {
    return get('/users/me/payment-methods', headers: _auth(token));
  }

  Future<Response<dynamic>> addPaymentMethod(
      Map<String, dynamic> body, String token) {
    return post('/users/me/payment-methods', body, headers: _auth(token));
  }

  Future<Response<dynamic>> updatePaymentMethod(
      int id, Map<String, dynamic> body, String token) {
    return patch('/users/me/payment-methods/$id', body,
        headers: _auth(token));
  }

  Future<Response<dynamic>> deletePaymentMethod(int id, String token) {
    return delete('/users/me/payment-methods/$id', headers: _auth(token));
  }

  // ─── DEBTS ─────────────────────────────────────────────

  Future<Response<dynamic>> getDebts(String token) {
    return get('/debts', headers: _auth(token));
  }

  Future<Response<dynamic>> createDebt(
      Map<String, dynamic> body, String token) {
    return post('/debts', body, headers: _auth(token));
  }

  Future<Response<dynamic>> getDebtDetail(int id, String token) {
    return get('/debts/$id', headers: _auth(token));
  }

  Future<Response<dynamic>> updateDebt(
      int id, Map<String, dynamic> body, String token) {
    return patch('/debts/$id', body, headers: _auth(token));
  }

  Future<Response<dynamic>> deleteDebt(int id, String token) {
    return delete('/debts/$id', headers: _auth(token));
  }

  /// Konfirmasi debt — dilakukan oleh otherUser (pihak lawan)
  Future<Response<dynamic>> confirmDebt(int id, String token) {
    return patch('/debts/$id/confirm', {}, headers: _auth(token));
  }

  /// Ajukan pelunasan — membuat settlement request baru
  /// Backend: POST /settlement-requests dengan body { "debtId": id }
 Future<Response<dynamic>> requestSettlement(int id, String token) {
    return post(
      '/debts/$id/settlement-request', 
      {}, // Body dikosongkan karena backend hanya membaca ID dari URL params
      headers: _auth(token),
    );
  }

  // ─── SETTLEMENT REQUESTS ───────────────────────────────

  Future<Response<dynamic>> getSettlements(String token) {
    return get('/settlement-requests', headers: _auth(token));
  }

  /// Setujui settlement — dilakukan oleh toUser (penerima klaim)
  Future<Response<dynamic>> approveSettlement(int id, String token) {
    return patch('/settlement-requests/$id/approve', {},
        headers: _auth(token));
  }

  /// Tolak settlement — dilakukan oleh toUser
  // Future<Response<dynamic>> rejectSettlement(int id, String token) {
  //   return patch('/settlement-requests/$id/reject', {},
  //       headers: _auth(token));
  // }

  // ─── GROUPS ────────────────────────────────────────────

  Future<Response<dynamic>> getGroups(String token) {
    return get('/groups', headers: _auth(token));
  }

  Future<Response<dynamic>> createGroup(
      Map<String, dynamic> body, String token) {
    return post('/groups', body, headers: _auth(token));
  }

  Future<Response<dynamic>> getGroupDetail(int id, String token) {
    return get('/groups/$id', headers: _auth(token));
  }

  Future<Response<dynamic>> updateGroup(
      int id, Map<String, dynamic> body, String token) {
    return patch('/groups/$id', body, headers: _auth(token));
  }

  Future<Response<dynamic>> deleteGroup(int id, String token) {
    return delete('/groups/$id', headers: _auth(token));
  }

  /// Tambah anggota — backend menerima username (bukan userId)
  Future<Response<dynamic>> addGroupMember(
      int groupId, String username, String token) {
    return post(
      '/groups/$groupId/members',
      {'username': username},
      headers: _auth(token),
    );
  }

  /// Keluarkan anggota — :userId adalah ID integer user target
  Future<Response<dynamic>> removeGroupMember(
      int groupId, int userId, String token) {
    return delete('/groups/$groupId/members/$userId',
        headers: _auth(token));
  }

  // ─── GROUP TRANSACTIONS ────────────────────────────────

  Future<Response<dynamic>> getGroupTransactions(
      int groupId, String token) {
    return get('/group-transactions/group/$groupId',
        headers: _auth(token));
  }

  Future<Response<dynamic>> createGroupTransaction(
      int groupId, Map<String, dynamic> body, String token) {
    return post('/group-transactions/group/$groupId', body,
        headers: _auth(token));
  }

  Future<Response<dynamic>> deleteGroupTransaction(
      int id, String token) {
    return delete('/group-transactions/$id', headers: _auth(token));
  }

  /// Buat settlement request untuk group transaction
  Future<Response<dynamic>> createGroupSettlement(
      int groupTransactionId, String token) {
    return post(
      '/settlement-requests',
      {'groupTransactionId': groupTransactionId},
      headers: _auth(token),
    );
  }

  /// Konfirmasi group transaction — dilakukan oleh anggota lain (bukan creator)
  Future<Response> rejectDebt(int id, String token) {
    return patch('/debts/$id/reject', {},
        headers: {'Authorization': 'Bearer $token'});
  }

  Future<Response> confirmSettlement(int id, String token) {
    return patch('/debts/$id/settlement-confirm', {},
        headers: {'Authorization': 'Bearer $token'});
  }

  Future<Response> rejectSettlement(int id, String token) {
    return patch('/debts/$id/settlement-reject', {},
        headers: {'Authorization': 'Bearer $token'});
  }
  // ─── HELPER ────────────────────────────────────────────
  Map<String, String> _auth(String token) =>
      {'Authorization': 'Bearer $token'};
}

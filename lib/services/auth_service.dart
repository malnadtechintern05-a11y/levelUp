import 'package:shared_preferences/shared_preferences.dart';
import 'api_client.dart';

class AuthService {
  static final AuthService instance = AuthService._internal();
  AuthService._internal();

  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'auth_user_id';
  static const String _usernameKey = 'auth_username';

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_userIdKey);
  }

  Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_usernameKey);
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  Future<Map<String, dynamic>> login(String identifier, String password) async {
    final response = await ApiClient.instance.post('/auth/login.php', body: {
      'identifier': identifier,
      'password': password,
    });

    if (response['status'] == 'success' && response['token'] != null) {
      final token = response['token'] as String;
      final user = response['user'] as Map<String, dynamic>;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
      await prefs.setInt(_userIdKey, user['id'] as int);
      await prefs.setString(_usernameKey, user['username'] as String);
      await prefs.setBool('is_logged_in', true);
    }

    return response;
  }

  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
    required String confirmPassword,
    String avatarId = 'hero1',
    String? displayName,
  }) async {
    final response = await ApiClient.instance.post('/auth/register.php', body: {
      'username': username,
      'email': email,
      'password': password,
      'confirm_password': confirmPassword,
      'avatar_id': avatarId,
      'display_name': displayName ?? username,
    });

    if (response['status'] == 'success' && response['token'] != null) {
      final token = response['token'] as String;
      final user = response['user'] as Map<String, dynamic>;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
      await prefs.setInt(_userIdKey, user['id'] as int);
      await prefs.setString(_usernameKey, user['username'] as String);
      await prefs.setBool('is_logged_in', true);
    }

    return response;
  }

  Future<void> logout() async {
    try {
      await ApiClient.instance.post('/auth/logout.php');
    } catch (_) {
      // Ignore network failures on logout
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_usernameKey);
    await prefs.setBool('is_logged_in', false);
  }

  Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final response = await ApiClient.instance.get('/auth/me.php');
      if (response['status'] == 'success' && response['user'] != null) {
        return response['user'] as Map<String, dynamic>;
      }
    } catch (_) {
      return null;
    }
    return null;
  }
}

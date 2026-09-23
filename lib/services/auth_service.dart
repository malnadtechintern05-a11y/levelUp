import 'package:shared_preferences/shared_preferences.dart';
import 'api_client.dart';
import '../helpers/security_helper.dart';

class AuthService {
  static final AuthService instance = AuthService._internal();
  AuthService._internal();

  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'auth_user_id';
  static const String _usernameKey = 'auth_username';
  static const String _userRoleKey = 'auth_role';
  static const String _localHashPrefix = 'local_user_hash_';

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_userIdKey);
  }

  Future<String> getUserIdString() async {
    final id = await getUserId();
    if (id != null && id > 0) {
      return id.toString();
    }
    final uname = await getUsername();
    if (uname != null && uname.isNotEmpty) {
      return uname.toLowerCase();
    }
    return 'hero';
  }

  Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_usernameKey);
  }

  Future<String> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userRoleKey) ?? 'user';
  }

  Future<bool> isAdmin() async {
    final role = await getRole();
    return role.toLowerCase() == 'admin';
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    final prefs = await SharedPreferences.getInstance();
    final isFlagged = prefs.getBool('is_logged_in') ?? false;
    return (token != null && token.isNotEmpty) || isFlagged;
  }

  Future<Map<String, dynamic>> login(String identifier, String password) async {
    try {
      final response = await ApiClient.instance.post('/auth/login.php', body: {
        'identifier': identifier,
        'password': password,
      });

      if (response['status'] == 'success' && response['token'] != null) {
        final token = response['token'] as String;
        final user = response['user'] as Map<String, dynamic>;
        final role = user['role']?.toString() ?? (user['is_admin'] == 1 || user['is_admin'] == true ? 'admin' : 'user');

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_tokenKey, token);
        await prefs.setInt(_userIdKey, user['id'] as int);
        await prefs.setString(_usernameKey, user['username'] as String);
        await prefs.setString(_userRoleKey, role);
        await prefs.setBool('is_logged_in', true);

        // Store secure local hash for offline fallback verification
        final cleanIdentifier = identifier.trim().toLowerCase();
        await prefs.setString('$_localHashPrefix$cleanIdentifier', SecurityHelper.hashPassword(password));

        return response;
      }
      return response;
    } catch (e) {
      // Offline fallback: check stored secure hash
      final cleanIdentifier = identifier.trim().toLowerCase();
      final prefs = await SharedPreferences.getInstance();
      final storedHash = prefs.getString('$_localHashPrefix$cleanIdentifier');

      if (storedHash != null && SecurityHelper.verifyPassword(password, storedHash)) {
        await prefs.setString(_usernameKey, identifier.trim());
        await prefs.setBool('is_logged_in', true);
        return {
          'status': 'success',
          'message': 'Logged in offline.',
          'user': {
            'username': identifier.trim(),
            'display_name': identifier.trim(),
          }
        };
      }
      rethrow;
    }
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
      final role = user['role']?.toString() ?? 'user';

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
      await prefs.setInt(_userIdKey, user['id'] as int);
      await prefs.setString(_usernameKey, user['username'] as String);
      await prefs.setString(_userRoleKey, role);
      await prefs.setBool('is_logged_in', true);

      // Save local hashed password
      final cleanUname = username.trim().toLowerCase();
      await prefs.setString('$_localHashPrefix$cleanUname', SecurityHelper.hashPassword(password));
    }

    return response;
  }

  Future<Map<String, dynamic>> socialLogin({
    required String provider,
    required String username,
    String? email,
    String? displayName,
    String avatarId = 'hero1',
  }) async {
    try {
      final response = await ApiClient.instance.post('/auth/social_login.php', body: {
        'provider': provider,
        'username': username,
        'email': email ?? '${username.toLowerCase()}@$provider.levelup.com',
        'display_name': displayName ?? username,
        'avatar_id': avatarId,
      });

      if (response['status'] == 'success' && response['token'] != null) {
        final token = response['token'] as String;
        final user = response['user'] as Map<String, dynamic>;
        final role = user['role']?.toString() ?? 'user';

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_tokenKey, token);
        if (user['id'] is int) {
          await prefs.setInt(_userIdKey, user['id'] as int);
        } else if (user['id'] != null) {
          await prefs.setInt(_userIdKey, int.tryParse(user['id'].toString()) ?? 0);
        }
        await prefs.setString(_usernameKey, user['username']?.toString() ?? username);
        await prefs.setString(_userRoleKey, role);
        await prefs.setBool('is_logged_in', true);
        await prefs.setString('logged_in_username', user['username']?.toString() ?? username);
        await prefs.setString('current_username', user['username']?.toString() ?? username);

        return response;
      }
      return response;
    } catch (e) {
      // Fallback to local offline session if backend is temporarily unreachable
      final cleanUsername = username.trim();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_usernameKey, cleanUsername);
      await prefs.setBool('is_logged_in', true);
      await prefs.setString('logged_in_username', cleanUsername);
      await prefs.setString('current_username', cleanUsername);
      return {
        'status': 'success',
        'message': 'Logged in offline mode.',
        'user': {
          'id': cleanUsername.toLowerCase(),
          'username': cleanUsername,
          'display_name': displayName ?? cleanUsername,
          'level': 1,
          'total_xp': 0,
          'gold': 50,
        }
      };
    }
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
    await prefs.remove(_userRoleKey);
    await prefs.remove('current_username');
    await prefs.remove('hero_username');
    await prefs.remove('hero_avatar');
    await prefs.remove('logged_in_username');
    await prefs.setBool('is_logged_in', false);
  }

  Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final response = await ApiClient.instance.get('/auth/me.php');
      if (response['status'] == 'success' && response['user'] != null) {
        final user = response['user'] as Map<String, dynamic>;
        final role = user['role']?.toString();
        if (role != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_userRoleKey, role);
        }
        return user;
      }
    } catch (_) {
      return null;
    }
    return null;
  }
}

import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthService {
  static const String _userKey = 'user';
  static const String _isLoggedInKey = 'isLoggedIn';

  // Save user data to local storage
  static Future<void> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, user.id.toString() + ',' + user.username + ',' + user.email);
    await prefs.setBool(_isLoggedInKey, true);
  }

  // Get user data from local storage
  static Future<User?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString(_userKey);
    
    if (userString != null) {
      final parts = userString.split(',');
      return User(
        id: int.parse(parts[0]),
        username: parts[1],
        email: parts[2],
      );
    }
    return null;
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  // Logout user
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    await prefs.setBool(_isLoggedInKey, false);
  }
}
import 'package:shared_preferences/shared_preferences.dart';

class UserPreferences {
  static Future<void> saveUserData(String accessToken, String memberId, String nickname, String profileImage) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('accessToken', accessToken);
    await prefs.setString('memberId', memberId);
    await prefs.setString('nickname', nickname);
    await prefs.setString('profileImage', profileImage);
  }

  static Future<Map<String, String?>> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'accessToken': prefs.getString('accessToken'),
      'memberId': prefs.getString('memberId'),
      'nickname': prefs.getString('nickname'),
      'profileImage': prefs.getString('profileImage'),
    };
  }

  static Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken');
    await prefs.remove('memberId');
    await prefs.remove('nickname');
    await prefs.remove('profileImage');
  }
}

import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _keyIsLoggedIn = 'isLoggedIn';
  static const String _keyEmployeeId = 'employeeId';
  static const String _keyEmployeeName = 'employeeName';
  static const String _keyEmployeeEmail = 'employeeEmail';
  static const String _keyEmployeePhone = 'employeePhone';
  static const String _keyTeamId = 'teamId';

  // Check if employee is logged in
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  // Save login data
  static Future<void> saveLoginData({
    required String employeeId,
    required String employeeName,
    required String employeeEmail,
    String? employeePhone,
    String? teamId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, true);
    await prefs.setString(_keyEmployeeId, employeeId);
    await prefs.setString(_keyEmployeeName, employeeName);
    await prefs.setString(_keyEmployeeEmail, employeeEmail);
    if (employeePhone != null) {
      await prefs.setString(_keyEmployeePhone, employeePhone);
    }
    if (teamId != null) {
      await prefs.setString(_keyTeamId, teamId);
    }
  }

  // Get employee ID
  static Future<String?> getEmployeeId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyEmployeeId);
  }

  // Get employee name
  static Future<String?> getEmployeeName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyEmployeeName);
  }

  // Get employee email
  static Future<String?> getEmployeeEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyEmployeeEmail);
  }

  // Get employee phone
  static Future<String?> getEmployeePhone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyEmployeePhone);
  }

  // Get team ID
  static Future<String?> getTeamId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyTeamId);
  }

  // Logout - clear all data
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyIsLoggedIn);
    await prefs.remove(_keyEmployeeId);
    await prefs.remove(_keyEmployeeName);
    await prefs.remove(_keyEmployeeEmail);
    await prefs.remove(_keyEmployeePhone);
    await prefs.remove(_keyTeamId);
    await prefs.remove('token');
  }
}




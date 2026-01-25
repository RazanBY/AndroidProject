import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  static const String baseUrl = 'https://l1x9zzdh-5000.euw.devtunnels.ms/api/users';

  // Get token
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Get headers with token
  static Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // GET /api/users - Get all users (Manager only)
  static Future<Map<String, dynamic>> getAllUsers() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['users'] != null) {
          return {
            'success': true,
            'users': data['users'],
            'count': data['count'] ?? (data['users'] as List).length,
          };
        }
      }
      return {
        'success': false,
        'users': <Map<String, dynamic>>[],
        'message': 'Failed to load users',
      };
    } catch (e) {
      return {
        'success': false,
        'users': <Map<String, dynamic>>[],
        'message': 'Network error: $e',
      };
    }
  }

  // GET /api/users/:id - Get user by ID
  static Future<Map<String, dynamic>> getUserById(int userId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/$userId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['user'] != null) {
          return {
            'success': true,
            'user': data['user'],
          };
        }
      }
      return {
        'success': false,
        'message': 'User not found',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // POST /api/users - Add user (Manager only)
  static Future<Map<String, dynamic>> addUser({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String userType, // employee/manager
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: headers,
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'phone': phone,
          'user_type': userType,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Failed to add user',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // POST /api/users/:id/wallet/adjust - Adjust user wallet (Manager only)
  static Future<Map<String, dynamic>> adjustUserWallet(
    int userId, {
    required double amount,
    required String operation, // add/subtract
    String? reason,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/$userId/wallet/adjust'),
        headers: headers,
        body: jsonEncode({
          'amount': amount,
          'operation': operation,
          if (reason != null) 'reason': reason,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Failed to adjust wallet',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // DELETE /api/users/:id - Delete user (Manager only)
  static Future<Map<String, dynamic>> deleteUser(int userId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/$userId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Failed to delete user',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }
}


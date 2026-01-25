import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/job_model.dart';
import '../models/employee_model.dart';

class ApiService {
  // API base URL
  static const String baseUrl = 'https://l1x9zzdh-5000.euw.devtunnels.ms';
  static const String employeeBaseUrl = '$baseUrl/api/employee';
  static const String authBaseUrl = '$baseUrl/api/auth';

  // Get stored token
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Save token
  static Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  // Get headers with token
  static Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Login employee (uses /api/auth/login)
  static Future<Map<String, dynamic>> loginEmployee(
      String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$authBaseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['token'] != null) {
          await _saveToken(data['token']);
          // Return employee data in expected format
          return {
            'success': true,
            'employee': {
              'id': data['user']['id'].toString(),
              'name': data['user']['name'],
              'email': data['user']['email'],
              'phone': data['user']['phone'],
              'teamId': data['user']['team_id']?.toString(),
            },
            'message': data['message'] ?? 'Login successful',
          };
        }
        return data;
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Login failed: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // Get assigned jobs for employee
  static Future<List<Job>> getAssignedJobs(String employeeId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$employeeBaseUrl/jobs'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          return data.map((job) => Job.fromJson(job)).toList();
        }
        return [];
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Update job status
  static Future<Map<String, dynamic>> updateJobStatus(
      String jobId, String employeeId, String status) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$employeeBaseUrl/updateJobStatus'),
        headers: headers,
        body: jsonEncode({
          'jobId': jobId,
          'status': status,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Update failed: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // Get employee profile
  static Future<Employee?> getEmployeeProfile(String employeeId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$employeeBaseUrl/profile'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['employee'] != null) {
          return Employee.fromJson(data['employee']);
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Complete job with completion time
  static Future<Map<String, dynamic>> completeJob(
      String jobId, String employeeId, String completionDate, String completionTime) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$employeeBaseUrl/completeJob'),
        headers: headers,
        body: jsonEncode({
          'jobId': jobId,
          'completionDate': completionDate,
          'completionTime': completionTime,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Completion failed: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // Clear token on logout
  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }
}



import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/job_model.dart';
import '../models/employee_model.dart';

class ApiService {
  // API base URL
  static const String baseUrl = 'https://l1x9zzdh-5000.euw.devtunnels.ms/api/employee';

  // Login employee
  static Future<Map<String, dynamic>> loginEmployee(
      String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Login failed: ${response.statusCode}',
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
      final response = await http.get(
        Uri.parse('$baseUrl/jobs?employeeId=$employeeId'),
        headers: {'Content-Type': 'application/json'},
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
      final response = await http.post(
        Uri.parse('$baseUrl/updateJobStatus'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'jobId': jobId,
          'employeeId': employeeId,
          'status': status,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Update failed: ${response.statusCode}',
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
      final response = await http.get(
        Uri.parse('$baseUrl/profile?employeeId=$employeeId'),
        headers: {'Content-Type': 'application/json'},
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
      final response = await http.post(
        Uri.parse('$baseUrl/completeJob'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'jobId': jobId,
          'employeeId': employeeId,
          'completionDate': completionDate,
          'completionTime': completionTime,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Completion failed: ${response.statusCode}',
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



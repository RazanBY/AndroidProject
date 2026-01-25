import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/team_model.dart';

class TeamService {
  static const String baseUrl = 'https://l1x9zzdh-5000.euw.devtunnels.ms/api/teams';

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

  // GET /api/teams - Get all teams
  static Future<Map<String, dynamic>> getAllTeams() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['teams'] != null) {
          final teams = (data['teams'] as List)
              .map((team) => Team.fromJson(team))
              .toList();
          return {
            'success': true,
            'teams': teams,
            'count': data['count'] ?? teams.length,
          };
        }
      }
      return {
        'success': false,
        'teams': <Team>[],
        'message': 'Failed to load teams',
      };
    } catch (e) {
      return {
        'success': false,
        'teams': <Team>[],
        'message': 'Network error: $e',
      };
    }
  }

  // GET /api/teams/available - Get available teams only
  static Future<Map<String, dynamic>> getAvailableTeams() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/available'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['teams'] != null) {
          final teams = (data['teams'] as List)
              .map((team) => Team.fromJson(team))
              .toList();
          return {
            'success': true,
            'teams': teams,
            'count': data['count'] ?? teams.length,
          };
        }
      }
      return {
        'success': false,
        'teams': <Team>[],
        'message': 'Failed to load available teams',
      };
    } catch (e) {
      return {
        'success': false,
        'teams': <Team>[],
        'message': 'Network error: $e',
      };
    }
  }

  // GET /api/teams/:id - Get team by ID
  static Future<Map<String, dynamic>> getTeamById(int teamId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/$teamId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['team'] != null) {
          return {
            'success': true,
            'team': Team.fromJson(data['team']),
          };
        }
      }
      return {
        'success': false,
        'message': 'Team not found',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // POST /api/teams - Add team (Manager only)
  static Future<Map<String, dynamic>> addTeam({
    required String teamName,
    required String carNumber,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: headers,
        body: jsonEncode({
          'team_name': teamName,
          'car_number': carNumber,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Failed to add team',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // DELETE /api/teams/:id - Delete team (Manager only)
  static Future<Map<String, dynamic>> deleteTeam(int teamId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/$teamId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Failed to delete team',
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


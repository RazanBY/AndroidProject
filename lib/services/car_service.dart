import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/car_model.dart';

class CarService {
  static const String baseUrl = 'https://l1x9zzdh-5000.euw.devtunnels.ms/api/cars';

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

  // GET /api/cars - Get user's cars
  static Future<Map<String, dynamic>> getUserCars() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['cars'] != null) {
          final cars = (data['cars'] as List)
              .map((car) => Car.fromJson(car))
              .toList();
          return {
            'success': true,
            'cars': cars,
            'count': data['count'] ?? cars.length,
          };
        }
      }
      return {
        'success': false,
        'message': 'Failed to load cars',
        'cars': <Car>[],
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
        'cars': <Car>[],
      };
    }
  }

  // POST /api/cars - Add car (Manager only)
  static Future<Map<String, dynamic>> addCar({
    required String carModel,
    required String plateNumber,
    String? color,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: headers,
        body: jsonEncode({
          'car_model': carModel,
          'plate_number': plateNumber,
          if (color != null) 'color': color,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Failed to add car',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // PUT /api/cars/:id - Update car
  static Future<Map<String, dynamic>> updateCar(
    int carId,
    Map<String, dynamic> updates,
  ) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/$carId'),
        headers: headers,
        body: jsonEncode(updates),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Failed to update car',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // DELETE /api/cars/:id - Delete car (Manager only)
  static Future<Map<String, dynamic>> deleteCar(int carId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/$carId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Failed to delete car',
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


import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/wallet_model.dart';

class WalletService {
  static const String baseUrl = 'https://l1x9zzdh-5000.euw.devtunnels.ms/api/wallet';

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

  // GET /api/wallet/balance - Get wallet balance
  static Future<Map<String, dynamic>> getBalance() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/balance'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'balance': 0.0,
          'message': 'Failed to get balance',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'balance': 0.0,
        'message': 'Network error: $e',
      };
    }
  }

  // GET /api/wallet/transactions - Get transactions
  static Future<Map<String, dynamic>> getTransactions() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/transactions'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final transactions = (data['transactions'] as List)
              .map((t) => WalletTransaction.fromJson(t))
              .toList();
          final summary = data['summary'] != null
              ? WalletSummary.fromJson(data['summary'])
              : null;

          return {
            'success': true,
            'transactions': transactions,
            'summary': summary,
          };
        }
      }
      return {
        'success': false,
        'transactions': <WalletTransaction>[],
        'message': 'Failed to load transactions',
      };
    } catch (e) {
      return {
        'success': false,
        'transactions': <WalletTransaction>[],
        'message': 'Network error: $e',
      };
    }
  }

  // POST /api/wallet/pay - Pay from wallet
  static Future<Map<String, dynamic>> payFromWallet(int bookingId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/pay'),
        headers: headers,
        body: jsonEncode({
          'booking_id': bookingId,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Payment failed',
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


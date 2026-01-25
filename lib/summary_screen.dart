import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SummaryScreen extends StatelessWidget {
  const SummaryScreen({super.key});

  Future<void> confirmOrder(
      BuildContext context, Map<String, dynamic> args) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء تسجيل الدخول مرة أخرى')),
      );
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    final double price = double.parse(args['price'].toString());

    try {
      final walletRes = await http.get(
        Uri.parse(
          'https://l1x9zzdh-5000.euw.devtunnels.ms/api/wallet/balance',
        ),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      final walletData = json.decode(walletRes.body);
      final double balance =
          double.parse(walletData['balance'].toString());

      if (balance < price) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('رصيد المحفظة غير كافي'),
          ),
        );
        return;
      }

      final payRes = await http.post(
        Uri.parse(
          'https://l1x9zzdh-5000.euw.devtunnels.ms/api/wallet/pay',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          "amount": price,
        }),
      );

      final payData = json.decode(payRes.body);

      if (payRes.statusCode != 200 || payData['success'] != true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('فشل الدفع من المحفظة'),
          ),
        );
        return;
      }

      /// 3️⃣ إنشاء الحجز بعد نجاح الدفع
      final bookingRes = await http.post(
        Uri.parse(
          'https://l1x9zzdh-5000.euw.devtunnels.ms/api/bookings/create',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          "car_id": int.parse(args['car_id'].toString()),
          "service_id": int.parse(args['service_id'].toString()),
          "booking_date": args['booking_date'].toString(),
          "location": args['location'].toString(),
          "lat": double.parse(args['lat'].toString()),
          "lng": double.parse(args['lng'].toString()),
        }),
      );

      final bookingData = json.decode(bookingRes.body);

      if (bookingRes.statusCode != 200 ||
          bookingData['success'] != true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('تم الخصم لكن فشل إنشاء الحجز (راجع الباك)'),
          ),
        );
        return;
      }

      /// 4️⃣ نجاح كامل
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('تم تأكيد الطلب وخصم $price ₪ بنجاح'),
        ),
      );

      Navigator.pushNamedAndRemoveUntil(
        context,
        '/orders',
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('حدث خطأ غير متوقع'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Summary'),
        backgroundColor: const Color(0xFF3B0A8F),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _item('Service', args['service_name']),
            _item('Car', args['car_name']),
            _item('Date & Time', args['booking_date']),
            _item('Location', args['location']),
            const Divider(height: 30),
            Text(
              'Total: ${args['price']} ₪',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => confirmOrder(context, args),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4DE1D6),
                ),
                child: const Text(
                  'Confirm & Pay',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _item(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        '$title: $value',
        style: const TextStyle(fontSize: 16),
      ),
    );
  }
}

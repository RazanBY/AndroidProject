import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class MyCarScreen extends StatefulWidget {
  const MyCarScreen({super.key});

  @override
  State<MyCarScreen> createState() => _MyCarScreenState();
}

class _MyCarScreenState extends State<MyCarScreen> {
  List cars = [];
  bool loading = true;

  Future<void> fetchCars() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final res = await http.get(
      Uri.parse('https://l1x9zzdh-5000.euw.devtunnels.ms/api/cars'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    final data = json.decode(res.body);

    setState(() {
      cars = data['cars'];
      loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchCars();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cars'),
        backgroundColor: const Color(0xFF3B0A8F),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: cars.length,
              itemBuilder: (context, index) {
                final car = cars[index];
                return Card(
                  child: ListTile(
                    title: Text(car['car_model']),
                    subtitle: Text(car['plate_number']),
                    onTap: () {
                      Navigator.pop(context, {
                        'car_id': car['id'],
                        'car_name': car['car_model'],
                      });
                    },
                  ),
                );
              },
            ),
    );
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class WashScreen extends StatefulWidget {
  const WashScreen({super.key});

  @override
  State<WashScreen> createState() => _WashScreenState();
}

class _WashScreenState extends State<WashScreen> {
  List services = [];
  bool loading = true;

  Future<void> fetchServices() async {
    final res = await http.get(
      Uri.parse('https://l1x9zzdh-5000.euw.devtunnels.ms/api/services'),
    );

    final data = json.decode(res.body);

    setState(() {
      services = data['services'];
      loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchServices();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Services'),
        backgroundColor: const Color(0xFF3B0A8F),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: services.length,
              itemBuilder: (context, index) {
                final service = services[index];

                return Card(
                  child: ListTile(
                    title: Text(service['name']),
                    subtitle: Text('${service['price']} ₪'),
                    onTap: () {
  Navigator.pushNamed(
    context,
    '/schedule',
    arguments: {
      'service_id': service['id'],
      'service_name': service['name'],
      'price': service['price'],
    },
  );
}

                  ),
                );
              },
            ),
    );
  }
}

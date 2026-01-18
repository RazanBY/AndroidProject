import 'package:flutter/material.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  final TextEditingController locationController = TextEditingController();

  @override
  void dispose() {
    locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Location'),
        backgroundColor: const Color(0xFF3B0A8F),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Wash: ${data['wash']}'),
            Text('Car: ${data['car']}'),
            Text('Date: ${data['date']}'),
            Text('Time: ${data['time']}'),

            const SizedBox(height: 20),

            TextField(
              controller: locationController,
              decoration: InputDecoration(
                hintText: 'Enter location',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.location_on),
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  if (locationController.text.isNotEmpty) {
                    Navigator.pushNamed(
                      context,
                      '/summary',
                      arguments: {
                        'wash': data['wash'],
                        'car': data['car'],
                        'date': data['date'],
                        'time': data['time'],
                        'location': locationController.text,
                        'price': data['price'],
                      },
                    );
                  }
                },
                child: const Text(
                  'Confirm',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

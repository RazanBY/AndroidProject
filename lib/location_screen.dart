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
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Location'),
        backgroundColor: const Color(0xFF3B0A8F),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Service: ${args['service_name']}'),
            Text('Car: ${args['car_name']}'),
            Text('Date: ${args['booking_date']}'),

            const SizedBox(height: 20),

            TextField(
              controller: locationController,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                hintText: 'Enter location',
                border: OutlineInputBorder(),
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: locationController.text.trim().isEmpty
                    ? null
                    : () {
                        Navigator.pushNamed(
                          context,
                          '/summary',
                          arguments: {
                            ...args,
                            'location': locationController.text.trim(),
                            'lat': 31.902556,
                            'lng': 35.206209,
                          },
                        );
                      },
                child: const Text('Next'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

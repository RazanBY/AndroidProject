import 'package:flutter/material.dart';

class WashScreen extends StatefulWidget {
  const WashScreen({super.key});

  @override
  State<WashScreen> createState() => _WashScreenState();
}

class _WashScreenState extends State<WashScreen> {
  String? selectedWash;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Car Wash'),
        backgroundColor: const Color(0xFF3B0A8F),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _washOption('Basic Wash', '10 \$'),
            _washOption('Premium Wash', '20 \$'),
            _washOption('Full Service', '30 \$'),
            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: selectedWash == null
                    ? null
                    : () async {
                        final selectedCar = await Navigator.pushNamed(
                          context,
                          '/mycar',
                          arguments: {'select': true},
                        );

                        if (selectedCar != null) {
                          Navigator.pushNamed(
                            context,
                            '/schedule',
                            arguments: {
                              'wash': selectedWash,
                              'car': selectedCar,
                            },
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4DE1D6),
                ),
                child: const Text(
                  'Next',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _washOption(String title, String price) {
    return Card(
      child: RadioListTile<String>(
        value: title,
        groupValue: selectedWash,
        onChanged: (value) {
          setState(() {
            selectedWash = value;
          });
        },
        title: Text(title),
        subtitle: Text(price),
      ),
    );
  }
}

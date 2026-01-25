import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AddCarScreen extends StatefulWidget {
  const AddCarScreen({super.key});

  @override
  State<AddCarScreen> createState() => _AddCarScreenState();
}

class _AddCarScreenState extends State<AddCarScreen> {
  final TextEditingController carModelController = TextEditingController();
  final TextEditingController plateNumberController = TextEditingController();
  final TextEditingController colorController = TextEditingController();
  
  bool isLoading = false;

  Future<void> _addCar() async {
    if (carModelController.text.trim().isEmpty || 
        plateNumberController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Car model and plate number are required'))
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.post(
        Uri.parse('https://l1x9zzdh-5000.euw.devtunnels.ms/api/cars'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'car_model': carModelController.text.trim(),
          'plate_number': plateNumberController.text.trim(),
          'color': colorController.text.trim().isNotEmpty ? 
                   colorController.text.trim() : null,
        }),
      );

      final data = jsonDecode(response.body);
      print('Response: ${response.statusCode}, Body: $data');

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Car added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        throw data['message'] ?? 'Failed to add car';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Car'),
        backgroundColor: const Color(0xFF3B0A8F),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height - 200,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 20),
              
              // Car Model
              TextField(
                controller: carModelController,
                decoration: const InputDecoration(
                  labelText: 'Car Model',
                  hintText: 'e.g., تويوتا كامري 2020',
                  prefixIcon: Icon(Icons.directions_car),
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Plate Number
              TextField(
                controller: plateNumberController,
                decoration: const InputDecoration(
                  labelText: 'Plate Number',
                  hintText: 'e.g., ABC-123',
                  prefixIcon: Icon(Icons.confirmation_number),
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Color (optional)
              TextField(
                controller: colorController,
                decoration: const InputDecoration(
                  labelText: 'Color (optional)',
                  hintText: 'e.g., أبيض',
                  prefixIcon: Icon(Icons.color_lens),
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
              
              const SizedBox(height: 40), // بدل Spacer
              
              // Save Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _addCar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4DE1D6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Save Car',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
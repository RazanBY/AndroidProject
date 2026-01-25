import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:glow_car/add_car_screen.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class MyCarScreen extends StatefulWidget {
  final bool isSelectionMode; 
  
  const MyCarScreen({super.key, this.isSelectionMode = false});

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
      cars = data['cars'] ?? [];
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
        title: Text(widget.isSelectionMode ? 'Select a Car' : 'My Cars'),
        backgroundColor: const Color(0xFF3B0A8F),
        leading: widget.isSelectionMode ? IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ) : null,
      ),
      floatingActionButton: !widget.isSelectionMode ? FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddCarScreen()),
          );
          if (result == true) {
            setState(() => loading = true);
            await fetchCars();
          }
        },
        backgroundColor: const Color(0xFF4DE1D6),
        child: const Icon(Icons.add),
      ) : null,
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : cars.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.directions_car, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text('No cars added yet'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const AddCarScreen()),
                          );
                          if (result == true) {
                            setState(() => loading = true);
                            await fetchCars();
                          }
                        },
                        child: const Text('Add Your First Car'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: cars.length,
                  itemBuilder: (context, index) {
                    final car = cars[index];
                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: ListTile(
                        title: Text(car['car_model'] ?? 'Unknown Model'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Plate: ${car['plate_number'] ?? 'N/A'}'),
                            if (car['color'] != null) Text('Color: ${car['color']}'),
                          ],
                        ),
                        leading: const Icon(Icons.directions_car, color: Color(0xFF3B0A8F)),
                        trailing: widget.isSelectionMode 
                            ? const Icon(Icons.arrow_forward_ios, size: 16)
                            : IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteCar(car['id']),
                              ),
                        onTap: () {
                          if (widget.isSelectionMode) {
                            Navigator.pop(context, {
                              'car_id': car['id'],
                              'car_name': car['car_model'] ?? 'Car',
                            });
                          }
                        },
                      ),
                    );
                  },
                ),
    );
  }

  Future<void> _deleteCar(int carId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final res = await http.delete(
      Uri.parse('https://l1x9zzdh-5000.euw.devtunnels.ms/api/cars/$carId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Car deleted successfully')),
      );
      await fetchCars();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete car')),
      );
    }
  }
}
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyCarScreen extends StatefulWidget {
  const MyCarScreen({super.key});

  @override
  State<MyCarScreen> createState() => _MyCarScreenState();
}

class _MyCarScreenState extends State<MyCarScreen> {
  List<String> cars = [];
  String? selectedCar;
  bool isSelectMode = false;

  @override
  void initState() {
    super.initState();
    _loadCars();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args != null && args is Map && args['select'] == true) {
        setState(() {
          isSelectMode = true;
        });
      }
    });
  }

  Future<void> _loadCars() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      cars = prefs.getStringList('cars') ?? [];
    });
  }

  Future<void> _saveCars() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('cars', cars);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cars'),
        backgroundColor: const Color(0xFF3B0A8F),
      ),

      floatingActionButton: isSelectMode
          ? null
          : FloatingActionButton(
              onPressed: () async {
                final newCar =
                    await Navigator.pushNamed(context, '/addcar');

                if (newCar != null && newCar is String) {
                  setState(() {
                    cars.add(newCar);
                  });
                  _saveCars();
                }
              },
              child: const Icon(Icons.add),
            ),

      bottomNavigationBar: isSelectMode
          ? Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: selectedCar == null
                      ? null
                      : () {
                          Navigator.pop(context, selectedCar);
                        },
                  child: const Text('Confirm'),
                ),
              ),
            )
          : null,

      body: cars.isEmpty
          ? const Center(child: Text('No cars added'))
          : ListView.builder(
              itemCount: cars.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const Icon(Icons.directions_car),
                  title: Text(cars[index]),
                  trailing: isSelectMode
                      ? Radio<String>(
                          value: cars[index],
                          groupValue: selectedCar,
                          onChanged: (value) {
                            setState(() {
                              selectedCar = value;
                            });
                          },
                        )
                      : IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            setState(() {
                              cars.removeAt(index);
                            });
                            _saveCars();
                          },
                        ),
                  onTap: isSelectMode
                      ? () {
                          setState(() {
                            selectedCar = cars[index];
                          });
                        }
                      : null,
                );
              },
            ),
    );
  }
}

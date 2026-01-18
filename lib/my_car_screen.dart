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

  void _addCar() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Car'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Car name / plate'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                setState(() {
                  cars.add(controller.text);
                });
                _saveCars();
              }
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
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
              onPressed: _addCar,
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
                return Dismissible(
                  key: ValueKey(cars[index]),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) {
                    setState(() {
                      cars.removeAt(index);
                    });
                    _saveCars();
                  },
                  child: ListTile(
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
                  ),
                );
              },
            ),
    );
  }
}

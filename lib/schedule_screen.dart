import 'package:flutter/material.dart';
import 'my_car_screen.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  Map<String, dynamic>? selectedCar;

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule Appointment'),
        backgroundColor: const Color(0xFF3B0A8F),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      args['service_name'],
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text('Price: ${args['price']} ₪'),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            Card(
              child: ListTile(
                leading: const Icon(Icons.directions_car, color: Color(0xFF3B0A8F)),
                title: const Text('Select Car'),
                subtitle: selectedCar == null 
                    ? const Text('Tap to choose a car', style: TextStyle(color: Colors.grey))
                    : Text(
                        selectedCar!['car_name'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () async {
                  final car = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const MyCarScreen(isSelectionMode: true),
                    ),
                  );
                  
                  if (car != null && car is Map) {
                    setState(() {
                      selectedCar = Map<String, dynamic>.from(car);
                    });
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Selected: ${car['car_name']}'),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  }
                },
              ),
            ),
            
            const SizedBox(height: 20),
            
            Card(
              child: ListTile(
                leading: const Icon(Icons.calendar_today, color: Color(0xFF3B0A8F)),
                title: const Text('Select Date'),
                subtitle: Text(
                  '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 30)),
                    initialDate: selectedDate,
                  );
                  if (date != null) {
                    setState(() => selectedDate = date);
                  }
                },
              ),
            ),
            
            const SizedBox(height: 10),
            
            Card(
              child: ListTile(
                leading: const Icon(Icons.access_time, color: Color(0xFF3B0A8F)),
                title: const Text('Select Time'),
                subtitle: Text(
                  '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: selectedTime,
                  );
                  if (time != null) {
                    setState(() => selectedTime = time);
                  }
                },
              ),
            ),
            
            const Spacer(),
            
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: selectedCar == null
                    ? null
                    : () {
                        final bookingDate =
                            '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')} '
                            '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}:00';

                        Navigator.pushNamed(
                          context,
                          '/location',
                          arguments: {
                            'service_id': args['service_id'],
                            'service_name': args['service_name'],
                            'price': args['price'],
                            'car_id': selectedCar!['car_id'],
                            'car_name': selectedCar!['car_name'],
                            'booking_date': bookingDate,
                          },
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4DE1D6),
                ),
                child: Text(
                  selectedCar == null ? 'Please Select a Car First' : 'Continue to Location',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
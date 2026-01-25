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
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule'),
        backgroundColor: const Color(0xFF3B0A8F),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () async {
                final car = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MyCarScreen()),
                );
                if (car != null) {
                  setState(() {
                    selectedCar = Map<String, dynamic>.from(car);
                  });
                }
              },
              child: Text(
                selectedCar == null
                    ? 'Select Car'
                    : selectedCar!['car_name'].toString(),
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () async {
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
              child: const Text('Select Date'),
            ),

            ElevatedButton(
              onPressed: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: selectedTime,
                );
                if (time != null) {
                  setState(() => selectedTime = time);
                }
              },
              child: const Text('Select Time'),
            ),

            const Spacer(),

            ElevatedButton(
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
                          'service_id':
                              int.parse(args['service_id'].toString()),
                          'service_name': args['service_name'].toString(),
                          'price':
                              double.parse(args['price'].toString()), // ⭐ مهم
                          'car_id': int.parse(
                              selectedCar!['car_id'].toString()), // ⭐ مهم
                          'car_name':
                              selectedCar!['car_name'].toString(),
                          'booking_date': bookingDate,
                        },
                      );
                    },
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}

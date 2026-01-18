import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  String get formattedDate {
    if (selectedDate == null) return 'Select date';
    return DateFormat('yyyy-MM-dd').format(selectedDate!);
  }

  String get formattedTime {
    if (selectedTime == null) return 'Select time';
    return selectedTime!.format(context);
  }

  @override
  Widget build(BuildContext context) {
    final data =
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
            /// Date
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Date'),
              subtitle: Text(formattedDate),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 30)),
                  initialDate: DateTime.now(),
                );

                if (picked != null) {
                  setState(() {
                    selectedDate = picked;
                  });
                }
              },
            ),

            const Divider(),

            /// Time
            ListTile(
              leading: const Icon(Icons.access_time),
              title: const Text('Time'),
              subtitle: Text(formattedTime),
              onTap: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );

                if (picked != null) {
                  setState(() {
                    selectedTime = picked;
                  });
                }
              },
            ),

            const Spacer(),

            /// Next
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: selectedDate == null || selectedTime == null
                    ? null
                    : () {
                        Navigator.pushNamed(
                          context,
                          '/location',
                          arguments: {
                            'wash': data['wash'],
                            'car': data['car'],
                            'date': formattedDate,
                            'time': formattedTime,
                            'price': _getPrice(data['wash']),
                          },
                        );
                      },
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

  int _getPrice(String wash) {
    switch (wash) {
      case 'Basic Wash':
        return 10;
      case 'Premium Wash':
        return 20;
      case 'Full Service':
        return 30;
      default:
        return 0;
    }
  }
}

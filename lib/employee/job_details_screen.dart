import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/job_model.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class JobDetailsScreen extends StatefulWidget {
  final Job job;

  const JobDetailsScreen({super.key, required this.job});

  @override
  State<JobDetailsScreen> createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends State<JobDetailsScreen> {
  late Job _job;
  bool _isLoading = false;
  bool _notificationsEnabled = true;
  String _selectedStatus = 'Pending';
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  final List<String> _statusOptions = [
    'Pending',
    'In Progress',
    'Completed',
    'Cancelled'
  ];

  @override
  void initState() {
    super.initState();
    _job = widget.job;
    _selectedStatus = _job.status;
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF3B0A8F),
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF3B0A8F),
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _updateStatus(String newStatus) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Status'),
        content: Text('Change job status to "$newStatus"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Update'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final employeeId = await StorageService.getEmployeeId();
      if (employeeId != null) {
        final result = await ApiService.updateJobStatus(
          _job.id,
          employeeId,
          newStatus,
        );

        if (mounted) {
          setState(() {
            _isLoading = false;
          });

          if (result['success'] == true) {
            setState(() {
              _job = _job.copyWith(status: newStatus);
              _selectedStatus = newStatus;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Status updated successfully'),
                backgroundColor: Colors.green,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result['message'] ?? 'Update failed'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _startJob() async {
    await _updateStatus('In Progress');
  }

  Future<void> _completeJob() async {
    // Show date and time picker for completion
    await _selectDate();
    if (_selectedDate != null) {
      await _selectTime();
      if (_selectedTime != null) {
        final completionDate = DateFormat('yyyy-MM-dd').format(_selectedDate!);
        final completionTime =
            '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}';

        setState(() {
          _isLoading = true;
        });

        try {
          final employeeId = await StorageService.getEmployeeId();
          if (employeeId != null) {
            final result = await ApiService.completeJob(
              _job.id,
              employeeId,
              completionDate,
              completionTime,
            );

            if (mounted) {
              setState(() {
                _isLoading = false;
              });

              if (result['success'] == true) {
                setState(() {
                  _job = _job.copyWith(
                    status: 'Completed',
                    date: completionDate,
                    time: completionTime,
                  );
                  _selectedStatus = 'Completed';
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Job completed successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(result['message'] ?? 'Completion failed'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          }
        } catch (e) {
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3B0A8F),
      appBar: AppBar(
        title: const Text('Job Details'),
        backgroundColor: const Color(0xFF2A075F),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4DE1D6)),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Customer Info Card
                  _buildInfoCard(
                    'Customer Information',
                    [
                      _buildInfoRow('Name', _job.customerName, Icons.person),
                      _buildInfoRow('Car Model', _job.carModel, Icons.directions_car),
                      _buildInfoRow('Car Plate', _job.carPlate, Icons.confirmation_number),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Service Info Card
                  _buildInfoCard(
                    'Service Information',
                    [
                      _buildInfoRow('Service Type', _job.serviceType, Icons.local_car_wash),
                      _buildInfoRow('Location', _job.location, Icons.location_on),
                      _buildInfoRow('Address', _job.address, Icons.home),
                      _buildInfoRow('Price', '\$${_job.price.toStringAsFixed(2)}', Icons.attach_money),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Schedule Info Card
                  _buildInfoCard(
                    'Schedule',
                    [
                      ListTile(
                        leading: const Icon(Icons.calendar_today),
                        title: const Text('Date'),
                        subtitle: Text(_job.date),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: _selectDate,
                        ),
                      ),
                      ListTile(
                        leading: const Icon(Icons.access_time),
                        title: const Text('Time'),
                        subtitle: Text(_job.time),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: _selectTime,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Status Card
                  Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Job Status',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Status Spinner
                          DropdownButtonFormField<String>(
                            value: _selectedStatus,
                            decoration: InputDecoration(
                              labelText: 'Status',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            items: _statusOptions.map((String status) {
                              return DropdownMenuItem<String>(
                                value: status,
                                child: Text(status),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                _updateStatus(newValue);
                              }
                            },
                          ),
                          const SizedBox(height: 16),
                          // Notification Switch
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Enable Notifications',
                                style: TextStyle(fontSize: 16),
                              ),
                              Switch(
                                value: _notificationsEnabled,
                                onChanged: (bool value) {
                                  setState(() {
                                    _notificationsEnabled = value;
                                  });
                                },
                                activeColor: const Color(0xFF4DE1D6),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Action Buttons
                  if (_job.status == 'Pending')
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _startJob,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Start Job',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  if (_job.status == 'In Progress') ...[
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _completeJob,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Complete Job',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}




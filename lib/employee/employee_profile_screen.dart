import 'package:flutter/material.dart';
import '../models/employee_model.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class EmployeeProfileScreen extends StatefulWidget {
  const EmployeeProfileScreen({super.key});

  @override
  State<EmployeeProfileScreen> createState() => _EmployeeProfileScreenState();
}

class _EmployeeProfileScreenState extends State<EmployeeProfileScreen> {
  Employee? _employee;
  bool _isLoading = true;
  String? _employeeId;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _employeeId = await StorageService.getEmployeeId();
      if (_employeeId != null) {
        final employee = await ApiService.getEmployeeProfile(_employeeId!);
        if (mounted) {
          setState(() {
            _employee = employee;
            _isLoading = false;
          });
        }
      } else {
        // Load from SharedPreferences if API fails
        final name = await StorageService.getEmployeeName();
        final email = await StorageService.getEmployeeEmail();
        final phone = await StorageService.getEmployeePhone();
        final teamId = await StorageService.getTeamId();

        if (mounted) {
          setState(() {
            _employee = Employee(
              id: _employeeId ?? '',
              name: name ?? 'Unknown',
              email: email ?? '',
              phone: phone,
              teamId: teamId,
            );
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      // Fallback to SharedPreferences
      final name = await StorageService.getEmployeeName();
      final email = await StorageService.getEmployeeEmail();
      final phone = await StorageService.getEmployeePhone();
      final teamId = await StorageService.getTeamId();

      if (mounted) {
        setState(() {
          _employee = Employee(
            id: _employeeId ?? '',
            name: name ?? 'Unknown',
            email: email ?? '',
            phone: phone,
            teamId: teamId,
          );
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3B0A8F),
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: const Color(0xFF2A075F),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4DE1D6)),
              ),
            )
          : _employee == null
              ? const Center(
                  child: Text(
                    'Failed to load profile',
                    style: TextStyle(color: Colors.white),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Profile Header
                      Card(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 50,
                                backgroundColor: const Color(0xFF4DE1D6),
                                child: Text(
                                  _employee!.name.isNotEmpty
                                      ? _employee!.name[0].toUpperCase()
                                      : 'E',
                                  style: const TextStyle(
                                    fontSize: 40,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _employee!.name,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (_employee!.rating != null) ...[
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _employee!.rating!.toStringAsFixed(1),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Employee Information Card
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
                                'Employee Information',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildInfoRow(
                                Icons.badge,
                                'Employee ID',
                                _employee!.id,
                              ),
                              const Divider(),
                              _buildInfoRow(
                                Icons.email,
                                'Email',
                                _employee!.email,
                              ),
                              if (_employee!.phone != null) ...[
                                const Divider(),
                                _buildInfoRow(
                                  Icons.phone,
                                  'Phone',
                                  _employee!.phone!,
                                ),
                              ],
                              if (_employee!.teamName != null) ...[
                                const Divider(),
                                _buildInfoRow(
                                  Icons.group,
                                  'Team',
                                  _employee!.teamName!,
                                ),
                              ],
                              if (_employee!.teamId != null) ...[
                                const Divider(),
                                _buildInfoRow(
                                  Icons.tag,
                                  'Team ID',
                                  _employee!.teamId!,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Statistics Card
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
                                'Statistics',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF4DE1D6).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.work_history,
                                      size: 32,
                                      color: Color(0xFF4DE1D6),
                                    ),
                                    const SizedBox(width: 16),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Total Jobs Completed',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        Text(
                                          '${_employee!.totalJobsCompleted}',
                                          style: const TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF4DE1D6),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 24, color: Colors.grey[600]),
          const SizedBox(width: 16),
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




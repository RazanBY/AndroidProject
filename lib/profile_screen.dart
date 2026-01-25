import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isLoading = true;

  String name = '';
  String email = '';
  String phone = '';
  String userType = '';
  double walletBalance = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  // 🔹 جلب بيانات البروفايل
  Future<void> _fetchProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      _goToLogin();
      return;
    }

    try {
      final response = await http.get(
        Uri.parse(
          'https://l1x9zzdh-5000.euw.devtunnels.ms/api/auth/profile',
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final user = data['user'];

        setState(() {
          name = user['name'];
          email = user['email'];
          phone = user['phone'];
          userType = user['user_type'];
          walletBalance =
              double.parse(user['wallet_balance'].toString());
          isLoading = false;
        });
      } else {
        _goToLogin();
      }
    } catch (e) {
      _goToLogin();
    }
  }

  // logout
  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); 

    _goToLogin();
  }

  void _goToLogin() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/login',
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3B0A8F),
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: const Color(0xFF3B0A8F),
        elevation: 0,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.white),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.person,
                        size: 60,
                        color: Color(0xFF3B0A8F),
                      ),
                    ),
                    const SizedBox(height: 20),

                    _infoTile("Name", name),
                    _infoTile("Email", email),
                    _infoTile("Phone", phone),
                    _infoTile("User Type", userType),
                    _infoTile(
                      "Wallet Balance",
                      "${walletBalance.toStringAsFixed(2)} ₪",
                    ),

                    const SizedBox(height: 30),

                    ElevatedButton(
                      onPressed: _logout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: const Text(
                        "Logout",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _infoTile(String title, String value) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3B0A8F),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 40),
            Image.asset('assets/logo.png', width: 120),
            const SizedBox(height: 20),

            _menuButton(context, "My Cars", Icons.directions_car, '/mycar'),
            _menuButton(context, "Book a Wash", Icons.calendar_month, '/wash'),
            _menuButton(context, "Wallet", Icons.account_balance_wallet, '/wallet'),
            _menuButton(context, "My Orders", Icons.list_alt, '/orders'),
          ],
        ),
      ),
    );
  }

  Widget _menuButton(BuildContext context, String title, IconData icon, String route) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: ElevatedButton(
        onPressed: route.isEmpty ? null : () {
          Navigator.pushNamed(context, route);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFBFE5E8),
          minimumSize: const Size(double.infinity, 70),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 32, color: Colors.black),
            const SizedBox(width: 20),
            Text(title, style: const TextStyle(fontSize: 18, color: Colors.black)),
          ],
        ),
      ),
    );
  }
}

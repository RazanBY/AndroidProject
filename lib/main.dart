import 'package:flutter/material.dart';
import 'splash_screen.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import 'home_screen.dart';
import 'wash_screen.dart';
import 'my_car_screen.dart';
import 'location_screen.dart';
import 'summary_screen.dart';
import 'add_car_screen.dart';
import 'schedule_screen.dart';
import 'my_orders_screen.dart';
import 'wallet_screen.dart';
import 'profile_screen.dart';
import 'employee/employee_login_screen.dart';
import 'employee/employee_dashboard_screen.dart';
import 'employee/job_details_screen.dart';
import 'employee/employee_profile_screen.dart';
void main() async {
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/mycar': (context) => const MyCarScreen(),
        '/wash': (context) => const WashScreen(),
        '/location': (context) => const LocationScreen(),
        '/summary': (context) => const SummaryScreen(),
        '/addcar': (context) => const AddCarScreen(),
        '/schedule': (context) => const ScheduleScreen(),
        '/orders': (context) => const MyOrdersScreen(),
        '/wallet': (context) => const WalletScreen(),
        '/profile': (context) => const ProfileScreen(),




        // Employee routes
        '/employee/login': (context) => const EmployeeLoginScreen(),
        '/employee/dashboard': (context) => const EmployeeDashboardScreen(),
        '/employee/profile': (context) => const EmployeeProfileScreen(),
      },
    );
  }
}

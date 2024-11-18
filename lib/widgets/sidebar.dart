import 'package:flutter/material.dart';
import 'package:app/dashboard/dashboard_page.dart';
import 'package:app/dashboard/users_page.dart';
import 'package:app/dashboard/settings_page.dart';
import 'package:app/dashboard/products_page.dart';

class Sidebar extends StatelessWidget {
  final Function(Widget) onPageChange;

  const Sidebar({super.key, required this.onPageChange});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width > 600 ? 70 : 50,
      color: const Color.fromARGB(255, 127, 79, 135),
      child: ListView(
        children: [
          IconButton(
            icon: const Icon(Icons.dashboard, color: Colors.white),
            onPressed: () => onPageChange(const DashboardPage()),
            tooltip: 'Dashboard',
          ),
          IconButton(
            icon: const Icon(Icons.people, color: Colors.white),
            onPressed: () => onPageChange(const UsersPage()),
            tooltip: 'Users',
          ),
          IconButton(
            icon: const Icon(Icons.shopping_bag, color: Colors.white),
            onPressed: () => onPageChange(const ProductPage()),
            tooltip: 'Products',
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () => onPageChange(const SettingsPage()),
            tooltip: 'Settings',
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:app/dashboard/dashboard_page.dart'; // Importer la page Dashboard
import 'package:app/dashboard/users_page.dart'; // Importer la page Users
import 'package:app/dashboard/settings_page.dart'; // Importer la page Settings
import 'package:app/dashboard/products_page.dart';
class Sidebar extends StatelessWidget {
  final Function(Widget) onPageChange; // Fonction pour changer la page affichée

  const Sidebar({super.key, required this.onPageChange});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70, // Réduire la largeur du Sidebar à 70 pour n'afficher que les icônes
      color: const Color.fromARGB(255, 127, 79, 135),
      child: ListView(
        children: [
          // Liste des icônes
          IconButton(
            icon: const Icon(Icons.dashboard, color: Colors.white),
            onPressed: () {
              onPageChange(const DashboardPage()); // Changer vers Dashboard
            },
          ),
          IconButton(
            icon: const Icon(Icons.people, color: Colors.white),
            onPressed: () {
              onPageChange(const UsersPage()); // Changer vers Users
            },
          ),
          IconButton(
            icon: const Icon(Icons.shopping_bag, color: Colors.white),
            onPressed: () {
              onPageChange(const ProductPage());
            }
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              onPageChange(const SettingsPage()); // Changer vers Settings
            },
          ),
        ],
      ),
    );
  }
}

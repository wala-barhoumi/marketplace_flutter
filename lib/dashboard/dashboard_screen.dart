import 'package:flutter/material.dart';
import 'package:app/widgets/navbar.dart';
import 'package:app/widgets/sidebar.dart';
import 'dashboard_page.dart'; // Importez la page Dashboard
import 'users_page.dart'; // Importez la page Users
import 'settings_page.dart'; // Importez la page Settings

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Variable pour gérer la page actuellement affichée
  Widget _currentPage = const DashboardPage(); // Page par défaut au démarrage

  // Fonction pour changer la page affichée
  void _updatePage(Widget page) {
    setState(() {
      _currentPage = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(60.0),
        child: Navbar(),
      ),
      body: Row(
        children: [
          Sidebar(
            onPageChange: _updatePage, // Passer la fonction de changement de page
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _currentPage, // Afficher la page courante
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

class Navbar extends StatelessWidget {
  const Navbar({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isLargeScreen = constraints.maxWidth > 800;
        return AppBar(
          backgroundColor: const Color.fromARGB(255, 127, 79, 135),
          title: const Text(
            'Admin Dashboard',
            style: TextStyle(color: Colors.white), // Set text color to white
          ),
          actions: isLargeScreen
              ? [
                  IconButton(
                    icon: const Icon(Icons.notifications, color: Colors.white), // White icon
                    onPressed: () {
                      // Action for notifications
                    },
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.account_circle, color: Colors.white), // White icon
                    onSelected: (value) {
                      if (value == 'update_profile') {
                        _navigateToUpdateProfile(context);
                      } else if (value == 'logout') {
                        _showLogoutConfirmation(context);
                      }
                    },
                    itemBuilder: (BuildContext context) => [
                      const PopupMenuItem(
                        value: 'update_profile',
                        child: Text('Mettre à jour le profil'),
                      ),
                      const PopupMenuItem(
                        value: 'logout',
                        child: Text('Se déconnecter'),
                      ),
                    ],
                  ),
                ]
              : [
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.menu, color: Colors.white), // White icon
                    onSelected: (value) {
                      // Handle actions here
                    },
                    itemBuilder: (BuildContext context) => [
                      const PopupMenuItem(
                        value: 'notifications',
                        child: Text('Notifications'),
                      ),
                      const PopupMenuItem(
                        value: 'update_profile',
                        child: Text('Mettre à jour le profil'),
                      ),
                      const PopupMenuItem(
                        value: 'logout',
                        child: Text('Se déconnecter'),
                      ),
                    ],
                  ),
                ],
        );
      },
    );
  }

  void _navigateToUpdateProfile(BuildContext context) {
    Navigator.pushNamed(context, '/update-profile');
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmation'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: const Text('Se déconnecter'),
          ),
        ],
      ),
    );
  }
}

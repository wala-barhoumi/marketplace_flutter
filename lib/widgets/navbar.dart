import 'package:flutter/material.dart';

class Navbar extends StatelessWidget {
  const Navbar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color.fromARGB(255, 127, 79, 135),
      title: const Text('Admin Dashboard'),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications),
          onPressed: () {
            // Action pour afficher les notifications
          },
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.account_circle),
          onSelected: (value) {
            if (value == 'update_profile') {
              // Action pour mettre à jour le profil
              _navigateToUpdateProfile(context);
            } else if (value == 'logout') {
              // Action pour déconnecter
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
      ],
    );
  }

  void _navigateToUpdateProfile(BuildContext context) {
    // Naviguer vers la page de mise à jour du profil
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
              // Action pour déconnecter (exemple : redirection vers la page de connexion)
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

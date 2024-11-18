import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  _UsersPageState createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  // Function to retrieve users from Firestore
  Future<List<Map<String, dynamic>>> getUsersFromFirestore() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance.collection('users').get();

      List<Map<String, dynamic>> usersList = [];
      for (var doc in querySnapshot.docs) {
        usersList.add(doc.data());
      }
      return usersList;
    } catch (e) {
      print('Error fetching users: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: getUsersFromFirestore(), // Call the function to fetch users
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error loading users'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No users found.'));
          }

          // List of users fetched from Firestore
          final users = snapshot.data!;

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  leading: Icon(Icons.person, size: 40),
                  title: Text(user['name'] ?? 'No Name'), // Replace with actual user fields
                  subtitle: Text(user['email'] ?? 'No Email'), // Replace with actual user fields
                  onTap: () {
                    // Optional: Add functionality for tapping on a user
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

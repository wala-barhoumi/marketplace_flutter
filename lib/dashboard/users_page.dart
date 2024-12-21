import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  _UsersPageState createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Real-time listener using StreamBuilder
  Stream<List<Map<String, dynamic>>> getUsersStream() {
    return _firestore.collection('users').snapshots().map((querySnapshot) {
      return querySnapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // Add the document ID to the data
        return data;
      }).toList();
    });
  }

  // Update user data
  Future<void> updateUser(String userId, Map<String, dynamic> updatedData) async {
    try {
      await _firestore.collection('users').doc(userId).update(updatedData);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User updated successfully')),
      );
    } catch (e) {
      print('Error updating user: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error updating user')),
      );
    }
  }

  // Delete user
  Future<void> deleteUser(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User deleted successfully')),
      );
    } catch (e) {
      print('Error deleting user: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error deleting user')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 189, 167, 204),
        title: const Text('User Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {},
          ),
        ],
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: getUsersStream(), // Stream of user data
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No users found'));
          }

          List<Map<String, dynamic>> users = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                DataTable(
                  columnSpacing: 16.0,
                  headingRowHeight: 56.0,
                  columns: <DataColumn>[
  DataColumn(
    label: Text(
      'Username',
      style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.01),
    ),
  ),
  DataColumn(
    label: Text(
      'Email',
      style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.01),
    ),
  ),
  DataColumn(
    label: Text(
      'Address',
      style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.01),
    ),
  ),
  DataColumn(
    label: Text(
      'Created At',
      style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.01),
    ),
  ),
  DataColumn(
    label: Text(
      'Actions',
      style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.01),
    ),
  ),
],

                  rows: users
                      .map(
                        (user) => DataRow(
                          cells: <DataCell>[
                            DataCell(Text(user['username'] ?? 'No username')),
                            DataCell(Text(user['email'] ?? 'No email')),
                            DataCell(Text(user['address'] ?? 'No address')),
                            DataCell(Text(_formatTimestamp(user['createdAt']))),
                            DataCell(
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () {
                                      // Example: Show dialog to update user data
                                      _showEditUserDialog(user);
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: const Text('Delete User'),
                                            content: const Text('Are you sure you want to delete this user?'),
                                            actions: <Widget>[
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: const Text('Cancel'),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  deleteUser(user['id']);
                                                  Navigator.of(context).pop();
                                                },
                                                child: const Text('Delete'),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Helper function to format the 'createdAt' timestamp
  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'No createdAt';
    DateTime date = timestamp.toDate();
    return '${date.toLocal()}';
  }

  // Function to show a dialog to edit user
  void _showEditUserDialog(Map<String, dynamic> user) {
    final TextEditingController usernameController = TextEditingController(text: user['username']);
    final TextEditingController emailController = TextEditingController(text: user['email']);
    final TextEditingController addressController = TextEditingController(text: user['address']);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit User'),
          content: Column(
            children: [
              TextField(
                controller: usernameController,
                decoration: const InputDecoration(labelText: 'Username'),
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(labelText: 'Address'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Update the user in Firestore
                Map<String, dynamic> updatedData = {
                  'username': usernameController.text,
                  'email': emailController.text,
                  'address': addressController.text,
                  'createdAt': user['createdAt'], // Keep the original createdAt
                };
                updateUser(user['id'], updatedData);
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}

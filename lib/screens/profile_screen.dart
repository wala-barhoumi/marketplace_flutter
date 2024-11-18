import 'package:app/screens/change_password_screen.dart';
import 'package:app/screens/edit_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth package
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore package

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late String username = '';
  late String email = '';

  // Sign out method
  Future<void> signout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print("Something went wrong: $e");
    }
  }

  // Fetch user profile from Firestore
  Future<void> fetchUserProfile() async {
    User? user = _auth.currentUser;
    if (user != null) {
      // Retrieve user data from Firestore using the user's UID
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (userDoc.exists) {
        setState(() {
          username = userDoc['username'] ?? 'No username';
          email = user.email ?? 'No email';
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUserProfile(); // Fetch user profile when the screen loads
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false, // Ensures no back arrow is displayed
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Picture Section
            const Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage('lib/assets/profile_picture.jpg'), // Replace with actual image
              ),
            ),
            const SizedBox(height: 16),
            // Profile Name and Email (Fetched from Firestore)
            Center(
              child: Column(
                children: [
                  Text(
                    username.isNotEmpty ? username : 'Loading...', // Show dynamic name or loading state
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    email.isNotEmpty ? email : 'Loading...', // Show dynamic email or loading state
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Account Settings Section
            const Text(
              'Account Settings',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Profile'),
              onTap: () async {
                // Navigate to EditProfileScreen and refresh on return
                bool? dataUpdated = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EditProfileScreen()),
                );

                // If data was updated, refresh the profile data
                if (dataUpdated != null && dataUpdated) {
                  fetchUserProfile(); // Refresh the profile data after returning from EditProfileScreen
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.lock),
              title: const Text('Change Password'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChangePasswordScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Notifications'),
              onTap: () {
                // Handle notifications settings action
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Log Out'),
              onTap: () {
                signout(); // Call the signout method when "Log Out" is tapped
                Navigator.pop(context); // Optionally, navigate back after sign-out
              },
            ),
          ],
        ),
      ),
    );
  }
}

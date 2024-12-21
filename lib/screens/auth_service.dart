import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<User?> createUserWithEmailAndPassword(
      String email, String password, String username, String address) async {
    try {
      // Create user in Firebase Authentication
      final cred = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      if (cred.user != null) {
        // Save additional user details in Firestore
        final userRef =
            FirebaseFirestore.instance.collection('users').doc(cred.user!.uid);
        await userRef.set({
          'username': username,
          'email': email,
          'address': address,
          'createdAt': FieldValue.serverTimestamp(),
        });
        log("User successfully created with username: $username and address: $address");
      }

      return cred.user;
    } catch (e) {
      log("Error during user creation: $e");
    }
    return null;
  }

  Future<User?> loginUserWithEmailAndPassword(
      String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return cred.user;
    } catch (e) {
      log("Something went wrong");
    }
    return null;
  }
  

  Future<User?> signInWithGoogle() async {
    try {
      // Ensure the user is signed out first
      await _googleSignIn.signOut();

      // Start Google Sign-In
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // Sign-in aborted by the user
        return null;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create credential for Firebase
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credentials
      final UserCredential userCredential = await _auth.signInWithCredential(credential);


      log("Google Sign-In successful: (${googleUser.email})");
      return userCredential.user;
    } catch (e) {
      log("Google Sign-In Error: $e");
      return null;
    }
  }

  Future<void> signout() async {
    try {
      await _auth.signOut();
      log("User signed out");
    } catch (e) {
      log("Something went wrong during sign-out");
    }
  }
  Future<void> signOut() async {
  await _googleSignIn.signOut();
  await _auth.signOut();
}

}

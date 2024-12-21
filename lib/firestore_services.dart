import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  // Fetch cart items for the current user
  Stream<List<DocumentSnapshot>> fetchCartItems() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return Stream.value([]); // Return empty list if user is not logged in
    }

    return FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .collection('cart')
        .snapshots()
        .map((snapshot) => snapshot.docs);
  }

  // Fetch favorite items for the current user
  Stream<List<DocumentSnapshot>> fetchFavoriteItems() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return Stream.value([]); // Return empty list if user is not logged in
    }

    return FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .collection('favorites')
        .snapshots()
        .map((snapshot) => snapshot.docs);
  }

  // Remove an item from the cart collection
  Future<void> removeItemFromCart(String itemId) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      print('User is not logged in');
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .collection('cart')
          .doc(itemId)
          .delete();
      print('Product removed from cart');
    } catch (e) {
      print('Error removing product from cart: $e');
    }
  }

  // Remove an item from the favorites collection
  Future<void> removeItemFromFavorites(String itemId) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      print('User is not logged in');
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .collection('favorites')
          .doc(itemId)
          .delete();
      print('Product removed from favorites');
    } catch (e) {
      print('Error removing product from favorites: $e');
    }
  }

  // Fetch product details using productId
  Future<DocumentSnapshot> fetchProductDetails(String productId) async {
    try {
      final productDoc = await FirebaseFirestore.instance.collection('products').doc(productId).get();
      return productDoc; // Return product document
    } catch (e) {
      print('Error fetching product details: $e');
      rethrow; // Rethrow the error so it can be caught where this function is called
    }
  }
}

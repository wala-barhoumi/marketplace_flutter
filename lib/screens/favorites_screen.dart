import 'dart:convert';

import 'package:app/firestore_services.dart';
import 'package:app/screens/cart_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FavoritesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Favorites')),
      body: StreamBuilder<List<DocumentSnapshot>>(
        stream: FirestoreService().fetchFavoriteItems(), // Fetch favorite items using FirestoreService
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final favoriteItems = snapshot.data ?? [];
          if (favoriteItems.isEmpty) {
            return Center(child: Text('No items in favorites'));
          }

          return ListView.builder(
            itemCount: favoriteItems.length,
            itemBuilder: (context, index) {
              final item = favoriteItems[index];
              final data = item.data() as Map<String, dynamic>?;

              // Check if data is valid
              if (data == null) {
                return ListTile(
                  title: Text('Invalid data'),
                  subtitle: Text('Missing required fields'),
                );
              }

              final productId = data['productId']; // Assuming 'productId' is stored
              final name = data['name'] ?? 'Unknown product';
              final price = data['price'] ?? 'Unknown price';
              final image = base64Decode(data['image'] ?? '');

              return ListTile(
                title: Text(name),
                subtitle: Text(price),
                leading: image.isNotEmpty
                    ? Image.memory(image, width: 50, height: 50, fit: BoxFit.cover)
                    : Icon(Icons.image, size: 50),
                onTap: () {
                  // Navigate to product details screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductDetailsScreen(productId: productId),
                    ),
                  );
                },
                trailing: IconButton(
                  icon: Icon(Icons.remove_circle_outline),
                  onPressed: () {
                    FirestoreService().removeItemFromFavorites(item.id); // Remove item using FirestoreService
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

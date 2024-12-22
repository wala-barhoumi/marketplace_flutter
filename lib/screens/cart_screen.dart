import 'dart:convert';
import 'package:app/firestore_services.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cart')),
      body: StreamBuilder<List<DocumentSnapshot>>(
        stream: FirestoreService().fetchCartItems(), // Fetch cart items using FirestoreService
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final cartItems = snapshot.data ?? [];
          if (cartItems.isEmpty) {
            return Center(child: Text('No items in cart'));
          }

          return ListView.builder(
            itemCount: cartItems.length,
            itemBuilder: (context, index) {
              final item = cartItems[index];
              final data = item.data() as Map<String, dynamic>?;

              // Check if data is valid
              if (data == null) {
                return ListTile(
                  title: Text('Invalid data'),
                  subtitle: Text('Missing required fields'),
                );
              }

              final productId = data['productId']; 
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
                    FirestoreService().removeItemFromCart(item.id); // Remove item using FirestoreService
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

class ProductDetailsScreen extends StatelessWidget {
  final String productId;
  const ProductDetailsScreen({required this.productId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Product Details')),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirestoreService().fetchProductDetails(productId), // Fetch product details using FirestoreService
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final productData = snapshot.data?.data() as Map<String, dynamic>?;
          if (productData == null) {
            return Center(child: Text('Product not found'));
          }

          final name = productData['name'];
          final price = productData['price'];
          final image = productData['image'];
          final description = productData['description'];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.network(image ?? '', height: 250, width: double.infinity, fit: BoxFit.cover),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name ?? 'Unknown product', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text('\$${price ?? 'Unknown price'}', style: TextStyle(fontSize: 18, color: Colors.green)),
                    SizedBox(height: 8),
                    Text(description ?? 'No description available', style: TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

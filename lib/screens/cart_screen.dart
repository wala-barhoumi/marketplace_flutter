import 'dart:convert';
import 'package:app/firestore_services.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app/screens/product_details.dart';
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
            double totalAmount = 0;
            cartItems.forEach((item) {
            final data = item.data() as Map<String, dynamic>?;
            if (data != null && data['price'] != null && data['quantity'] != null) {
             final price = double.tryParse(data['price'].toString()) ?? 0.0;
             final quantity = data['quantity'] is int ? data['quantity'] : int.tryParse(data['quantity'].toString()) ?? 0;
             totalAmount += (price * quantity);

            }
          });
          

           return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    final item = cartItems[index];
                    final data = item.data() as Map<String, dynamic>?;
                    if (data == null) {
                      return ListTile(
                        title: Text('Invalid data'),
                        subtitle: Text('Missing required fields'),
                      );
                    }

                    final productId = data['productId'];
                    final name = data['name'] ?? 'Unknown product';
                    final price = data['price'] ?? 'Unknown price';
                    final quantity = data['quantity'];
                    final image = base64Decode(data['image'] ?? '');

                    return ListTile(
                      title: Text(name),
                      subtitle: Text('Price: \ ${price} DT \nQuantity: $quantity'),
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
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Total Amount: \ ${totalAmount.toStringAsFixed(2) }DT',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () => _confirmOrder(cartItems, totalAmount, context),
                      child: Text('Confirm Order'),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _confirmOrder(
      List<DocumentSnapshot> cartItems, double totalAmount, BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please log in to confirm your order.')),
      );
      return;
    }

    final orderData = {
      'userId': user.uid,
      'totalAmount': totalAmount,
      'timestamp': FieldValue.serverTimestamp(),
    };

    try {
      await FirebaseFirestore.instance.collection('orders').add(orderData);

      // Clear the cart after confirming the order
      for (var item in cartItems) {
        await FirestoreService().removeItemFromCart(item.id);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order confirmed successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to confirm order: $e')),
      );
    }
  }
}

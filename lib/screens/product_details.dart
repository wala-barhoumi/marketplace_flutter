import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductDetailsScreen extends StatefulWidget {
  final String productId;

  const ProductDetailsScreen({Key? key, required this.productId}) : super(key: key);

  @override
  _ProductDetailsScreenState createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  late String productName = '';
  late String productDescription = '';
  late double productPrice = 0.0;
  late int productStock = 0;
  late String productCategory = '';
  late String productImage = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProductDetails();
  }

  Future<void> _fetchProductDetails() async {
    try {
      DocumentSnapshot productSnapshot = await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.productId)
          .get();

      if (productSnapshot.exists) {
        setState(() {
          productName = productSnapshot['name'] ?? '';
          productDescription = productSnapshot['description'] ?? '';
          productPrice = productSnapshot['price']?.toDouble() ?? 0.0;
          productStock = productSnapshot['stock']?.toInt() ?? 0;
          productCategory = productSnapshot['category'] ?? '';
          productImage = productSnapshot['image'] ?? '';
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product not found')),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching product details: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch product details: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                child: Column(
                  children: [
                    Expanded(
                      flex: 3,
                      child: productImage.isNotEmpty
                          ? (productImage.startsWith('data:image')
                              ? Image.memory(
                                  base64Decode(cleanBase64(productImage)),
                                  width: double.infinity,
                                  height: 200,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(Icons.image_not_supported, size: 50);
                                  },
                                )
                              : Image.network(
                                  productImage,
                                  width: double.infinity,
                                  height: 200,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(Icons.image_not_supported, size: 50);
                                  },
                                ))
                          : const Icon(Icons.image_not_supported, size: 50),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            productName,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$productPrice DT',
                            style: const TextStyle(fontSize: 14, color: Colors.green),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$productStock in stock',
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Details:',
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            productDescription,
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: () {
                              _toggleFavorite(widget.productId);
                            },
                            icon: const Icon(
                              Icons.favorite_border,
                              size: 28,
                              color: Colors.red,
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              _addToCart(widget.productId);
                            },
                            child: const Text(
                              'Add To Cart',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  void _toggleFavorite(String productId) async {
    // Implement your logic for toggling favorites here
  }

  void _addToCart(String productId) async {
    // Implement your logic for adding to cart here
  }

  String cleanBase64(String base64String) {
    if (base64String.startsWith('data:image')) {
      final parts = base64String.split(',');
      return parts.length > 1 ? parts[1] : '';
    }
    return base64String;
  }
}

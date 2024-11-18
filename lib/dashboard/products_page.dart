import 'package:flutter/material.dart';

class ProductPage extends StatelessWidget {
  const ProductPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and button to add a new product
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Product List',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Add action to navigate to a page to add a new product
                    // You can create a separate page or modal to add a product.
                  },
                  child: const Text('Add Product'),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Product List - In this example, we're using a hardcoded list of products.
            // Replace this with dynamic data (e.g., from Firebase or an API).
            Expanded(
              child: ListView.builder(
                itemCount: 5, // Update this with the number of products
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: Icon(Icons.shopping_bag, size: 40), // Placeholder for product image
                      title: Text('Product ${index + 1}'), // Product Name
                      subtitle: Text('Price: \$${(index + 1) * 10}'), // Product Price
                      onTap: () {
                        // Navigate to the product details page (optional)
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

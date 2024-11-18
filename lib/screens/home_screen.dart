import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth
import 'package:flutter/material.dart';
import 'package:app/screens/profile_screen.dart'; // ProfileScreen import

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0; // Track the selected index
  String deliveryAddress = 'Loading...'; // Default loading state for address

  // List of screens to show based on the selected index
  final List<Widget> _screens = [
    HomeContentScreen(), // Main home content
    const Center(child: Text("Favorites")), // Placeholder for Favorites screen
    const Center(child: Text("Cart")),       // Placeholder for Cart screen
    ProfileScreen(),  // Link ProfileScreen here
  ];

  @override
  void initState() {
    super.initState();
    _getAddress(); // Initial address fetch
  }

  // Function to get the address from Firestore
  Future<void> _getAddress() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        // Access the Firestore document
        DocumentSnapshot snapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();

        if (snapshot.exists) {
          // Extract the 'address' field from the document
          setState(() {
            deliveryAddress = snapshot['address'] ?? 'Address not available';
          });
        } else {
          setState(() {
            deliveryAddress = 'Address not found';
          });
        }
      } else {
        setState(() {
          deliveryAddress = 'User not logged in';
        });
      }
    } catch (e) {
      print('Error fetching address: $e');
      setState(() {
        deliveryAddress = 'Error loading address';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],  // Show screen based on selected index
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index; // Update the selected index

            // If the Home tab is selected, fetch the address again
            if (_currentIndex == 0) {
              _getAddress(); // Fetch address each time Home tab is clicked
            }
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: 'Favorites'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Cart'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}

// Updated HomeContentScreen with address from HomeScreen state
class HomeContentScreen extends StatelessWidget {
  const HomeContentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Retrieve the address from the nearest ancestor state (HomeScreen)
    String deliveryAddress = (context.findAncestorStateOfType<_HomeScreenState>()?.deliveryAddress) ?? 'Loading...';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false, // Remove the back arrow
        title: Row(
          children: [
            const Icon(Icons.location_on, color: Colors.blue, size: 20),  // Smaller icon size
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                'Delivery: $deliveryAddress',  // Display the address
                style: const TextStyle(color: Colors.black, fontSize: 12),  // Smaller font size
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.black, size: 20),  // Smaller icon size
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8.0),  // Reduced padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Add the search bar here
            TextField(
              decoration: InputDecoration(
                labelText: 'Search...',
                prefixIcon: const Icon(Icons.search, size: 18),  // Smaller icon size
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0), // Rounded corners
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: const BorderSide(
                    color: Colors.grey, // Color of the border
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide(
                    color: Theme.of(context).primaryColor, // Color when focused
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15), // Reduced spacing after the search bar
            _buildHighlightProduct(),
            const SizedBox(height: 15),
            _buildPopularCategories(),
            const SizedBox(height: 15),
            _buildProductGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildHighlightProduct() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.pink.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Image.asset(
            'lib/assets/rose_hibiscus_mist.png',
            width: 60,  // Reduced image size
            height: 90,  // Reduced image size
            fit: BoxFit.cover,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Rose Hibiscus Mist',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),  // Smaller font size
              ),
              const Text(
                '36.00',
                style: TextStyle(fontSize: 12, color: Colors.grey, decoration: TextDecoration.lineThrough),
              ),
              const Text(
                '34.20',
                style: TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              ElevatedButton(
                onPressed: () {},  // Smaller text
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),  // Reduced padding
                ),
                child: Text('Add to Cart', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPopularCategories() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Popular categories',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),  // Smaller font size
            ),
            GestureDetector(
              onTap: () {
                // Handle 'See all' navigation
              },
              child: const Text(
                'See all',
                style: TextStyle(color: Colors.blue, fontSize: 12),  // Smaller font size
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),  // Reduced spacing
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildCategoryIcon(Icons.face, 'Beauty'),
            _buildCategoryIcon(Icons.checkroom, 'Clothes'),
            _buildCategoryIcon(Icons.book, 'Books'),
            _buildCategoryIcon(Icons.home, 'Home'),
            _buildCategoryIcon(Icons.sports_soccer, 'Sport'),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryIcon(IconData iconData, String label) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: Colors.grey.shade200,
          child: Icon(iconData, color: Colors.black, size: 18),  // Smaller icon size
        ),
        const SizedBox(height: 5),
        Text(label, style: const TextStyle(fontSize: 10)),  // Smaller font size
      ],
    );
  }

  Widget _buildProductGrid() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 8,  // Reduced spacing
      mainAxisSpacing: 8,  // Reduced spacing
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildProductCard('Moisturising tonic', 'lib/assets/tonic.jpg', '\$27.90'),
        _buildProductCard('Facial moisturiser', 'lib/assets/moisturiser.jpg', '\$45.50'),
      ],
    );
  }

  Widget _buildProductCard(String name, String imagePath, String price) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 8, offset: const Offset(0, 4))],
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(imagePath, fit: BoxFit.cover, height: 100, width: double.infinity),  // Reduced image size
          Padding(
            padding: const EdgeInsets.all(6.0),  // Reduced padding
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),  // Smaller font size
                Text(price, style: const TextStyle(fontSize: 12, color: Colors.grey)),  // Smaller font size
              ],
            ),
          ),
        ],
      ),
    );
  }
}

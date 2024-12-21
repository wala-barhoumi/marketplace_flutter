import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'profile_screen.dart';
import 'cart_screen.dart';
import 'favorites_screen.dart';
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  String deliveryAddress = 'Chargement...';
  String searchQuery = '';

  final List<Widget> _screens = [
    const HomeContentScreen(),
    FavoritesScreen(),
     CartScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _fetchAddress();
  }

Future<void> _fetchAddress() async {
  try {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      if (mounted) {
        setState(() => deliveryAddress = 'Utilisateur non connecté');
      }
      return;
    }

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .get();

    if (mounted) {
      setState(() {
        deliveryAddress = userDoc.exists
            ? (userDoc['address'] ?? 'Adresse non disponible')
            : 'Adresse introuvable';
      });
    }
  } catch (e) {
    if (mounted) {
      setState(() => deliveryAddress = 'Erreur de chargement de l\'adresse');
    }
    debugPrint('Erreur lors de la récupération de l\'adresse : $e');
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            if (_currentIndex == 0) _fetchAddress(); // Refresh address on home tab
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: 'Favoris'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Panier'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}

class HomeContentScreen extends StatefulWidget {
  const HomeContentScreen({super.key});

  @override
  State<HomeContentScreen> createState() => _HomeContentScreenState();
}

class _HomeContentScreenState extends State<HomeContentScreen> {
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final homeScreenState = context.findAncestorStateOfType<_HomeScreenState>();
    final deliveryAddress = homeScreenState?.deliveryAddress ?? 'Chargement...';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.location_on, color: Colors.blue),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                'Livraison : $deliveryAddress',
                style: const TextStyle(color: Colors.black, fontSize: 14),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchBar(),
            const SizedBox(height: 15),
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

  Widget _buildSearchBar() {
    return TextField(
      onChanged: (query) {
        setState(() {
          searchQuery = query;
        });
      },
      decoration: InputDecoration(
        labelText: 'Rechercher...',
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
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
          Image.asset('lib/assets/rose_hibiscus_mist.png', width: 50, height: 80),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Rose Hibiscus Mist', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              const Text('\36.00 DT', style: TextStyle(fontSize: 10, color: Colors.grey, decoration: TextDecoration.lineThrough)),
              const Text('\34.20 DT', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4)),
                child: const Text('Ajouter au panier', style: TextStyle(fontSize: 10)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPopularCategories() {
    const categories = [
      {'label': 'Beauté', 'icon': Icons.face},
      {'label': 'Vêtements', 'icon': Icons.shopping_bag},
      {'label': 'Livres', 'icon': Icons.book},
      {'label': 'Maison', 'icon': Icons.house},
      {'label': 'Sport', 'icon': Icons.sports_baseball},
      {'label': 'Jeux', 'icon': Icons.videogame_asset},
    ];

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text('Catégories populaires', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            Text('Voir tout', style: TextStyle(color: Colors.blue)),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: categories.map((category) => _buildCategoryIcon(category['icon'] as IconData, category['label'] as String)).toList(),
        ),
      ],
    );
  }

  Widget _buildCategoryIcon(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, size: 24),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildProductGrid() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('products').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Erreur lors du chargement des produits'));
        }
        final products = snapshot.data?.docs ?? [];
        final filteredProducts = products.where((product) {
          final name = product['name'] ?? '';
          return name.toLowerCase().contains(searchQuery.toLowerCase());
        }).toList();

        return filteredProducts.isEmpty
            ? const Center(child: Text('Aucun produit trouvé'))
            : GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredProducts.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemBuilder: (context, index) {
                  final product = filteredProducts[index];
                  return _buildProductCard(
                    product['name'] ?? 'Produit sans nom',
                    product['image'] ?? '',
                    product['price']?.toString() ?? '0.00',
                    product.id, // Use product ID for favoriting and cart actions
                  );
                },
              );
      },
    );
  }

Widget _buildProductCard(String name, String image, String price, String productId) {
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProductDetailsScreen(productId: productId),
        ),
      );
    },
    child: Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Column(
        children: [
          Expanded(
            child: image.isNotEmpty && (image.startsWith('http') || image.startsWith('data:image'))
                ? (image.startsWith('data:image')
                    ? Image.memory(
                        base64Decode(cleanBase64(image)),
                        width: double.infinity,
                        height: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.image_not_supported, size: 50);
                        },
                      )
                    : Image.network(
                        image,
                        width: double.infinity,
                        height: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.image_not_supported, size: 50);
                        },
                      ))
                : const Icon(Icons.image_not_supported, size: 50),
          ),
          Padding(
            padding: const EdgeInsets.all(6),
            child: Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(6),
            child: Text(
              '$price DT',
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {
                  _toggleFavorite(productId);
                },
                icon: const Icon(Icons.favorite_border, size: 24, color: Colors.red),
              ),
              IconButton(
                onPressed: () {
                  _addToCart(productId);
                },
                icon: const Icon(Icons.card_giftcard, size: 24, color: Colors.blue),
              ),
            ],
          )
        ],
      ),
    )
     );
  }

 void _toggleFavorite(String productId) async {
  final currentUser = FirebaseAuth.instance.currentUser;

  if (currentUser == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Veuillez vous connecter pour ajouter aux favoris')),
    );
    return;
  }

  final favoritesRef = FirebaseFirestore.instance
      .collection('users')
      .doc(currentUser.uid)
      .collection('favorites');

  final doc = await favoritesRef.doc(productId).get();

  if (doc.exists) {
    await favoritesRef.doc(productId).delete();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Produit retiré des favoris')),
    );
  } else {
    await favoritesRef.doc(productId).set({
      'productId': productId,
      'timestamp': FieldValue.serverTimestamp(),
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Produit ajouté aux favoris')),
    );
  }
}

 void _addToCart(String productId) async {
  final currentUser = FirebaseAuth.instance.currentUser;

  if (currentUser == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Veuillez vous connecter pour ajouter au panier')),
    );
    return;
  }

  final cartRef = FirebaseFirestore.instance
      .collection('users')
      .doc(currentUser.uid)
      .collection('cart');

  final doc = await cartRef.doc(productId).get();

  if (doc.exists) {
    await cartRef.doc(productId).update({
      'quantity': FieldValue.increment(1),
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Quantité du produit augmentée')),
    );
  } else {
    await cartRef.doc(productId).set({
      'productId': productId,
      'quantity': 1,
      'timestamp': FieldValue.serverTimestamp(),
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Produit ajouté au panier')),
    );
  }
}

}

String cleanBase64(String base64String) {
  if (base64String.startsWith('data:image')) {
    final parts = base64String.split(',');
    return parts.length > 1 ? parts[1] : '';
  }
  return base64String;
}

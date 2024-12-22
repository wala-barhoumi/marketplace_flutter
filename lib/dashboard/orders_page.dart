import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  _OrdersPageState createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch Orders Stream
  Stream<List<Map<String, dynamic>>> getOrdersStream() {
    return _firestore.collection('orders').snapshots().asyncMap((querySnapshot) async {
      List<Map<String, dynamic>> orders = [];
      for (var doc in querySnapshot.docs) {
        var orderData = doc.data();
        try {
          var subCollection = await doc.reference.collection('order_details').get();
          orderData['order_details'] = subCollection.docs.map((detail) => detail.data()).toList();
        } catch (e) {
          orderData['order_details'] = [];
          debugPrint('Error fetching order details for ${doc.id}: $e');
        }
        orderData['id'] = doc.id;
        orders.add(orderData);
      }
      return orders;
    });
  }

  // Fetch Products Stream
  Stream<List<Map<String, dynamic>>> getProductsStream() {
    return _firestore.collection('products').snapshots().map((querySnapshot) {
      return querySnapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'name': doc['name'],
          'price': doc['price'],
        };
      }).toList();
    });
  }

  // Add Order
  Future<void> addOrder(Map<String, dynamic> newOrder, List<Map<String, dynamic>> orderDetails) async {
    try {
      DocumentReference orderRef = await _firestore.collection('orders').add(newOrder);
      for (var detail in orderDetails) {
        await orderRef.collection('order_details').add(detail);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order added successfully')),
      );
    } catch (e) {
      debugPrint('Error adding order: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error adding order')),
      );
    }
  }

  // Edit Order
  Future<void> editOrder(String orderId, Map<String, dynamic> updatedData) async {
    try {
      await _firestore.collection('orders').doc(orderId).update(updatedData);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order updated successfully')),
      );
    } catch (e) {
      debugPrint('Error updating order: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error updating order')),
      );
    }
  }

  // Delete Order
  Future<void> deleteOrder(String orderId) async {
    try {
      await _firestore.collection('orders').doc(orderId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order deleted successfully')),
      );
    } catch (e) {
      debugPrint('Error deleting order: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error deleting order')),
      );
    }
  }

  // Show Add Order Dialog
  void showAddOrderDialog() {
    showDialog(
      context: context,
      builder: (context) {
        List<Map<String, dynamic>> selectedProducts = [];
        return AlertDialog(
          title: const Text('Add Order'),
          content: StreamBuilder<List<Map<String, dynamic>>>(
            stream: getProductsStream(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const CircularProgressIndicator();
              }
              final products = snapshot.data!;
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: products.map((product) {
                  return CheckboxListTile(
                    title: Text(product['name']),
                    subtitle: Text('Price: ${product['price']}'),
                    value: selectedProducts.contains(product),
                    onChanged: (selected) {
                      setState(() {
                        if (selected == true) {
                          selectedProducts.add(product);
                        } else {
                          selectedProducts.remove(product);
                        }
                      });
                    },
                  );
                }).toList(),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                await addOrder(
                  {
                    'order_date': DateTime.now().toString(),
                    'status': 'Pending',
                    'total': selectedProducts.fold<double>(0.0, (sum, item) => sum + (item['price'] as double)),
                  },
                  selectedProducts.map((e) => {'unit_price': e['price'], 'quantity': 1}).toList(),
                );
                Navigator.pop(context);
              },
              child: const Text('Add Order'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 189, 167, 204),
        title: const Text('Orders Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: showAddOrderDialog,
          ),
        ],
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: getOrdersStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No orders found'));
          }

          List<Map<String, dynamic>> orders = snapshot.data!;

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 16.0,
              headingRowHeight: 56.0,
              columns: const <DataColumn>[
                DataColumn(label: Text('Order Date')),
                DataColumn(label: Text('Status')),
                DataColumn(label: Text('Total')),
                DataColumn(label: Text('Details')),
                DataColumn(label: Text('Actions')),
              ],
              rows: orders.map((order) {
                return DataRow(
                  cells: <DataCell>[
                    DataCell(Text(order['order_date'] ?? 'No Date')),
                    DataCell(Text(order['status'] ?? 'Pending')),
                    DataCell(Text(order['total']?.toString() ?? '0')),
                    DataCell(
                      Text(order['order_details']
                          .map((detail) => "Unit: ${detail['unit_price']}, Qty: ${detail['quantity']}")
                          .join(', ')),
                    ),
                    DataCell(
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => editOrder(order['id'], {'status': 'Updated'}),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => deleteOrder(order['id']),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}

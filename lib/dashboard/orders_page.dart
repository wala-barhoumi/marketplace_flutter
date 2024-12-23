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

      return orders;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 189, 167, 204),
        title: const Text('Orders Dashboard'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('orders').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No orders found'));
          }

         var orders = snapshot.data!.docs;

         return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('users').snapshots(),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                if (!userSnapshot.hasData || userSnapshot.data!.docs.isEmpty) {
                return const Center(child: Text('No users found'));
                }
                final users = userSnapshot.data!.docs;
                 return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columnSpacing: 56.0,
                    headingRowHeight: 56.0,
                    columns: const <DataColumn>[
                      DataColumn(label: Text('User Name', style: TextStyle(
                                fontSize: 16 ,
                                fontWeight: FontWeight.bold,
                              ),)),
                      DataColumn(label: Text('Order Date',style: TextStyle(
                                fontSize: 16 ,
                                fontWeight: FontWeight.bold,
                              ),)),
                      DataColumn(label: Text('Total Amount',style: TextStyle(
                                fontSize: 16 ,
                                fontWeight: FontWeight.bold,
                              ),)),
                      
                    
                    ],
                    rows: orders.map((order) {
                      final userId = order.get('userId');
                      final user = users.firstWhere((x) => x.id == userId);
                      return DataRow(
                        cells: <DataCell>[
                          DataCell(Text(user['username'])),
                          DataCell(Text(order['timestamp'].toDate().toString())),
                          DataCell(Text(order['totalAmount'].toString())),
                          
                        
                        ]
                      );
                    }).toList(),
                  ),
                );
              },
            );

         
        },
      ),
    );
  }
}

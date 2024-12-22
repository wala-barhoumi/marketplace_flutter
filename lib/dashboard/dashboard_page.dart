import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  // This method counts the documents in a Firestore collection
  Future<int> getDocumentCount(String collectionName) async {
    // Reference to the Firestore collection
    CollectionReference collectionRef = FirebaseFirestore.instance.collection(collectionName);

    // Fetch the documents from the collection
    QuerySnapshot snapshot = await collectionRef.get();

    // Return the number of documents in the collection
    return snapshot.size;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
      ),
      body: FutureBuilder<Map<String, int>>(
        // Fetch the statistics dynamically
        future: Future.wait([
          getDocumentCount('users'),
          getDocumentCount('products'),
          getDocumentCount('orders'),
        ]).then((values) {
          return {
            'users': values[0] as int,
            'products': values[1] as int,
            'orders': values[2] as int,
          };
        }),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final stats = snapshot.data!;

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Statistics Cards
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatCard('Users', stats['users'] ?? 0),
                      _buildStatCard('Products', stats['products'] ?? 0),
                      _buildStatCard('Orders', stats['orders'] ?? 0),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Chart to visualize the stats
                  _buildStatsChart(stats),
                ],
              ),
            );
          } else {
            return const Center(child: Text('No data available.'));
          }
        },
      ),
    );
  }

  // Helper function to create a stat card
  Widget _buildStatCard(String title, int value) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '$value',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  // Helper function to create the stats chart using FL Chart
  Widget _buildStatsChart(Map<String, int> stats) {
    return AspectRatio(
      aspectRatio: 1.3,
      child: BarChart(
        BarChartData(
          borderData: FlBorderData(show: false),
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(show: false),
          barGroups: [
            BarChartGroupData(
              x: 0,
              barRods: [
                BarChartRodData(
                  y: stats['users']!.toDouble(),
                  rodStackItems: [
                    BarChartRodStackItem(0, stats['users']!.toDouble(), Colors.blue),
                  ],
                  width: 30,
                ),
              ],
            ),
            BarChartGroupData(
              x: 1,
              barRods: [
                BarChartRodData(
                  y: stats['products']!.toDouble(),
                  rodStackItems: [
                    BarChartRodStackItem(0, stats['products']!.toDouble(), Colors.green),
                  ],
                  width: 30,
                ),
              ],
            ),
            BarChartGroupData(
              x: 2,
              barRods: [
                BarChartRodData(
                  y: stats['orders']!.toDouble(),
                  rodStackItems: [
                    BarChartRodStackItem(0, stats['orders']!.toDouble(), Colors.red),
                  ],
                  width: 30,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: DashboardPage(),
  ));
}

import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});
  Stream<Map<String, int>> getStatsStream() {
    final userStream = FirebaseFirestore.instance.collection('users').snapshots().map((snapshot) => snapshot.size);
    final productStream = FirebaseFirestore.instance.collection('products').snapshots().map((snapshot) => snapshot.size);
    final orderStream = FirebaseFirestore.instance.collection('orders').snapshots().map((snapshot) => snapshot.size);

    return StreamZip([userStream, productStream, orderStream]).map((values) {
      return {
        'users': values[0],
        'products': values[1],
        'orders': values[2],
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), 
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFFF),
        title: const Text('Admin Dashboard', style: TextStyle(color: Colors.black)),
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 1,
      ),
      body: StreamBuilder<Map<String, int>>(
        stream: getStatsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final stats = snapshot.data!;

            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatCard('Users', stats['users'] ?? 0, const Color(0xFF3AB4F2)),
                        _buildStatCard('Products', stats['products'] ?? 0, const Color(0xFFF2C94C)),
                        _buildStatCard('Orders', stats['orders'] ?? 0, const Color(0xFF27AE60)),
                      ],
                    ),
                  ],
                ),
              ),
            );
          } else {
            return const Center(child: Text('No data available.'));
          }
        },
      ),
    );
  }

  Widget _buildStatCard(String title, int value, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(8.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 100,
              width: 100,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      value: value.toDouble(),
                      color: color,
                      radius: 50,
                      title: '',
                    ),
                    PieChartSectionData(
                      value: 100 - value.toDouble(),
                      color: Colors.grey[200],
                      radius: 50,
                      title: '',
                    ),
                  ],
                  sectionsSpace: 0,
                  centerSpaceRadius: 30,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '$value',
              style: TextStyle(
                color: color,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
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

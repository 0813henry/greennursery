// lib/page/history_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:greennursery/data/cart_controller.dart';

class HistoryPage extends StatefulWidget {
  final CartController cartController;

  const HistoryPage({Key? key, required this.cartController}) : super(key: key);

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  String selectedFilter = 'Todas las fechas';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Compras'),
        backgroundColor: Colors.green,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Filtrar por fecha:', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 10),
                DropdownButton<String>(
                  value: selectedFilter,
                  items: [
                    'Todas las fechas',
                    'Última semana',
                    'Último mes',
                    'Último año',
                  ].map((String filter) {
                    return DropdownMenuItem<String>(
                      value: filter,
                      child: Text(filter),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedFilter = newValue!;
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getFilteredStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      'No tienes compras previas.',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  );
                }

                final purchaseItems = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: purchaseItems.length,
                  itemBuilder: (context, index) {
                    final purchase = purchaseItems[index];
                    final date = (purchase['date'] as Timestamp).toDate();
                    final totalAmount = purchase['totalAmount'] ?? 0.0;
                    final items = purchase['items'] as List;

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        title: Text(
                          'Compra realizada el: ${date.toLocal()}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(
                          'Total: \$${totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.expand_more, color: Colors.green),
                          onPressed: () => _showPurchaseDetails(context, items),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Stream<QuerySnapshot> _getFilteredStream() {
    DateTime? startDate;

    switch (selectedFilter) {
      case 'Última semana':
        startDate = DateTime.now().subtract(const Duration(days: 7));
        break;
      case 'Último mes':
        startDate = DateTime.now().subtract(const Duration(days: 30));
        break;
      case 'Último año':
        startDate = DateTime.now().subtract(const Duration(days: 365));
        break;
      default:
        return FirebaseFirestore.instance
            .collection('users')
            .doc(widget.cartController.userId)
            .collection('purchases')
            .orderBy('date', descending: true)
            .snapshots();
    }

    return FirebaseFirestore.instance
        .collection('users')
        .doc(widget.cartController.userId)
        .collection('purchases')
        .where('date', isGreaterThanOrEqualTo: startDate)
        .orderBy('date', descending: true)
        .snapshots();
  }

  void _showPurchaseDetails(BuildContext context, List items) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text(
            'Detalles de la Compra',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: items.map<Widget>((item) {
                final name = item['name'];
                final price = item['price'];
                final quantity = item['quantity'];
                final itemTotal = price * quantity;

                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListTile(
                    title: Text(
                      name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Precio: \$${price.toStringAsFixed(2)} x $quantity = \$${itemTotal.toStringAsFixed(2)}',
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cerrar',
                style: TextStyle(color: Colors.green, fontSize: 16),
              ),
            ),
          ],
        );
      },
    );
  }
}

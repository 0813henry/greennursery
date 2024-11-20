// lib/page/history_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:greennursery/data/cart_controller.dart';

class HistoryPage extends StatefulWidget {
  final CartController cartController;

  const HistoryPage({Key? key, required this.cartController}) : super(key: key);

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  DateTime? selectedStartDate;
  DateTime? selectedEndDate;

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
                ElevatedButton(
                  onPressed: () async {
                    DateTimeRange? pickedRange = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                      initialDateRange: selectedStartDate != null && selectedEndDate != null
                          ? DateTimeRange(start: selectedStartDate!, end: selectedEndDate!)
                          : null,
                    );
                    if (pickedRange != null) {
                      setState(() {
                        selectedStartDate = pickedRange.start;
                        selectedEndDate = pickedRange.end;
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: Text(
                    selectedStartDate != null && selectedEndDate != null
                        ? '${DateFormat('dd/MM/yyyy').format(selectedStartDate!)} - ${DateFormat('dd/MM/yyyy').format(selectedEndDate!)}'
                        : 'Seleccionar rango',
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.clear, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      selectedStartDate = null;
                      selectedEndDate = null;
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
                      child: ExpansionTile(
                        title: Text(
                          'Compra realizada el: ${DateFormat('dd/MM/yyyy').format(date)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(
                          'Total: \$${totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        children: items.map<Widget>((item) {
                          final name = item['name'];
                          final price = item['price'];
                          final quantity = item['quantity'];
                          final itemTotal = price * quantity;

                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
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
    var query = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.cartController.userId) // Verifica que userId sea el del usuario actual
        .collection('purchases')
        .orderBy('date', descending: true);

    if (selectedStartDate != null && selectedEndDate != null) {
      query = query
          .where('date', isGreaterThanOrEqualTo: selectedStartDate)
          .where('date', isLessThanOrEqualTo: selectedEndDate);
    }

    return query.snapshots();
  }
}

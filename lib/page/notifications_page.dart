import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationsPage extends StatefulWidget {
  @override
  _NotificationsPageState createState() => _NotificationsPageState();

  static Future<void> sendOrderNotification(String orderId, List<String> plantNames) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    for (var plantName in plantNames) {
      await FirebaseFirestore.instance
          .collection('notifications')
          .add({
        'userId': userId,
        'orderId': orderId,
        'plantName': plantName,
        'status': 'El pedido se ha realizado exitosamente',
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
  }
}

class _NotificationsPageState extends State<NotificationsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones'),
        backgroundColor: Colors.green,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .where('userId', isEqualTo: _auth.currentUser?.uid)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final notifications = snapshot.data!.docs;

          if (notifications.isEmpty) {
            return const Center(child: Text('No tienes notificaciones.'));
          }

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              final orderId = notification['orderId'];
              final plantName = notification['plantName'];
              final status = notification['status'];

              return Dismissible(
                key: Key(notification.id),
                direction: DismissDirection.endToStart,
                onDismissed: (direction) async {
                  await FirebaseFirestore.instance
                      .collection('notifications')
                      .doc(notification.id)
                      .delete();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Notificación eliminada')),
                  );
                },
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                child: ListTile(
                  title: Text('Pedido $orderId: $plantName'),
                  subtitle: Text(status),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
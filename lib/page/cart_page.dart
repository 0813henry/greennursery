import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:greennursery/data/cart_controller.dart';
import 'dart:math';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';

class CartPage extends StatefulWidget {
  final CartController cartController;
  final Function incrementNotificationCount;

  const CartPage({Key? key, required this.cartController, required this.incrementNotificationCount}) : super(key: key);

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final TextEditingController _addressController = TextEditingController();
  String? _selectedPaymentMethod;
  final List<String> _paymentMethods = ['Tarjeta de Crédito', 'PayPal', 'Transferencia Bancaria'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Carrito de Compras'),
        backgroundColor: Colors.green,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: widget.cartController.getCartItems(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Tu carrito está vacío.'));
          }

          final cartItems = snapshot.data!.docs;

          return FutureBuilder<double>(
            future: widget.cartController.getTotalAmount(),
            builder: (context, totalSnapshot) {
              if (totalSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              double totalAmount = totalSnapshot.data ?? 0;
              double tax = totalAmount * 0.15; // 15% tax
              double shippingCost = 10.0; // Fixed shipping cost
              double finalAmount = totalAmount + tax + shippingCost;

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total: \$${totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Impuestos (15%): \$${tax.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Costo de Envío: \$${shippingCost.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Total a Pagar: \$${finalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: cartItems.length,
                      itemBuilder: (context, index) {
                        final cartItem = cartItems[index];
                        final productId = cartItem['productId'];
                        final name = cartItem['name'];
                        final price = cartItem['price'];
                        final quantity = cartItem['quantity'];
                        final itemTotal = price * quantity;

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(12),
                            title: Text(
                              name,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            subtitle: Text(
                              'Precio: \$${price.toStringAsFixed(2)} x $quantity = \$${itemTotal.toStringAsFixed(2)}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove, color: Colors.red),
                                  onPressed: () async {
                                    if (quantity > 1) {
                                      await widget.cartController.updateQuantity(productId, quantity - 1);
                                    } else {
                                      await _removeFromCart(context, productId, quantity);
                                    }
                                  },
                                ),
                                Text(
                                  '$quantity',
                                  style: const TextStyle(fontSize: 18),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add, color: Colors.green),
                                  onPressed: () async {
                                    await _updateQuantity(context, productId, quantity + 1);
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.grey),
                                  onPressed: () async {
                                    await _removeFromCart(context, productId, quantity);
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        TextField(
                          controller: _addressController,
                          decoration: const InputDecoration(
                            labelText: 'Dirección de Entrega',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 10),
                        DropdownButtonFormField<String>(
                          value: _selectedPaymentMethod,
                          decoration: const InputDecoration(
                            labelText: 'Método de Pago',
                            border: OutlineInputBorder(),
                          ),
                          items: _paymentMethods.map((method) {
                            return DropdownMenuItem(
                              value: method,
                              child: Text(method),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedPaymentMethod = value!;
                            });
                          },
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton(
                              onPressed: () async {
                                try {
                                  await widget.cartController.clearCart();
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Carrito vaciado con éxito.')),
                                    );
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Error al vaciar el carrito: $e')),
                                    );
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text('Vaciar Carrito'),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                try {
                                  String orderId = _generateOrderId();
                                  await widget.cartController.makePayment();
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Pago realizado con éxito. Número de referencia: $orderId')),
                                    );
                                    widget.incrementNotificationCount();
                                    _simulateOrderStatus(orderId, cartItems.map((item) => item['name'] as String).toList());
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Error al realizar el pago: $e')),
                                    );
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text('Realizar Pago'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _removeFromCart(BuildContext context, String productId, int quantity) async {
    try {
      await widget.cartController.removeFromCart(productId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Producto eliminado del carrito.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar el producto del carrito: $e')),
      );
    }
  }

  Future<void> _updateQuantity(BuildContext context, String productId, int quantity) async {
    try {
      await widget.cartController.updateQuantity(productId, quantity);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cantidad actualizada.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar la cantidad: $e')),
      );
    }
  }

  String _generateOrderId() {
    final random = Random();
    final orderId = List.generate(10, (_) => random.nextInt(10)).join();
    return orderId;
  }

  void _simulateOrderStatus(String orderId, List<String> plantNames) {
    final statuses = ['Preparando envío', 'Pedido Enviado', 'Pedido Recibido'];
    int statusIndex = 0;
    final userId = FirebaseAuth.instance.currentUser?.uid;

    Timer.periodic(const Duration(seconds: 10), (timer) async {
      if (statusIndex >= statuses.length) {
        timer.cancel();
        return;
      }

      final status = statuses[statusIndex];
      for (var plantName in plantNames) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('notifications')
            .add({
          'orderId': orderId,
          'plantName': plantName,
          'status': status,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }

      statusIndex++;
      widget.incrementNotificationCount();
    });
  }
}

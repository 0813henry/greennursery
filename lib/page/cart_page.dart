// lib/page/cart_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:greennursery/data/cart_controller.dart';

class CartPage extends StatelessWidget {
  final CartController cartController;

  const CartPage({Key? key, required this.cartController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Carrito de Compras'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: cartController.getCartItems(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Tu carrito está vacío.'));
          }

          final cartItems = snapshot.data!.docs;

          return FutureBuilder<double>(
            future: cartController.getTotalAmount(),
            builder: (context, totalSnapshot) {
              if (totalSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              double totalAmount = totalSnapshot.data ?? 0; // Total del carrito

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Total a Pagar: \$${totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.right,
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

                        return ListTile(
                          title: Text(name),
                          subtitle: Text('Precio: \$${price.toStringAsFixed(2)} x $quantity = \$${itemTotal.toStringAsFixed(2)}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove),
                                onPressed: () async {
                                  if (quantity > 1) {
                                    await cartController.updateQuantity(productId, quantity - 1);
                                  } else {
                                    await _removeFromCart(context, productId, quantity);
                                  }
                                },
                              ),
                              Text('$quantity'),
                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: () async {
                                  await _updateQuantity(context, productId, quantity + 1);
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () async {
                                  await _removeFromCart(context, productId, quantity);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            try {
                              await cartController.clearCart();
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
                          child: const Text('Vaciar Carrito'),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            try {
                              await cartController.makePayment();
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Pago realizado con éxito.')),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error al realizar el pago: $e')),
                                );
                              }
                            }
                          },
                          child: const Text('Realizar Pago'),
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
      await cartController.removeFromCart(productId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Producto eliminado del carrito.')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar del carrito: $e')),
        );
      }
    }
  }

  Future<void> _updateQuantity(BuildContext context, String productId, int quantity) async {
    try {
      await cartController.updateQuantity(productId, quantity);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cantidad actualizada.')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar la cantidad: $e')),
        );
      }
    }
  }
}

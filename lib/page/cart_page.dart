<<<<<<< HEAD
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
=======
import 'package:flutter/material.dart';
import 'package:greennursery/data/cart_model.dart';

class CartPage extends StatefulWidget {
  final ShoppingCart cart;

  const CartPage({Key? key, required this.cart}) : super(key: key);

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Carrito de Compras'),
      backgroundColor: Colors.green, // Usando un color predeterminado.
    ),
    body: ListView.builder(
      itemCount: widget.cart.items.length,
      itemBuilder: (context, index) {
        var item = widget.cart.items[index];
        return ListTile(
          leading: Image.asset(item.plant.imagePath, width: 50),
          title: Text(item.plant.name),
          subtitle: Text('Cantidad: ${item.quantity}'),
          trailing: Text(
            '\$${(item.plant.price * item.quantity).toStringAsFixed(2)}',
          ),
        );
      },
    ),
    bottomNavigationBar: Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
        onPressed: () {
          _showCheckoutDialog();
        },
        child: Text(
          'Pagar - Total: \$${widget.cart.getTotalPrice().toStringAsFixed(2)}',
        ),
      ),
    ),
  );
}


  void _showCheckoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Pago'),
        content: const Text('¿Deseas completar la compra?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              widget.cart.clearCart();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Compra realizada con éxito')),
              );
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }
>>>>>>> 3c9bff7ee9d25b19aa3f7cab6ccdd00b70783cef
}

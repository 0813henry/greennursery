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
}

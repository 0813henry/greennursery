import 'package:flutter/material.dart';
import 'package:greennursery/core/color.dart';
import 'package:greennursery/data/plant_model.dart';
<<<<<<< HEAD
import 'package:greennursery/data/cart_controller.dart';
=======
import 'package:greennursery/data/cart_model.dart';
>>>>>>> 3c9bff7ee9d25b19aa3f7cab6ccdd00b70783cef
import 'package:greennursery/page/cart_page.dart';

class DetailsPage extends StatelessWidget {
  final Plants plant;
<<<<<<< HEAD
  final CartController cart;
=======
  final ShoppingCart cart;
>>>>>>> 3c9bff7ee9d25b19aa3f7cab6ccdd00b70783cef

  const DetailsPage({Key? key, required this.plant, required this.cart})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Sección de la imagen superior y detalles
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: height / 2,
                  decoration: BoxDecoration(
                    color: lightGreen,
                    boxShadow: [
                      BoxShadow(
                        color: green.withOpacity(0.2),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(60),
                      bottomRight: Radius.circular(60),
                    ),
                    image: DecorationImage(
                      image: NetworkImage(plant.imagePath), // Usar la URL de la imagen
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // Descripción del producto
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${plant.name} (${plant.category} Plant)',
                            style: TextStyle(
                              color: black.withOpacity(0.8),
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0,
                            ),
                          ),
<<<<<<< HEAD
                          IconButton(
                            icon: Image.asset('assets/icons/heart.png',
                                color: white),
                            onPressed: () {},
=======
                          Container(
                            height: 30.0,
                            width: 30.0,
                            padding: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              color: green,
                              boxShadow: [
                                BoxShadow(
                                  color: green.withOpacity(0.2),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Image.asset(
                              'assets/icons/heart.png',
                              color: white,
                            ),
>>>>>>> 3c9bff7ee9d25b19aa3f7cab6ccdd00b70783cef
                          ),
                        ],
                      ),
                      const SizedBox(height: 20.0),
                      Text(
                        plant.description,
                        style: TextStyle(
                          color: black.withOpacity(0.5),
                          fontSize: 15.0,
                          height: 1.4,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      Text(
                        'Treatment',
                        style: TextStyle(
                          color: black.withOpacity(0.9),
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Botón para retroceder y el ícono del carrito en la parte superior
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.arrow_back),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
<<<<<<< HEAD
                        builder: (context) => CartPage(cartController: cart),
=======
                        builder: (context) => CartPage(cart: cart),
>>>>>>> 3c9bff7ee9d25b19aa3f7cab6ccdd00b70783cef
                      ),
                    );
                  },
                  icon: Image.asset('assets/icons/cart.png',
                      color: black, height: 40.0),
                ),
              ],
            ),
            // Botón inferior para comprar
            Align(
              alignment: Alignment.bottomRight,
              child: GestureDetector(
                onTap: () {
<<<<<<< HEAD
                  _showQuantityDialog(context, plant); // Mostrar el diálogo para seleccionar la cantidad
=======
                  cart.addItem(plant);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Producto agregado al carrito'),
                    ),
                  );
>>>>>>> 3c9bff7ee9d25b19aa3f7cab6ccdd00b70783cef
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 50.0, vertical: 15.0),
                  decoration: BoxDecoration(
                    color: green,
<<<<<<< HEAD
=======
                    boxShadow: [
                      BoxShadow(
                        color: green.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, -5),
                      ),
                    ],
>>>>>>> 3c9bff7ee9d25b19aa3f7cab6ccdd00b70783cef
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(60),
                    ),
                  ),
                  child: Text(
                    'Buy \$${plant.price.toStringAsFixed(0)}',
                    style: TextStyle(
                      color: white.withOpacity(0.9),
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
<<<<<<< HEAD
=======
                      letterSpacing: 0.5,
>>>>>>> 3c9bff7ee9d25b19aa3f7cab6ccdd00b70783cef
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Función para mostrar el diálogo de selección de cantidad
  void _showQuantityDialog(BuildContext context, Plants plant) {
    int quantity = 1; // Cantidad inicial

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Seleccionar Cantidad'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Cantidad:'),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: () {
                              if (quantity > 1) {
                                setState(() {
                                  quantity--;
                                });
                              }
                            },
                          ),
                          Text(quantity.toString()),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () {
                              setState(() {
                                quantity++;
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el diálogo
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await cart.addItem(plant, quantity); // Agregar el item al carrito con la cantidad
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Producto agregado al carrito'),
                    ),
                  );
                  Navigator.of(context).pop(); // Cerrar el diálogo
                } catch (e) {
                  // Manejo de errores
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error al agregar al carrito: $e'),
                    ),
                  );
                }
              },
              child: const Text('Agregar al carrito'),
            ),
          ],
        );
      },
    );
  }
}

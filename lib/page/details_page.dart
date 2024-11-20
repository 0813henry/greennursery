import 'package:flutter/material.dart';
import 'package:greennursery/core/color.dart';
import 'package:greennursery/data/plant_model.dart';
import 'package:greennursery/data/cart_controller.dart';
import 'package:greennursery/page/cart_page.dart';
import 'package:greennursery/page/comments_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DetailsPage extends StatefulWidget {
  final Plants plant;
  final CartController cart;

  const DetailsPage({Key? key, required this.plant, required this.cart})
      : super(key: key);

  @override
  _DetailsPageState createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _checkIfFavorite();
  }

  Future<void> _checkIfFavorite() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      bool isFavorite = await widget.cart.isFavorite(widget.plant.id);
      setState(() {
        _isFavorite = isFavorite;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      if (_isFavorite) {
        await widget.cart.removeFromFavorites(widget.plant.id);
        setState(() {
          _isFavorite = false;
        });
      } else {
        await widget.cart.addToFavorites(widget.plant);
        setState(() {
          _isFavorite = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
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
                        image: NetworkImage(widget.plant.imagePath), // Usar la URL de la imagen
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
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
                              '${widget.plant.name} (${widget.plant.category} Plant)',
                              style: TextStyle(
                                color: black.withOpacity(0.8),
                                fontWeight: FontWeight.bold,
                                fontSize: 18.0,
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                _isFavorite ? Icons.favorite : Icons.favorite_border,
                                color: _isFavorite ? Colors.red : const Color.fromARGB(255, 33, 197, 33),
                              ),
                              onPressed: _toggleFavorite,
                            ),
                          ],
                        ),
                        const SizedBox(height: 20.0),
                        Text(
                          widget.plant.description,
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
                        const SizedBox(height: 20.0),
                        _buildRatingSection(context), // Sección de calificación
                        const SizedBox(height: 20.0),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CommentsPage(plant: widget.plant),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green, // Color de fondo
                            foregroundColor: Colors.white, // Color del texto
                            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30), // Bordes redondeados
                            ),
                            elevation: 5, // Sombra
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.comment, color: Colors.white), // Icono
                              SizedBox(width: 10),
                              Text(
                                'View Comments',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
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
                        builder: (context) => CartPage(cartController: widget.cart),
                      ),
                    );
                  },
                  icon: Image.asset('assets/icons/cart.png',
                      color: black, height: 40.0),
                ),
              ],
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: GestureDetector(
                onTap: () {
                  _showQuantityDialog(context, widget.plant); // Mostrar el diálogo para seleccionar la cantidad
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 50.0, vertical: 15.0),
                  decoration: BoxDecoration(
                    color: green,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(60),
                    ),
                  ),
                  child: Text(
                    'Buy \$${widget.plant.price.toStringAsFixed(0)}',
                    style: TextStyle(
                      color: white.withOpacity(0.9),
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
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

  Widget _buildRatingSection(BuildContext context) {
    double rating = 0;
    TextEditingController commentController = TextEditingController();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rate this plant',
          style: TextStyle(
            color: black.withOpacity(0.9),
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10.0),
        RatingBar.builder(
          initialRating: 0,
          minRating: 0,
          direction: Axis.horizontal,
          allowHalfRating: true,
          itemCount: 5,
          itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
          itemBuilder: (context, _) => const Icon(
            Icons.star,
            color: Colors.amber,
          ),
          onRatingUpdate: (ratingValue) {
            rating = ratingValue;
          },
        ),
        const SizedBox(height: 20.0),
        TextField(
          controller: commentController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Leave a comment',
          ),
          maxLines: 3,
        ),
        const SizedBox(height: 20.0),
        ElevatedButton(
          onPressed: () {
            _submitRating(context, rating, commentController.text);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green, // Color de fondo
            foregroundColor: Colors.white, // Color del texto
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30), // Bordes redondeados
            ),
            elevation: 5, // Sombra
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.send, color: Colors.white), // Icono
              SizedBox(width: 10),
              Text(
                'Submit',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _submitRating(BuildContext context, double rating, String comment) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Obtener el nombre del usuario desde la colección 'users'
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        String userName = userDoc['name'] ?? 'Anonymous';

        await FirebaseFirestore.instance.collection('ratings').add({
          'plantId': widget.plant.id,
          'rating': rating,
          'comment': comment,
          'userName': userName,
          'timestamp': FieldValue.serverTimestamp(),
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Rating: $rating, Comment: $comment'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You need to be logged in to submit a rating.'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
        ),
      );
    }
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
                  await widget.cart.addItem(plant, quantity); // Agregar el item al carrito con la cantidad
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
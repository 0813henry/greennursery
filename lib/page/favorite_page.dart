import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:greennursery/data/plant_model.dart';
import 'package:greennursery/page/details_page.dart';
import 'package:greennursery/data/cart_controller.dart';

class FavoritePage extends StatelessWidget {
  final CartController cartController;

  const FavoritePage({Key? key, required this.cartController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favoritos'),
        backgroundColor: Colors.green,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser?.uid)
            .collection('favorites')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var favorites = snapshot.data!.docs;

          if (favorites.isEmpty) {
            return const Center(child: Text('No tienes favoritos.'));
          }

          return ListView.builder(
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              var favorite = favorites[index];
              var plant = Plants(
                id: favorite['plantId'],
                name: favorite['name'],
                imagePath: favorite['imagePath'],
                category: favorite['category'],
                description: '', // Puedes agregar más detalles si es necesario
                price: 0.0, // Puedes agregar más detalles si es necesario
                isFavorit: true,
                stock: 0, // Puedes agregar más detalles si es necesario
              );

              return ListTile(
                leading: Image.network(
                  plant.imagePath,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
                ),
                title: Text(plant.name),
                subtitle: Text(plant.category),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () async {
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(FirebaseAuth.instance.currentUser?.uid)
                        .collection('favorites')
                        .doc(plant.id)
                        .delete();
                  },
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailsPage(plant: plant, cart: cartController),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
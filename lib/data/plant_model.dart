import 'package:cloud_firestore/cloud_firestore.dart';

class Plants {
  final String id;
  final String name;
  final String imagePath;
  final String category;
  final String description;
  final double price;
  final bool isFavorit;
  final int stock;

  Plants({
    required this.id,
    required this.name,
    required this.imagePath,
    required this.category,
    required this.description,
    required this.price,
    required this.isFavorit,
    required this.stock,
  });

  // Método para crear una instancia de Plants desde un documento de Firestore
  factory Plants.fromDocument(DocumentSnapshot doc) {
    return Plants(
      id: doc.id, // El ID del documento
      name: doc['name'] ?? '',
      imagePath: doc['imagePath'] ?? '',
      category: doc['category'] ?? '',
      description: doc['description'] ?? '',
      price: (doc['price'] ?? 0).toDouble(),
      isFavorit: doc['isFavorit'] ?? false,
      stock: (doc['stock'] ?? 0).toInt(), // Asegúrate de convertir a int
    );
  }
  // Método para convertir la instancia de Plants a un Map, útil para guardar en Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'imagePath': imagePath,
      'category': category,
      'description': description,
      'price': price,
      'isFavorit': isFavorit,
      'stock': stock,
    };
  }
  // Método para copiar el objeto con nuevos valores
  Plants copyWith({
    String? id,
    String? name,
    String? imagePath,
    String? category,
    String? description,
    double? price,
    bool? isFavorit,
    int? stock,
  }) {
    return Plants(
      id: id ?? this.id,
      name: name ?? this.name,
      imagePath: imagePath ?? this.imagePath,
      category: category ?? this.category,
      description: description ?? this.description,
      price: price ?? this.price,
      isFavorit: isFavorit ?? this.isFavorit,
      stock: stock ?? this.stock,
    );
  }
}
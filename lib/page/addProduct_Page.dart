import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({Key? key}) : super(key: key);

  @override
  _AddProductPageState createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _imagePathController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _selectedCategory;
  bool _isLoading = false;
  String? _editProductId;

  Future<void> _addOrUpdateProduct() async {
    if (_auth.currentUser?.email != 'admin@gmail.com') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No tienes permiso para modificar productos.')),
      );
      return;
    }

    String name = _nameController.text.trim();
    String imagePath = _imagePathController.text.trim();
    String description = _descriptionController.text.trim();
    double? price = double.tryParse(_priceController.text.trim());
    int? stock = int.tryParse(_stockController.text.trim());

    if (name.isEmpty || imagePath.isEmpty || _selectedCategory == null || description.isEmpty || price == null || stock == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor completa todos los campos.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (_editProductId == null) {
        // Agregar nuevo producto
        await _firestore.collection('plants').add({
          'name': name,
          'imagePath': imagePath,
          'category': _selectedCategory,
          'description': description,
          'price': price,
          'stock': stock,
          'isFavorit': false,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Producto agregado exitosamente.')),
        );
      } else {
        // Actualizar producto existente
        await _firestore.collection('plants').doc(_editProductId).update({
          'name': name,
          'imagePath': imagePath,
          'category': _selectedCategory,
          'description': description,
          'price': price,
          'stock': stock,
          'isFavorit': false,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Producto actualizado exitosamente.')),
        );
      }
      _clearFields();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al procesar el producto: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _clearFields() {
    _nameController.clear();
    _imagePathController.clear();
    _descriptionController.clear();
    _priceController.clear();
    _stockController.clear();
    _selectedCategory = null;
    _editProductId = null;
  }

  void _editProduct(DocumentSnapshot product) {
    setState(() {
      _editProductId = product.id;
      _nameController.text = product['name'];
      _imagePathController.text = product['imagePath'];
      _selectedCategory = product['category'];
      _descriptionController.text = product['description'];
      _priceController.text = product['price'].toString();
      _stockController.text = product['stock'].toString();
    });
  }

  Future<void> _deleteProduct(String productId) async {
    try {
      await _firestore.collection('plants').doc(productId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Producto eliminado exitosamente.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar el producto: $e')),
      );
    }
  }

  Future<void> _signOut() async {
    await _auth.signOut();
    Navigator.of(context).pushReplacementNamed('/login'); // Redirige a la página de inicio de sesión
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Productos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Formulario de producto
            Expanded(
              child: ListView(
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Nombre'),
                  ),
                  TextField(
                    controller: _imagePathController,
                    decoration: const InputDecoration(labelText: 'Ruta de la Imagen'),
                  ),
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    hint: const Text('Seleccionar categoría'),
                    items: [
                      'Exterior',
                      'Interior',
                      'Cactus',
                      'Oficina',
                      'Bonsai',
                      'Bromelias',
                      'Buena Suerte',
                      'Carnivoras',
                      'Florales',
                      'Hojas',
                      'Huerta',
                      'Jardin & Balcon',
                      'Orquideas',
                      'Purificadoas de Aire',
                      'Rastreras & Enredaderas'
                    ].map((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedCategory = newValue;
                      });
                    },
                    decoration: const InputDecoration(labelText: 'Categoría'),
                  ),
                  TextField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(labelText: 'Descripción'),
                  ),
                  TextField(
                    controller: _priceController,
                    decoration: const InputDecoration(labelText: 'Precio'),
                    keyboardType: TextInputType.number,
                  ),
                  TextField(
                    controller: _stockController,
                    decoration: const InputDecoration(labelText: 'Stock'),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  _isLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: _addOrUpdateProduct,
                          child: Text(_editProductId == null ? 'Agregar Producto' : 'Actualizar Producto'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                  const Divider(),
                  const SizedBox(height: 10),
                ],
              ),
            ),
            // Lista de productos
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection('plants').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return const Center(child: Text('Error al cargar productos'));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No hay productos disponibles'));
                  }

                  return ListView(
                    children: snapshot.data!.docs.map((product) {
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ListTile(
                          leading: SizedBox(
                            width: 50,
                            height: 50,
                            child: Image.network(product['imagePath'], fit: BoxFit.cover),
                          ),
                          title: Text(product['name']),
                          subtitle: Text(
                            'Categoría: ${product['category']} - Precio: \$${product['price']}',
                            style: const TextStyle(color: Colors.grey),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _editProduct(product),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteProduct(product.id),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:greennursery/data/plant_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../page/login_page.dart';

class AddProductPage extends StatefulWidget {
  @override
  _AddProductPageState createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _imagePathController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  String? _selectedCategory;

  final List<String> _categories = [
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
  ];

  Future<void> _addPlant() async {
    final plant = Plants(
      id: '',
      name: _nameController.text,
      imagePath: _imagePathController.text,
      category: _selectedCategory ?? '',
      description: _descriptionController.text,
      price: double.parse(_priceController.text),
      isFavorit: false,
      stock: int.parse(_stockController.text),
    );

    await FirebaseFirestore.instance.collection('plants').add(plant.toMap());
    _clearFields();
  }

  void _clearFields() {
    _nameController.clear();
    _imagePathController.clear();
    _descriptionController.clear();
    _priceController.clear();
    _stockController.clear();
    setState(() {
      _selectedCategory = null;
    });
  }

  Future<void> _deletePlant(String id) async {
    await FirebaseFirestore.instance.collection('plants').doc(id).delete();
  }

  Future<void> _updatePlant(Plants plant) async {
    await FirebaseFirestore.instance.collection('plants').doc(plant.id).update(plant.toMap());
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Administrar Plantas'),
        leading: IconButton(
          icon: Icon(Icons.logout),
          onPressed: _logout,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildTextField(_nameController, 'Nombre', Icons.local_florist),
            SizedBox(height: 10),
            _buildTextField(_imagePathController, 'Ruta de Imagen', Icons.image),
            SizedBox(height: 10),
            _buildDropdownButtonFormField(),
            SizedBox(height: 10),
            _buildTextField(_descriptionController, 'Descripción', Icons.description),
            SizedBox(height: 10),
            _buildTextField(_priceController, 'Precio', Icons.attach_money, TextInputType.number),
            SizedBox(height: 10),
            _buildTextField(_stockController, 'Stock', Icons.storage, TextInputType.number),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addPlant,
              child: Text('Agregar Planta'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                textStyle: TextStyle(fontSize: 16),
              ),
            ),
            SizedBox(height: 20),
            _buildPlantList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String labelText, IconData icon, [TextInputType keyboardType = TextInputType.text]) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(),
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.white,
      ),
      keyboardType: keyboardType,
    );
  }

  Widget _buildDropdownButtonFormField() {
    return DropdownButtonFormField<String>(
      value: _selectedCategory,
      decoration: InputDecoration(
        labelText: 'Categoría',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.category),
        filled: true,
        fillColor: Colors.white,
      ),
      items: _categories.map((category) {
        return DropdownMenuItem(
          value: category,
          child: Text(category),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedCategory = value;
        });
      },
    );
  }

  Widget _buildPlantList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('plants').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }

        final plants = snapshot.data!.docs.map((doc) => Plants.fromDocument(doc)).toList();

        return ListView.builder(
          shrinkWrap: true,
          itemCount: plants.length,
          itemBuilder: (context, index) {
            final plant = plants[index];
            return Card(
              margin: EdgeInsets.symmetric(vertical: 10),
              child: ListTile(
                title: Text(plant.name),
                subtitle: Text('Stock: ${plant.stock}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        _nameController.text = plant.name;
                        _imagePathController.text = plant.imagePath;
                        _selectedCategory = plant.category;
                        _descriptionController.text = plant.description;
                        _priceController.text = plant.price.toString();
                        _stockController.text = plant.stock.toString();
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text('Modificar Planta'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _buildTextField(_nameController, 'Nombre', Icons.local_florist),
                                  _buildTextField(_imagePathController, 'Ruta de Imagen', Icons.image),
                                  _buildDropdownButtonFormField(),
                                  _buildTextField(_descriptionController, 'Descripción', Icons.description),
                                  _buildTextField(_priceController, 'Precio', Icons.attach_money, TextInputType.number),
                                  _buildTextField(_stockController, 'Stock', Icons.storage, TextInputType.number),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('Cancelar'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    final updatedPlant = plant.copyWith(
                                      name: _nameController.text,
                                      imagePath: _imagePathController.text,
                                      category: _selectedCategory ?? '',
                                      description: _descriptionController.text,
                                      price: double.parse(_priceController.text),
                                      stock: int.parse(_stockController.text),
                                    );
                                    _updatePlant(updatedPlant);
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('Guardar'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => _deletePlant(plant.id),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
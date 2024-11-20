import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'forgot_password.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String? _imagePath;
  final FirebaseStorage storage = FirebaseStorage.instance;
  Color _backgroundColor = Colors.green.shade100;
  String? userId;
  String? userName;
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getCurrentUserId();
  }

  Future<void> _getCurrentUserId() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        setState(() {
          userId = user.uid;
        });
        _loadUserSettings();
      } else {
        print("Usuario no autenticado");
      }
    } catch (e) {
      print("Error al obtener el ID del usuario: $e");
    }
  }

  Future<void> _loadUserSettings() async {
    if (userId == null) return;
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (userDoc.exists) {
        setState(() {
          userName = userDoc['name'] ?? 'Usuario';
          _nameController.text = userName!;
          _imagePath = userDoc['profileImage'];
          int colorValue = userDoc['backgroundColor'] ?? Colors.green.shade100.value;
          _backgroundColor = Color(colorValue);
        });
      } else {
        print("El documento del usuario no existe.");
      }
    } catch (e) {
      print("Error al cargar la configuración del usuario: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
        backgroundColor: Colors.green,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.shade300, Colors.green.shade700],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: _imagePath != null
                        ? NetworkImage(_imagePath!)
                        : const AssetImage('assets/default_profile.png') as ImageProvider,
                    onBackgroundImageError: (_, __) {
                      setState(() {
                        _imagePath = null;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: TextButton(
                  onPressed: _pickImage,
                  child: const Text(
                    'Cambiar Imagen de Perfil',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Nombre de Usuario',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    prefixIcon: const Icon(Icons.person),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Cambiar Color de Fondo',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              TextButton(
                onPressed: _changeBackgroundColor,
                child: const Text(
                  'Seleccionar Color',
                  style: TextStyle(color: Colors.white),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                title: const Text('Cambiar Contraseña', style: TextStyle(color: Colors.white)),
                trailing: const Icon(Icons.arrow_forward, color: Colors.white),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ForgotPasswordPage()),
                  );
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveSettings,
                child: const Text('Guardar Configuraciones'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  backgroundColor: Colors.green.shade700,
                  shadowColor: Colors.green.shade900,
                  elevation: 10,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _deleteAccount,
                child: const Text('Eliminar Cuenta'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  backgroundColor: Colors.redAccent,
                  shadowColor: Colors.red,
                  elevation: 10,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/login');
                },
                child: const Text('Cerrar Sesión'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  backgroundColor: Colors.redAccent,
                  shadowColor: Colors.red,
                  elevation: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 100,
      maxWidth: 800,
      maxHeight: 800,
    );
    if (image != null) {
      await _uploadImageToFirebase(image);
    } else {
      print('No se seleccionó ninguna imagen.');
    }
  }

  Future<void> _uploadImageToFirebase(XFile image) async {
    String filePath = 'profile_images/$userId.png';
    File file = File(image.path);
    try {
      await storage.ref(filePath).putFile(file);
      String downloadURL = await storage.ref(filePath).getDownloadURL();
      setState(() {
        _imagePath = downloadURL;
      });
    } catch (e) {
      print('Error al subir la imagen: $e');
    }
  }

  void _changeBackgroundColor() {
    setState(() {
      _backgroundColor = Color((Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0);
    });
  }

  Future<void> _saveSettings() async {
    if (userId == null) return;
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'backgroundColor': _backgroundColor.value,
        'profileImage': _imagePath,
        'name': _nameController.text.trim(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Configuraciones guardadas')),
      );
    } catch (e) {
      print('Error al guardar configuraciones: $e');
    }
  }

  Future<void> _deleteAccount() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      await user?.delete();
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      print('Error al eliminar la cuenta: $e');
    }
  }
}

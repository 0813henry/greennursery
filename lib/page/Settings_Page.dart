import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:greennursery/page/history_Page.dart';
import 'package:greennursery/widgets/bottom_nav.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
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

  @override
  void initState() {
    super.initState();
    _requestPermissions();
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
      setState(() {
        userName = userDoc['name'] ?? 'Usuario';
        _imagePath = userDoc['profileImage'];
        int colorValue = userDoc['backgroundColor'] ?? Colors.green.shade100.value;
        _backgroundColor = Color(colorValue);
      });
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
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [_backgroundColor, Colors.green.shade300],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
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
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: Text(
                  userName ?? 'Usuario',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Cambiar Color de Fondo',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                title: const Text('Cambiar Contraseña'),
                trailing: const Icon(Icons.arrow_forward),
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
                  backgroundColor: Colors.green.shade700,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _deleteAccount,
                child: const Text('Eliminar Cuenta'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/login');
                },
                child: const Text('Cerrar Sesión'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _requestPermissions() async {
    final status = await Permission.storage.request();
    if (!status.isGranted) {
      print("Permiso denegado");
    }
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

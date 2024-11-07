import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart'; // Asegúrate de importar FirebaseAuth
import 'forgot_password.dart'; // Asegúrate de importar tu página de recuperación de contraseña

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String? _imagePath;
  final FirebaseStorage storage = FirebaseStorage.instance;
  Color _backgroundColor = Colors.green.shade100;
  List<Map<String, dynamic>> _purchases = [];
  late String userId; // Usar una variable de instancia para el ID del usuario

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    _getCurrentUserId(); // Obtiene el ID del usuario actual
    _loadUserSettings();
    _loadPurchases();
  }

  // Obtener el ID del usuario actual
  Future<void> _getCurrentUserId() async {
    try {
      // Verificar si el usuario está autenticado
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        setState(() {
          userId = user.uid; // Usar el ID del usuario autenticado
        });
      } else {
        print("Usuario no autenticado");
      }
    } catch (e) {
      print("Error al obtener el ID del usuario: $e");
    }
  }

  // Cargar configuraciones del usuario
  Future<void> _loadUserSettings() async {
    if (userId.isEmpty) return; // Asegurarse de que el userId no esté vacío
    // Cargar la imagen de perfil desde Firebase si existe
    String filePath = 'profile_images/$userId.png'; // Cambiado para usar el ID del usuario
    try {
      String downloadURL = await storage.ref(filePath).getDownloadURL();
      setState(() {
        _imagePath = downloadURL;
      });
    } catch (e) {
      print("Error al cargar la imagen de perfil: $e");
    }
  }

  // Cargar historial de compras
  Future<void> _loadPurchases() async {
    if (userId.isEmpty) return; // Asegurarse de que el userId no esté vacío
    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('purchases')
          .orderBy('purchaseDate', descending: true)
          .get();

      setState(() {
        _purchases = snapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
      });
    } catch (e) {
      print('Error al cargar el historial de compras: $e');
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
                        : const AssetImage('assets/') as ImageProvider,
                  ),
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
              Text(
                'Historial de Compras',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              _purchases.isNotEmpty
                  ? ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: _purchases.length,
                      itemBuilder: (context, index) {
                        final purchase = _purchases[index];
                        final DateTime purchaseDate = (purchase['purchaseDate'] as Timestamp).toDate();
                        return ListTile(
                          title: Text(purchase['productName'] ?? 'Producto sin nombre'),
                          subtitle: Text('Cantidad: ${purchase['quantity']} - Fecha: ${purchaseDate.toLocal()}'),
                          trailing: Text('\$${purchase['totalPrice'] ?? 0}'),
                        );
                      },
                    )
                  : const Text('No hay compras registradas.'),
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

  // Solicitar permisos para acceder a almacenamiento
  Future<void> _requestPermissions() async {
    final status = await Permission.storage.request();
    if (!status.isGranted) {
      print("Permiso denegado");
    }
  }

  // Seleccionar imagen desde la galería
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

  // Subir la imagen seleccionada a Firebase Storage
  Future<void> _uploadImageToFirebase(XFile image) async {
    String filePath = 'profile_images/$userId.png'; // Usar ID de usuario para la imagen
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

  // Cambiar el color de fondo aleatoriamente
  void _changeBackgroundColor() {
    final Random random = Random();
    setState(() {
      _backgroundColor = Color.fromARGB(
        255,
        random.nextInt(256),
        random.nextInt(256),
        random.nextInt(256),
      );
    });
  }

  // Eliminar la cuenta del usuario
  Future<void> _deleteAccount() async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).delete();
      print('Cuenta eliminada');
      Navigator.pushNamed(context, '/login');
    } catch (e) {
      print('Error al eliminar la cuenta: $e');
    }
  }

  // Guardar configuraciones del usuario
  Future<void> _saveSettings() async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'backgroundColor': _backgroundColor.value,
        'profileImage': _imagePath,
      }, SetOptions(merge: true));
      print('Configuraciones guardadas');
    } catch (e) {
      print('Error al guardar configuraciones: $e');
    }
  }
}

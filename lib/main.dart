import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:greennursery/page/home_page.dart';
import 'package:greennursery/page/login_page.dart';
import 'package:greennursery/page/create_account.dart';
import 'package:greennursery/page/forgot_password.dart';
import 'package:greennursery/data/cart_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
<<<<<<< HEAD
  await Firebase.initializeApp();

  // Inicializa los controladores
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    Get.put(CartController(user.uid));
  }
  Get.put(());
=======

  try {
    if (kIsWeb) {
      // Inicializa Firebase para Web con opciones específicas
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: "AIzaSyDkFmMl0ezx1M1fBsG3dR-4-7RPdqmQ7ew",
          authDomain: "greennursery-7eccd.firebaseapp.com",
          projectId: "greennursery-7eccd",
          storageBucket: "greennursery-7eccd.appspot.com",
          messagingSenderId: "362082290742",
          appId: "1:362082290742:web:c4a0fa82fb50b73e7d9c97",
        ),
      );
    } else {
      // Inicializa Firebase para Android/iOS
      await Firebase.initializeApp();
    }
  } catch (e) {
    print('Error al inicializar Firebase: $e');
  }
>>>>>>> 3c9bff7ee9d25b19aa3f7cab6ccdd00b70783cef

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    return GetMaterialApp(
      title: 'Greennursery',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const LoginPage(),
      routes: {
        '/create-account': (context) => const CreateAccountPage(),
        '/forgot-password': (context) => const ForgotPasswordPage(),
        '/home': (context) => HomePage(cartController: Get.find<CartController>()), // Pasa el controlador
        '/login': (context) => LoginPage()
=======
    return FutureBuilder(
      future: Firebase.initializeApp(), // Inicializa Firebase
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const MaterialApp(
            home: Scaffold(
              body: Center(
                child: Text(
                  'Error al inicializar Firebase.',
                  style: TextStyle(fontSize: 18, color: Colors.red),
                ),
              ),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            home: Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }

        return MaterialApp(
          title: 'Green Nursery',
          theme: ThemeData(
            primarySwatch: Colors.green,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          initialRoute: '/', // Ruta inicial
          routes: {
            '/': (context) => const LoginPage(), // Página de inicio de sesión
            '/home': (context) => const HomePage(), // Página principal tras el login
            '/create-account': (context) => const CreateAccountPage(), // Crear cuenta
            '/forgot-password': (context) => const ForgotPasswordPage(), // Recuperar contraseña
          },
          debugShowCheckedModeBanner: false,
        );
>>>>>>> 3c9bff7ee9d25b19aa3f7cab6ccdd00b70783cef
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:greennursery/page/home_page.dart';
import 'package:greennursery/page/login_page.dart';
import 'package:greennursery/page/create_account.dart';
import 'package:greennursery/page/forgot_password.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Inicializa Firebase
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Green Nursery',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const LoginPage(), // Página de inicio
      routes: {
        '/create-account': (context) => const CreateAccountPage(), // Ruta para crear cuenta
        '/forgot-password': (context) => const ForgotPasswordPage(), // Ruta para recuperar contraseña
      },
    );
  }
}

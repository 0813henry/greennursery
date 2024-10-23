import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:greennursery/core/color.dart';
import 'package:greennursery/widgets/bottom_nav.dart';
import 'package:greennursery/page/create_account.dart'; // Asegúrate de tener este archivo creado
import 'package:greennursery/page/forgot_password.dart'; // Asegúrate de tener este archivo creado

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _login() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Si el inicio de sesión es exitoso, navega a BottomNavBar
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const BottomNavBar()),
      );
    } catch (e) {
      // Manejar el error de inicio de sesión (ejemplo: mostrar un mensaje)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView( // Envuelve el contenido en un SingleChildScrollView
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start, // Cambia a start para dejar más espacio
          children: [
            const SizedBox(height: 25),
            const Text(
              'Planta con nosotros',
              style: TextStyle(
                fontSize: 22.0,
                letterSpacing: 1.8,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'Lleva la naturaleza a casa',
              style: TextStyle(
                color: grey,
                fontSize: 16,
                letterSpacing: 1.8,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(
              height: 450,
              width: 450,
              child: Image.asset('assets/images/logo.png'),
            ),
            const SizedBox(height: 25),

            // Campo de texto para el correo electrónico
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Correo Electrónico',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),

            // Campo de texto para la contraseña
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Contraseña',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),

            // Botón de inicio de sesión
            GestureDetector(
              onTap: _login,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 80.0,
                  vertical: 12.0,
                ),
                decoration: BoxDecoration(
                  color: green,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: const Text(
                  'Iniciar Sesión',
                  style: TextStyle(
                    color: white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Botón para crear una cuenta
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateAccountPage(),
                  ),
                );
              },
              child: Text(
                'Crear una cuenta',
                style: TextStyle(
                  color: black.withOpacity(0.7),
                  fontSize: 16,
                  letterSpacing: 1,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            // Botón para olvidar la contraseña
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ForgotPasswordPage(),
                  ),
                );
              },
              child: Text(
                '¿Olvidaste tu contraseña?',
                style: TextStyle(
                  color: black.withOpacity(0.4),
                  letterSpacing: 1,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 25), // Espacio adicional al final
          ],
        ),
      ),
    );
  }
}

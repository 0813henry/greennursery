import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:greennursery/core/color.dart';
import 'package:greennursery/widgets/bottom_nav.dart';
import 'package:greennursery/page/create_account.dart';
import 'package:greennursery/page/forgot_password.dart';
import 'addProduct_Page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoading = false; // Estado de carga
  final List<String> _adminEmails = [
    'admin@gmail.com', // Correos que deben tener acceso administrativo
  ];

  /// Función para manejar el inicio de sesión.
  Future<void> _login() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor ingresa correo y contraseña')),
      );
      return;
    }

    setState(() {
      _isLoading = true; // Muestra el estado de carga
    });

    try {
      // Intento de inicio de sesión con Firebase
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Si el inicio de sesión es exitoso, verifica si el usuario tiene acceso
      if (userCredential.user != null) {
        // Verifica si el correo del usuario está en la lista de administradores
        if (_adminEmails.contains(email)) {
          // Navegar a la página para agregar productos
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => AddProductPage(), // Asegúrate de crear esta página
            ),
          );
        } else {
          // Si no es administrador, redirige a BottomNavBar
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => BottomNavBar(), // Asegúrate de pasar los datos del carrito
            ),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      // Manejo específico de errores de Firebase
      String errorMessage;
      switch (e.code) {
        case 'invalid-email':
          errorMessage = 'Correo electrónico no válido.';
          break;
        case 'user-not-found':
          errorMessage = 'No se encontró el usuario.';
          break;
        case 'wrong-password':
          errorMessage = 'Contraseña incorrecta.';
          break;
        default:
          errorMessage = 'Error: ${e.message}';
      }
      // Mostrar mensaje de error con SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } catch (e) {
      // Captura de errores inesperados
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error inesperado: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false; // Oculta el estado de carga
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
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
              height: 350,
              width: 350,
              child: Image.asset('assets/images/logo.png'),
            ),
            const SizedBox(height: 25),

            // Campo de texto para correo
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Correo Electrónico',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),

            // Campo de texto para contraseña
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Contraseña',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),

            // Botón de inicio de sesión con indicador de carga
            _isLoading
                ? const CircularProgressIndicator()
                : GestureDetector(
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

            // Botón para recuperar la contraseña
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
            const SizedBox(height: 25), // Espacio al final
          ],
        ),
      ),
    );
  }
}

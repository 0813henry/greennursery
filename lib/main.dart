import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:greennursery/page/home_page.dart';
import 'package:greennursery/page/login_page.dart';
import 'package:greennursery/page/create_account.dart';
import 'package:greennursery/page/forgot_password.dart';
import 'package:greennursery/data/cart_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Inicializa los controladores
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    Get.put(CartController(user.uid));
  }
  Get.put(());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:greennursery/core/color.dart';
import 'package:greennursery/data/bottom_menu.dart';
import 'package:greennursery/page/home_page.dart';
import 'package:greennursery/page/cart_page.dart';
import 'package:greennursery/page/guidelines_page.dart'; // Nueva página
import 'package:greennursery/page/settings_page.dart'; // Nueva página
import 'package:greennursery/data/cart_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';

final userId = FirebaseAuth.instance.currentUser!.uid;
final cartController = CartController(userId);

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({Key? key}) : super(key: key); // No es necesario el parámetro `cart`

  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  PageController pageController = PageController();
  int selectIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: pageController,
        onPageChanged: (value) => setState(() => selectIndex = value),
        children: [
          HomePage(cartController: cartController), // Pasamos cartController aquí
          const GuidelinesPage(),
          CartPage(cartController: cartController),
          const SettingsPage(),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        elevation: 0,
        child: SizedBox(
          height: 60.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              for (int i = 0; bottomMenu.length > i; i++)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      pageController.jumpToPage(i);
                      selectIndex = i;
                    });
                  },
                  child: Image.asset(
                    bottomMenu[i].imagePath,
                    color: selectIndex == i ? green : grey.withOpacity(0.5),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}

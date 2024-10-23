import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:greennursery/core/color.dart';
import 'package:greennursery/data/category_model.dart';
import 'package:greennursery/data/plant_data.dart';
import 'package:greennursery/page/details_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Controlador de página y estados
  late PageController controller;
  int selectId = 0; // ID de la categoría seleccionada
  int activePage = 0; // Página activa en el slider

  @override
  void initState() {
    // Inicialización del controlador
    controller = PageController(viewportFraction: 0.6, initialPage: 0);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      appBar: buildAppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildSearchBar(), // Barra de búsqueda
            buildCategorySelector(), // Selector de categorías
            buildPlantSlider(), // Slider de plantas
            buildPopularPlantsHeader(), // Encabezado para plantas populares
            buildPopularPlantsList(), // Lista de plantas populares
          ],
        ),
      ),
    );
  }

  // Fase 1: Crear la barra de navegación
  AppBar buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: white,
      automaticallyImplyLeading: false,
      leadingWidth: 40,
      leading: TextButton(
        onPressed: () {},
        child: Image.asset('assets/icons/menu.png'),
      ),
      actions: [
        Container(
          height: 40.0,
          width: 40.0,
          margin: const EdgeInsets.only(right: 20, top: 10, bottom: 5),
          decoration: BoxDecoration(
            color: green,
            boxShadow: [
              BoxShadow(
                color: green.withOpacity(0.5),
                blurRadius: 10,
                offset: const Offset(0, 0),
              ),
            ],
            borderRadius: BorderRadius.circular(20.0),
            image: const DecorationImage(
              image: AssetImage('assets/images/pro.png'),
            ),
          ),
        ),
      ],
    );
  }

  // Fase 2: Implementar la barra de búsqueda
  Padding buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
      child: Row(
        children: [
          Container(
            height: 45.0,
            width: 300.0,
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            decoration: BoxDecoration(
              color: white,
              border: Border.all(color: green),
              boxShadow: [
                BoxShadow(
                  color: green.withOpacity(0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 0),
                ),
              ],
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Row(
              children: [
                const SizedBox(
                  height: 45,
                  width: 250,
                  child: TextField(
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Search',
                    ),
                  ),
                ),
                Image.asset(
                  'assets/icons/search.png',
                  height: 25,
                )
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            height: 45.0,
            width: 45.0,
            decoration: BoxDecoration(
              color: green,
              boxShadow: [
                BoxShadow(
                  color: green.withOpacity(0.5),
                  blurRadius: 10,
                  offset: const Offset(0, 0),
                ),
              ],
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Image.asset(
              'assets/icons/adjust.png',
              color: white,
              height: 25,
            ),
          ),
        ],
      ),
    );
  }

  // Fase 3: Crear la sección de categorías
  SizedBox buildCategorySelector() {
    return SizedBox(
      height: 35.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          for (int i = 0; i < categories.length; i++)
            GestureDetector(
              onTap: () {
                setState(() => selectId = categories[i].id);
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    categories[i].name,
                    style: TextStyle(
                      color: selectId == i ? green : black.withOpacity(0.7),
                      fontSize: 16.0,
                    ),
                  ),
                  if (selectId == i)
                    const CircleAvatar(
                      radius: 3,
                      backgroundColor: green,
                    )
                ],
              ),
            ),
        ],
      ),
    );
  }

  // Fase 4: Crear el slider de plantas
  SizedBox buildPlantSlider() {
    return SizedBox(
      height: 320.0,
      child: PageView.builder(
        itemCount: plants.length,
        controller: controller,
        physics: const BouncingScrollPhysics(),
        padEnds: false,
        pageSnapping: true,
        onPageChanged: (value) => setState(() => activePage = value),
        itemBuilder: (itemBuilder, index) {
          bool active = index == activePage;
          return slider(active, index);
        },
      ),
    );
  }

  // Animación del slider
  AnimatedContainer slider(bool active, int index) {
    double margin = active ? 20 : 30;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutCubic,
      margin: EdgeInsets.all(margin),
      child: mainPlantsCard(index),
    );
  }

  // Tarjeta principal de plantas
  Widget mainPlantsCard(int index) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (builder) => DetailsPage(plant: plants[index]),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: white,
          boxShadow: [
            BoxShadow(
              color: black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(5, 5),
            ),
          ],
          border: Border.all(color: green, width: 2),
          borderRadius: BorderRadius.circular(30.0),
        ),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: lightGreen,
                boxShadow: [
                  BoxShadow(
                    color: black.withOpacity(0.05),
                    blurRadius: 15,
                    offset: const Offset(5, 5),
                  ),
                ],
                borderRadius: BorderRadius.circular(25.0),
                image: DecorationImage(
                  image: AssetImage(plants[index].imagePath),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              right: 8,
              top: 8,
              child: CircleAvatar(
                backgroundColor: green,
                radius: 15,
                child: Image.asset(
                  'assets/icons/add.png',
                  color: white,
                  height: 15,
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Text(
                  '${plants[index].name} - \$${plants[index].price.toStringAsFixed(0)}',
                  style: TextStyle(
                    color: black.withOpacity(0.7),
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  // Fase 5: Encabezado para plantas populares
  Padding buildPopularPlantsHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Plantas Populares',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextButton(
            onPressed: () {},
            child: const Text(
              'Ver todo',
              style: TextStyle(
                color: green,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Lista de plantas populares
  SizedBox buildPopularPlantsList() {
    return SizedBox(
      height: 200.0,
      child: ListView.builder(
        padding: const EdgeInsets.only(left: 20.0),
        scrollDirection: Axis.horizontal,
        itemCount: plants.length,
        itemBuilder: (context, index) {
          return popularPlantCard(index);
        },
      ),
    );
  }

  // Tarjeta de planta popular
  Widget popularPlantCard(int index) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (builder) => DetailsPage(plant: plants[index]),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(right: 10.0),
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: white,
          borderRadius: BorderRadius.circular(15.0),
          boxShadow: [
            BoxShadow(
              color: black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(5, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15.0),
              child: Image.asset(
                plants[index].imagePath,
                height: 120.0,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 10.0),
            Text(
              plants[index].name,
              style: const TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5.0),
            Text(
              '\$${plants[index].price.toStringAsFixed(0)}',
              style: const TextStyle(
                fontSize: 14.0,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose(); // Liberar recursos
    super.dispose();
  }
}

<<<<<<< HEAD
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:greennursery/data/cart_controller.dart';
import 'package:greennursery/data/plant_model.dart';
=======
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:greennursery/core/color.dart';
import 'package:greennursery/data/category_model.dart';
import 'package:greennursery/data/plant_data.dart';
import 'package:greennursery/data/cart_model.dart';
import 'package:greennursery/page/cart_page.dart';
>>>>>>> 3c9bff7ee9d25b19aa3f7cab6ccdd00b70783cef
import 'package:greennursery/page/details_page.dart';
import 'package:greennursery/core/color.dart';

class HomePage extends StatefulWidget {
  final CartController cartController;

  const HomePage({Key? key, required this.cartController}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
<<<<<<< HEAD
  PageController controller = PageController(viewportFraction: 0.6);
  int activePage = 0;
  String searchText = '';
  String? selectedCategory;
  List<String> categories = [
    'Todas',
    'Exterior',
    'Interior',
    'Cactus',
    'Oficina',
    'Bonsai',
    'Bromelias',
    'Buena Suerte',
    'Carnivoras',
    'Florales',
    'Hojas',
    'Huerta',
    'Jardin & Balcon',
    'Orquideas',
    'Purificadoas de Aire',
    'Rastreras & Enredaderas'
  ];
  Future<List<Plants>>? plantsFuture;

  @override
  void initState() {
=======
  late PageController controller;
  int selectId = 0;
  int activePage = 0;

  final ShoppingCart cart = ShoppingCart(); // Instancia del carrito

  @override
  void initState() {
    controller = PageController(viewportFraction: 0.6, initialPage: 0);
>>>>>>> 3c9bff7ee9d25b19aa3f7cab6ccdd00b70783cef
    super.initState();
    // Inicializar la carga de plantas una vez
    plantsFuture = _fetchPlants();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
<<<<<<< HEAD
      appBar: AppBar(
        elevation: 0,
        backgroundColor: white,
        automaticallyImplyLeading: false,
        title: Text(
          'GreenNursery',
          style: TextStyle(color: black),
=======
      appBar: buildAppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildSearchBar(),
            buildCategorySelector(),
            buildPlantSlider(),
            buildPopularPlantsHeader(),
            buildPopularPlantsList(),
          ],
>>>>>>> 3c9bff7ee9d25b19aa3f7cab6ccdd00b70783cef
        ),
      ),
      body: FutureBuilder<List<Plants>>(
        future: plantsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay plantas disponibles.'));
          } else {
            List<Plants> plantsList = snapshot.data!
                .where((plant) =>
                    (selectedCategory == null ||
                        selectedCategory == 'Todas' ||
                        plant.category == selectedCategory) &&
                    (plant.name.toLowerCase().contains(searchText.toLowerCase())))
                .toList();

<<<<<<< HEAD
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Barra de búsqueda
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
                    child: Column(
                      children: [
                        TextField(
                          onChanged: (value) => setState(() => searchText = value),
                          decoration: InputDecoration(
                            hintText: 'Buscar por nombre',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            suffixIcon: Icon(Icons.search),
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Dropdown para seleccionar categoría
                        DropdownButton<String>(
                          value: selectedCategory,
                          hint: Text('Seleccionar Categoría'),
                          isExpanded: true,
                          items: categories.map((category) {
                            return DropdownMenuItem(
                              value: category,
                              child: Text(category),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedCategory = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),

                  // Carrusel de plantas
                  SizedBox(
                    height: 320.0,
                    child: PageView.builder(
                      itemCount: plantsList.length,
                      controller: controller,
                      physics: const BouncingScrollPhysics(),
                      onPageChanged: (value) => setState(() => activePage = value),
                      itemBuilder: (context, index) {
                        bool active = index == activePage;
                        return slider(active, plantsList[index]);
                      },
                    ),
                  ),

                  // Título de "Populares"
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Text(
                      'Populares',
                      style: TextStyle(color: black.withOpacity(0.7), fontWeight: FontWeight.bold, fontSize: 18.0),
                    ),
                  ),

                  // Lista de plantas populares
                  SizedBox(
                    height: 130.0,
                    child: ListView.builder(
                      itemCount: plantsList.length,
                      padding: const EdgeInsets.only(left: 20.0),
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        return _popularPlantCard(plantsList[index]);
                      },
                    ),
                  ),
                ],
              ),
            );
          }
=======
  AppBar buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: white,
      automaticallyImplyLeading: false,
      leading: TextButton(
        onPressed: () {},
        child: Image.asset('assets/icons/menu.png'),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.shopping_cart, color: green),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CartPage(cart: cart),
              ),
            );
          },
        ),
        Container(
          height: 40.0,
          width: 40.0,
          margin: const EdgeInsets.only(right: 20, top: 10, bottom: 5),
          decoration: BoxDecoration(
            color: green,
            shape: BoxShape.circle,
            image: const DecorationImage(
              image: AssetImage('assets/images/pro.png'),
            ),
          ),
        ),
      ],
    );
  }

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
                ),
              ],
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Row(
              children: [
                const SizedBox(
                  width: 250,
                  child: TextField(
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Search',
                    ),
                  ),
                ),
                Image.asset('assets/icons/search.png', height: 25),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            height: 45.0,
            width: 45.0,
            decoration: BoxDecoration(
              color: green,
              borderRadius: BorderRadius.circular(10.0),
              boxShadow: [
                BoxShadow(
                  color: green.withOpacity(0.5),
                  blurRadius: 10,
                ),
              ],
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

  SizedBox buildCategorySelector() {
    return SizedBox(
      height: 35.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: categories.map((category) {
          return GestureDetector(
            onTap: () => setState(() => selectId = category.id),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  category.name,
                  style: TextStyle(
                    color: selectId == category.id ? green : black.withOpacity(0.7),
                    fontSize: 16.0,
                  ),
                ),
                if (selectId == category.id)
                  const CircleAvatar(
                    radius: 3,
                    backgroundColor: green,
                  )
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  SizedBox buildPlantSlider() {
    return SizedBox(
      height: 320.0,
      child: PageView.builder(
        itemCount: plants.length,
        controller: controller,
        onPageChanged: (value) => setState(() => activePage = value),
        itemBuilder: (context, index) {
          bool active = index == activePage;
          return slider(active, index);
>>>>>>> 3c9bff7ee9d25b19aa3f7cab6ccdd00b70783cef
        },
      ),
    );
  }

<<<<<<< HEAD
  Future<List<Plants>> _fetchPlants() async {
    final snapshot = await FirebaseFirestore.instance.collection('plants').get();
    return snapshot.docs.map((doc) => Plants.fromDocument(doc)).toList();
  }

  Widget slider(bool active, Plants plant) {
=======
  AnimatedContainer slider(bool active, int index) {
>>>>>>> 3c9bff7ee9d25b19aa3f7cab6ccdd00b70783cef
    double margin = active ? 20 : 30;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      margin: EdgeInsets.all(margin),
      child: mainPlantsCard(plant),
    );
  }

<<<<<<< HEAD
  Widget mainPlantsCard(Plants plant) {
=======
  Widget mainPlantsCard(int index) {
>>>>>>> 3c9bff7ee9d25b19aa3f7cab6ccdd00b70783cef
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
<<<<<<< HEAD
          MaterialPageRoute(builder: (context) => DetailsPage(plant: plant, cart: widget.cartController)),
=======
          MaterialPageRoute(
            builder: (context) => DetailsPage(plant: plants[index], cart: cart),
          ),
>>>>>>> 3c9bff7ee9d25b19aa3f7cab6ccdd00b70783cef
        );
      },
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: white,
<<<<<<< HEAD
          borderRadius: BorderRadius.circular(30.0),
          boxShadow: [
            BoxShadow(color: black.withOpacity(0.05), blurRadius: 15, offset: const Offset(5, 5)),
=======
          border: Border.all(color: green, width: 2),
          borderRadius: BorderRadius.circular(30.0),
          boxShadow: [
            BoxShadow(
              color: black.withOpacity(0.05),
              blurRadius: 15,
            ),
>>>>>>> 3c9bff7ee9d25b19aa3f7cab6ccdd00b70783cef
          ],
        ),
        child: Stack(
          children: [
<<<<<<< HEAD
            ClipRRect(
              borderRadius: BorderRadius.circular(25.0),
              child: Image.network(plant.imagePath, fit: BoxFit.cover),
=======
            Container(
              decoration: BoxDecoration(
                color: lightGreen,
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
                child: Icon(Icons.add, color: white, size: 15),
              ),
>>>>>>> 3c9bff7ee9d25b19aa3f7cab6ccdd00b70783cef
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Text(
                  '${plant.name} - \$${plant.price.toStringAsFixed(2)}',
                  style: TextStyle(color: black.withOpacity(0.7), fontWeight: FontWeight.bold, fontSize: 16.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

<<<<<<< HEAD
  Widget _popularPlantCard(Plants plant) {
=======
  Padding buildPopularPlantsHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Plantas Populares',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          TextButton(
            onPressed: () {},
            child: const Text('Ver todo', style: TextStyle(color: green, fontSize: 16)),
          ),
        ],
      ),
    );
  }

  SizedBox buildPopularPlantsList() {
    return SizedBox(
      height: 200.0,
      child: ListView.builder(
        padding: const EdgeInsets.only(left: 20.0),
        scrollDirection: Axis.horizontal,
        itemCount: plants.length,
        itemBuilder: (context, index) => popularPlantCard(index),
      ),
    );
  }

  Widget popularPlantCard(int index) {
>>>>>>> 3c9bff7ee9d25b19aa3f7cab6ccdd00b70783cef
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
<<<<<<< HEAD
          MaterialPageRoute(builder: (context) => DetailsPage(plant: plant, cart: widget.cartController)),
=======
          MaterialPageRoute(
            builder: (context) => DetailsPage(plant: plants[index], cart: cart),
          ),
>>>>>>> 3c9bff7ee9d25b19aa3f7cab6ccdd00b70783cef
        );
      },
      child: Container(
        width: 200.0,
        margin: const EdgeInsets.only(right: 20, bottom: 10),
        decoration: BoxDecoration(
          color: lightGreen,
          borderRadius: BorderRadius.circular(20.0),
          boxShadow: [
<<<<<<< HEAD
            BoxShadow(color: green.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5)),
=======
            BoxShadow(
              color: black.withOpacity(0.05),
              blurRadius: 15,
            ),
>>>>>>> 3c9bff7ee9d25b19aa3f7cab6ccdd00b70783cef
          ],
        ),
        child: Row(
          children: [
<<<<<<< HEAD
            Image.network(plant.imagePath, width: 70, height: 70),
            const SizedBox(width: 10.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  plant.name,
                  style: TextStyle(color: black.withOpacity(0.7), fontWeight: FontWeight.w800),
                ),
                Text(
                  '\$${plant.price.toStringAsFixed(2)}',
                  style: TextStyle(color: black.withOpacity(0.4), fontWeight: FontWeight.w600, fontSize: 12.0),
                ),
              ],
=======
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
              style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5.0),
            Text(
              '\$${plants[index].price.toStringAsFixed(0)}',
              style: const TextStyle(fontSize: 14.0, color: Colors.grey),
>>>>>>> 3c9bff7ee9d25b19aa3f7cab6ccdd00b70783cef
            ),
          ],
        ),
      ),
    );
  }
<<<<<<< HEAD
=======

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
>>>>>>> 3c9bff7ee9d25b19aa3f7cab6ccdd00b70783cef
}

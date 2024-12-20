import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:greennursery/data/cart_controller.dart';
import 'package:greennursery/data/plant_model.dart';
import 'package:greennursery/page/details_page.dart';
import 'package:greennursery/page/notifications_page.dart';
import 'package:greennursery/core/color.dart';

class HomePage extends StatefulWidget {
  final CartController cartController;

  const HomePage({Key? key, required this.cartController}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
  int notificationCount = 0;

  @override
  void initState() {
    super.initState();
    // Inicializar la carga de plantas una vez
    plantsFuture = _fetchPlants();
  }

  void _incrementNotificationCount() {
    setState(() {
      notificationCount++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        title: Text(
          'GreenNursery',
          style: TextStyle(color: black, fontWeight: FontWeight.bold, fontSize: 24),
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.notifications, color: black),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => NotificationsPage()),
                  );
                },
              ),
              if (notificationCount > 0)
                Positioned(
                  right: 11,
                  top: 11,
                  child: Container(
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    constraints: BoxConstraints(
                      minWidth: 14,
                      minHeight: 14,
                    ),
                    child: Text(
                      '$notificationCount',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.shade300, Colors.green.shade700],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: FutureBuilder<List<Plants>>(
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
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              suffixIcon: Icon(Icons.search, color: Colors.green.shade700),
                            ),
                          ),
                          const SizedBox(height: 10),
                          // Dropdown para seleccionar categoría
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 15.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: DropdownButton<String>(
                              value: selectedCategory,
                              hint: Text('Seleccionar Categoría'),
                              isExpanded: true,
                              underline: SizedBox(),
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
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18.0),
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
          },
        ),
      ),
    );
  }

  Future<List<Plants>> _fetchPlants() async {
    final snapshot = await FirebaseFirestore.instance.collection('plants').get();
    return snapshot.docs.map((doc) => Plants.fromDocument(doc)).toList();
  }

  Widget slider(bool active, Plants plant) {
    double margin = active ? 20 : 30;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      margin: EdgeInsets.all(margin),
      child: mainPlantsCard(plant),
    );
  }

  Widget mainPlantsCard(Plants plant) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DetailsPage(plant: plant, cart: widget.cartController)),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30.0),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 15, offset: const Offset(5, 5)),
          ],
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(25.0),
              child: Image.network(plant.imagePath, fit: BoxFit.cover),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Text(
                  '${plant.name} - \$${plant.price.toStringAsFixed(2)}',
                  style: TextStyle(color: Colors.black.withOpacity(0.7), fontWeight: FontWeight.bold, fontSize: 16.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _popularPlantCard(Plants plant) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DetailsPage(plant: plant, cart: widget.cartController)),
        );
      },
      child: Container(
        width: 200.0,
        margin: const EdgeInsets.only(right: 20, bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.0),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5)),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20.0),
              child: Image.network(plant.imagePath, width: 70, height: 70, fit: BoxFit.cover),
            ),
            const SizedBox(width: 10.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  plant.name,
                  style: TextStyle(color: Colors.black.withOpacity(0.7), fontWeight: FontWeight.w800),
                ),
                Text(
                  '\$${plant.price.toStringAsFixed(2)}',
                  style: TextStyle(color: Colors.black.withOpacity(0.4), fontWeight: FontWeight.w600, fontSize: 12.0),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

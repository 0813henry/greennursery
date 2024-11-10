import 'package:greennursery/data/plant_model.dart';
/// Modelo para representar un ítem dentro del carrito.
class CartItem {
  final Plants plant; // Instancia del modelo de planta.
  int quantity; // Cantidad del ítem.
  CartItem({required this.plant, this.quantity = 1});
}
/// Clase para gestionar las operaciones del carrito de compras.
class ShoppingCart {
  final List<CartItem> items = []; // Lista de ítems en el carrito.
  /// Agrega una planta al carrito. Si ya existe, incrementa la cantidad.
  void addItem(Plants plant) {
    var existingItem = items.firstWhere(
      (item) => item.plant.id == plant.id,
      orElse: () => CartItem(plant: plant),
    );
    if (items.contains(existingItem)) {
      existingItem.quantity++;
    } else {
      items.add(existingItem);
    }
  }
  /// Elimina una planta del carrito.
  void removeItem(Plants plant) {
    items.removeWhere((item) => item.plant.id == plant.id);
  }
  /// Calcula el precio total del carrito.
  double getTotalPrice() {
    return items.fold(0, (total, item) => total + (item.plant.price * item.quantity));
  }
  /// Limpia todos los ítems del carrito.
  void clearCart() {
    items.clear();
  }
  /// Verifica si el carrito está vacío.
  bool isEmpty() {
    return items.isEmpty;
  }
}
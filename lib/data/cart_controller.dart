// lib/data/cart_controller.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'plant_model.dart';

class CartController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String userId;

  CartController(this.userId);

  // Stream para obtener los items del carrito
  Stream<QuerySnapshot> getCartItems() {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('cart')
        .snapshots();
  }

  // Función para añadir un producto al carrito
  Future<void> addItem(Plants plant, int quantity) async {
    final plantDoc = await _firestore.collection('plants').doc(plant.id).get();
    final stockAvailable = plantDoc.data()?['stock'] ?? 0;

    if (stockAvailable >= quantity) {
      final cartItemRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('cart')
          .doc(plant.id);

      await cartItemRef.set({
        'productId': plant.id,
        'name': plant.name,
        'price': plant.price,
        'quantity': FieldValue.increment(quantity),
      }, SetOptions(merge: true));
    } else {
      throw Exception('No hay suficiente stock para añadir esta cantidad al carrito.');
    }
  }

  // Función para eliminar un producto del carrito
  Future<void> removeFromCart(String productId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('cart')
        .doc(productId)
        .delete();
  }

  // Función para actualizar la cantidad de un producto en el carrito
  Future<void> updateQuantity(String productId, int quantity) async {
    final plantDoc = await _firestore.collection('plants').doc(productId).get();
    final stockAvailable = plantDoc.data()?['stock'] ?? 0;

    if (stockAvailable >= quantity) {
      final cartItemRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('cart')
          .doc(productId);

      await cartItemRef.update({
        'quantity': quantity,
      });
    } else {
      throw Exception('No hay suficiente stock para actualizar la cantidad.');
    }
  }

  // Función para obtener el total del carrito
  Future<double> getTotalAmount() async {
    final cartItems = await getCartItemsList();
    double total = 0;

    for (var item in cartItems) {
      final price = item['price'] ?? 0.0;
      final quantity = item['quantity'] ?? 0;
      total += price * quantity;
    }

    return total;
  }

  // Función para obtener los items del carrito como una lista
  Future<List<Map<String, dynamic>>> getCartItemsList() async {
    final cartItems = await _firestore
        .collection('users')
        .doc(userId)
        .collection('cart')
        .get();

    return cartItems.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }

  // Función para realizar el pago
  Future<void> makePayment() async {
    final cartItems = await getCartItemsList();

    for (var item in cartItems) {
      final productId = item['productId'];
      final quantity = item['quantity'];

      // Verificar el stock disponible antes de proceder al pago
      final plantDoc = await _firestore.collection('plants').doc(productId).get();
      final stockAvailable = plantDoc.data()?['stock'] ?? 0;

      if (stockAvailable < quantity) {
        throw Exception('No hay suficiente stock para el producto: ${item['name']}');
      }

      try {
        // Actualizar el stock de la planta
        await _firestore.collection('plants').doc(productId).update({
          'stock': FieldValue.increment(-quantity),
        });
      } catch (e) {
        throw Exception('Error al actualizar el stock: $e');
      }
    }

    // Guardar el historial de la compra
    await _savePurchaseHistory(cartItems);

    // Vaciar el carrito después de realizar el pago
    await clearCart();
  }

  // Función para vaciar el carrito
  Future<void> clearCart() async {
    final cartItems = await _firestore
        .collection('users')
        .doc(userId)
        .collection('cart')
        .get();

    for (var doc in cartItems.docs) {
      await doc.reference.delete();
    }
  }

  // Función para guardar el historial de la compra
  Future<void> _savePurchaseHistory(List<Map<String, dynamic>> cartItems) async {
    final purchaseRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('purchases')
        .doc();

    // Guardar los detalles de la compra, incluyendo los productos y la fecha
    await purchaseRef.set({
      'purchaseId': purchaseRef.id,
      'date': FieldValue.serverTimestamp(), // Fecha de la compra
      'items': cartItems,
      'totalAmount': await getTotalAmount(),
    });
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shop_smart/providers/products_provider.dart';
import 'package:shop_smart/services/my_app_functions.dart';
import 'package:uuid/uuid.dart';

import '../models/cart_model.dart';

class CartProvider with ChangeNotifier {
  final Map<String, CartModel> _cartItems = {};

  Map<String, CartModel> get getCartitems {
    return _cartItems;
  }

  final userDb = FirebaseFirestore.instance.collection("users");
  final _auth = FirebaseAuth.instance;

  // Firebase
  Future<void> addTOCartFirebase(
      {required String productId,
      required int qty,
      required BuildContext context}) async {
    final User? user = _auth.currentUser;
    if (user == null) {
      MyAppFunctions.showErrorOrWarningDialog(
        context: context,
        subtitle: 'Please Login First',
        fct: () {},
      );
      return;
    }
    final uid = user.uid;
    final cartId = const Uuid().v4();
    try {
      await userDb.doc(uid).update({
        'userCart': FieldValue.arrayUnion([
          {
            'cartId': cartId,
            'productId': productId,
            'quantity': qty,
          }
        ]),
      });
      await fetchCart();
      Fluttertoast.showToast(
        msg: 'Item Has Been Added',
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> fetchCart() async {
    final User? user = _auth.currentUser;
    if (user == null) {
      _cartItems.clear();
      return;
    }
    try {
      final userDoc = await userDb.doc(user.uid).get();
      final data = userDoc.data();
      if (data == null || !data.containsKey('userCart')) {
        return;
      }
      final leng = userDoc.get('userCart').length;
      for (int index = 0; index < leng; index++) {
        _cartItems.putIfAbsent(
            userDoc.get('userCart')[index]['productId'],
            () => CartModel(
                  cartId: userDoc.get('userCart')[index]['cartId'],
                  productId: userDoc.get('userCart')[index]['productId'],
                  quantity: userDoc.get('userCart')[index]['quantity'],
                ));
      }
    } catch (e) {
      rethrow;
    }
    notifyListeners();
  }

  Future<void> removeCartItemFromFireStore({
    required String cartId,
    required String productId,
    required int qty,
  }) async{
    final User? user = _auth.currentUser;
    try {
      await userDb.doc(user!.uid).update({
        'userCart': FieldValue.arrayRemove([
          {
            'cartId': cartId,
            'productId': productId,
            'quantity': qty,
          }
        ]),
      });
      //await fetchCart();
      _cartItems.remove(productId);
      Fluttertoast.showToast(
        msg: 'Item Has Been Removed',
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> clearCartFromFireStore() async{
    final User? user = _auth.currentUser;
    try {
      await userDb.doc(user!.uid).update({
        'userCart': [],
      });
      //await fetchCart();
      _cartItems.clear();
      // Fluttertoast.showToast(
      //   msg: 'Cart Has Been Cleared',
      // );
    } catch (e) {
      rethrow;
    }
  }

  // Local
  void addProductToCart({required String productId}) {
    _cartItems.putIfAbsent(
      productId,
      () => CartModel(
          cartId: const Uuid().v4(), productId: productId, quantity: 1),
    );
    notifyListeners();
  }

  void updateQty({required String productId, required int qty}) {
    _cartItems.update(
      productId,
      (cartItem) => CartModel(
        cartId: cartItem.cartId,
        productId: productId,
        quantity: qty,
      ),
    );
    notifyListeners();
  }

  bool isProdinCart({required String productId}) {
    return _cartItems.containsKey(productId);
  }

  double getTotal({required ProductsProvider productsProvider}) {
    double total = 0.0;

    _cartItems.forEach((key, value) {
      final getCurrProduct = productsProvider.findByProdId(value.productId);
      if (getCurrProduct == null) {
        total += 0;
      } else {
        total += double.parse(getCurrProduct.productPrice) * value.quantity;
      }
    });
    return total;
  }

  int getQty() {
    int total = 0;
    _cartItems.forEach((key, value) {
      total += value.quantity;
    });
    return total;
  }

  void clearLocalCart() {
    _cartItems.clear();
    notifyListeners();
  }

  void removeOneItem({required String productId}) {
    _cartItems.remove(productId);
    notifyListeners();
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../models/order_model.dart';

class OrderProvider with ChangeNotifier {
  final List<OrdersModelAdvanced> orders = [];
  List<OrdersModelAdvanced> get getOrders => orders;

  final orderDb =  FirebaseFirestore.instance.collection('ordersAdvanced');
  final auth = FirebaseAuth.instance;

  Future<List<OrdersModelAdvanced>> fetchOrders() async {
    User? user = auth.currentUser;
    var uid = user!.uid;
    try {
      await FirebaseFirestore.instance
          .collection('ordersAdvanced').where('userId',isEqualTo: uid).orderBy('orderDate',descending: false)
          .get()
          .then((orderSnapshot) {
        orders.clear();
        for (var element in orderSnapshot.docs) {
          orders.insert(
            0,
            OrdersModelAdvanced(
              orderId: element.get('orderId'),
              userId: element.get('userId'),
              productId: element.get('productId'),
              productTitle: element.get('productTitle').toString(),
              userName: element.get('userName'),
              price: element.get('price').toString(),
              imageUrl: element.get('imageUrl'),
              quantity: element.get('quantity').toString(),
              orderDate: element.get('orderDate'),
            ),
          );
        }
      });
      return orders;
    } catch (e) {
      rethrow;
    }
  }


  Future<void> removeOrderItemFromFireStore({
    required String orderId,

  }) async{
    // final User? user = auth.currentUser;
    try {
      await orderDb.doc(orderId).delete();
      notifyListeners();
      //orders.remove(orderId);
      Fluttertoast.showToast(
        msg: 'Item Has Been Removed',
      );
    } catch (e) {
      rethrow;
    }
    // notifyListeners();
  }

  // void removeOneItem({required String orderId}) {
  //   List<orders>.remove(orderId);
  //   notifyListeners();
  // }
}

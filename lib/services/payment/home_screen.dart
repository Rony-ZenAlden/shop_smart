import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_paypal_payment/flutter_paypal_payment.dart';
import 'package:shop_smart/services/payment/model/items_model.dart';
import 'package:shop_smart/services/payment/model/transaction_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "PayPal Payment",
          style: TextStyle(fontSize: 20),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.greenAccent,
              ),
              onPressed: () async {
                var transactionData = getTransaction();
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (BuildContext context) => PaypalCheckoutView(
                    sandboxMode: true,
                    clientId:
                        "AUVOO88x47ACLhktvCfLpST_FvoNe_f145vGcti1eyPBL6i6AVDmDqol8RP9RFTtQNCJwE7YhAwyfUHR",
                    secretKey:
                        "EMrbcl_LhdVO48iFbrt0YrjExfopavHfqs6nNjaoMVWDoJHFh16t3_17zhpeB3lCIRxG24DkDialPJia",
                    transactions: [
                      {
                        "amount": transactionData.amount.toJson(),
                        "description": "The payment transaction description.",
                        "item_list": transactionData.itemList.toJson(),
                      }
                    ],
                    note: "Contact us for any questions on your order.",
                    onSuccess: (Map params) async {
                      log("onSuccess: $params");
                      Navigator.pop(context);
                    },
                    onError: (error) {
                      log("onError: $error");
                      Navigator.pop(context);
                    },
                    onCancel: () {
                      // print('cancelled:');
                      Navigator.pop(context);
                    },
                  ),
                ));
              },
              child: const Text(
                'Checkout',
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  ({Amount amount, ItemListModel itemList}) getTransaction() {
    var amount = Amount(
      total: "100",
      currency: 'USD',
      details: Details(
        shipping: "0",
        shippingDiscount: 0,
        subtotal: '100',
      ),
    );

    List<OrderItemModel> orders = [
      OrderItemModel(
        name: 'Apple',
        price: "4",
        currency: 'USD',
        quantity: 10,
      ),
      OrderItemModel(
        name: 'Apple',
        price: "5",
        currency: 'USD',
        quantity: 12,
      ),
    ];
    var itemList = ItemListModel(
      items: orders,
    );

    return (amount: amount, itemList: itemList);
  }
}

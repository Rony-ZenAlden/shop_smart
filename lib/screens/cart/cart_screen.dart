import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_smart/screens/loading_manager.dart';
import 'package:uuid/uuid.dart';

import '../../providers/cart_provider.dart';
import '../../providers/products_provider.dart';
import '../../providers/user_provider.dart';
import '../../services/assets_manager.dart';
import '../../services/my_app_functions.dart';
import '../../widgets/app_name_text.dart';
import '../../widgets/empty_bag.dart';
import '../../widgets/title_text.dart';
import 'bottom_checkout.dart';
import 'cart_widget.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    // final productsProvider = Provider.of<ProductsProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context);
    final productsProvider = Provider.of<ProductsProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);

    return cartProvider.getCartitems.isEmpty
        ? Scaffold(
            appBar: AppBar(),
            body: EmptyBagWidget(
              imagePath: AssetsManager.shoppingBasket,
              title: "Your cart is empty",
              subtitle:
                  "Looks like your cart is empty add something and make me happy",
              buttonText: "Shop now",
            ),
          )
        : Scaffold(
            bottomSheet: CartBottomSheetWidget(
              function: () async {
                await placeOrderAdvanced(
                  cartProvider: cartProvider,
                  productProvider: productsProvider,
                  userProvider: userProvider,
                );
              },
            ),
            appBar: AppBar(
              leading: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset(
                  AssetsManager.shoppingCart,
                ),
              ),
              title: AppNameTextWidget(
                text: "Cart (${cartProvider.getCartitems.length})",
                fontSize: 24,
              ),
              actions: [
                IconButton(
                  onPressed: () {
                    MyAppFunctions.showErrorOrWarningDialog(
                      isError: false,
                      context: context,
                      subtitle: "Clear cart?",
                      fct: () async {
                        await cartProvider.clearCartFromFireStore();
                        //cartProvider.clearLocalCart();
                      },
                    );
                  },
                  icon: const Icon(
                    Icons.delete_forever_rounded,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            body: LoadingManager(
              isLoading: _isLoading,
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                        itemCount: cartProvider.getCartitems.length,
                        itemBuilder: (context, index) {
                          return ChangeNotifierProvider.value(
                              value: cartProvider.getCartitems.values
                                  .toList()[index],
                              child: const CartWidget());
                        }),
                  ),
                  const SizedBox(
                    height: kBottomNavigationBarHeight + 10,
                  )
                ],
              ),
            ),
          );
  }

  // Get Carts From Firebase
  Future<void> placeOrderAdvanced({
    required CartProvider cartProvider,
    required ProductsProvider productProvider,
    required UserProvider userProvider,
  }) async {
    final auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    if (user == null) {
      return;
    }
    final uid = user.uid;
    try {
      setState(() {
        _isLoading = true;
      });
      cartProvider.getCartitems.forEach((key, value) async {
        final getCurrProduct = productProvider.findByProdId(value.productId);
        final orderId = const Uuid().v4();
        await FirebaseFirestore.instance
            .collection("ordersAdvanced")
            .doc(orderId)
            .set({
          'orderId': orderId,
          'userId': uid,
          'productId': value.productId,
          "productTitle": getCurrProduct!.productTitle,
          'price': double.parse(getCurrProduct.productPrice) * value.quantity,
          'totalPrice':
              cartProvider.getTotal(productsProvider: productProvider),
          'quantity': value.quantity,
          'imageUrl': getCurrProduct.productImage,
          'userName': userProvider.getUserModel!.userName,
          'orderDate': Timestamp.now(),
        });
      });
      await cartProvider.clearCartFromFireStore();
      cartProvider.clearLocalCart();
    } catch (e) {
      await MyAppFunctions.showErrorOrWarningDialog(
        context: context,
        subtitle: e.toString(),
        fct: () {},
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
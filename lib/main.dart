import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shop_smart/providers/cart_provider.dart';
import 'package:shop_smart/providers/order_provider.dart';
import 'package:shop_smart/providers/products_provider.dart';
import 'package:shop_smart/providers/theme_provider.dart';
import 'package:shop_smart/providers/user_provider.dart';
import 'package:shop_smart/providers/viewed_recently_provider.dart';
import 'package:shop_smart/providers/wishlist_provider.dart';
import 'package:shop_smart/root_screen.dart';
import 'package:shop_smart/screens/auth/forgot_password.dart';
import 'package:shop_smart/screens/auth/login.dart';
import 'package:shop_smart/screens/auth/register.dart';
import 'package:shop_smart/screens/home_screen.dart';
import 'package:shop_smart/screens/inner_screen/orders/orders_screen.dart';
import 'package:shop_smart/screens/inner_screen/product_details.dart';
import 'package:shop_smart/screens/inner_screen/viewed_recently.dart';
import 'package:shop_smart/screens/inner_screen/wishlist.dart';
import 'package:shop_smart/screens/search_screen.dart';

import 'constant/theme_data.dart';
import 'firebase_options.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(
      const MyApp(),
    );
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) {
          return ThemeProvider();
        }),
        ChangeNotifierProvider(create: (_) {
          return ProductsProvider();
        }),
        ChangeNotifierProvider(create: (_) {
          return CartProvider();
        }),
        ChangeNotifierProvider(create: (_) {
          return WishlistProvider();
        }),
        ChangeNotifierProvider(create: (_) {
          return ViewedProdProvider();
        }),
        ChangeNotifierProvider(create: (_) {
          return UserProvider();
        }),
        ChangeNotifierProvider(create: (_) {
          return OrderProvider();
        }),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Shop-Smart',
            theme: Styles.themeData(
                isDarkTheme: themeProvider.getIsDarkTheme, context: context),
            home: const LoginScreen(),
            routes: {
              ProductDetailsScreen.routName: (context) =>
                  const ProductDetailsScreen(),
              WishlistScreen.routName: (context) => const WishlistScreen(),
              ViewedRecentlyScreen.routName: (context) =>
                  const ViewedRecentlyScreen(),
              RegisterScreen.routName: (context) => const RegisterScreen(),
              RootScreen.routeName: (context) => const RootScreen(),
              LoginScreen.routeName: (context) => const LoginScreen(),
              OrdersScreenFree.routeName: (context) => const OrdersScreenFree(),
              ForgotPasswordScreen.routeName: (context) =>
                  const ForgotPasswordScreen(),
              SearchScreen.routeName: (context) => const SearchScreen(),
              HomeScreen.routName: (context) => const HomeScreen(),
            },
          );
        },
      ),
    );
  }
}

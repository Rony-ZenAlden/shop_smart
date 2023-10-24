import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_smart/screens/inner_screen/orders/orders_widget.dart';
import 'package:shop_smart/services/assets_manager.dart';
import 'package:shop_smart/widgets/app_name_text.dart';
import 'package:shop_smart/widgets/empty_bag.dart';
import '../../../models/order_model.dart';
import '../../../providers/order_provider.dart';
import '../../../widgets/title_text.dart';

class OrdersScreenFree extends StatefulWidget {
  static const routeName = '/OrderScreen';

  const OrdersScreenFree({Key? key}) : super(key: key);

  @override
  State<OrdersScreenFree> createState() => _OrdersScreenFreeState();
}

class _OrdersScreenFreeState extends State<OrdersScreenFree> {

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: AppNameTextWidget(
          text: 'Placed orders(${orderProvider.getOrders.length})',
            fontSize: 24,
        ),
      ),
      body: FutureBuilder<List<OrdersModelAdvanced>>(
        future: orderProvider.fetchOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: SelectableText(snapshot.error.toString()),
            );
          } else if (!snapshot.hasData || orderProvider.getOrders.isEmpty) {
            return EmptyBagWidget(
              imagePath: AssetsManager.orderBag,
              title: 'No Orders has been placed yet',
              subtitle: '',
              buttonText: 'Shop Now',
            );
          }
          return ListView.separated(
            itemCount: snapshot.data!.length,
            itemBuilder: (ctx, index) {
              return Padding(
                padding:const EdgeInsets.symmetric(horizontal: 7,vertical: 6),
                child: OrdersWidgetFree(ordersModelAdvanced: orderProvider.getOrders[index],),
              );
            },
            separatorBuilder: (BuildContext context, int index) {
              return const Divider(
                thickness: 1,
                color: Colors.grey,
              );
            },
          );
        },
      ),
    );
  }
}

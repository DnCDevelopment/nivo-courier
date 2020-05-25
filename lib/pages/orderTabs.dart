import 'package:flutter/material.dart';

import 'package:nivocourier/widgets/Cart/cart.dart';
import 'package:nivocourier/widgets/Orders/orders.dart';

class OrderTabs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            bottom: TabBar(
              tabs: [
                Tab(text: 'Orders'),
                Tab(text: 'Cart'),
              ],
            ),
          ),
          body: TabBarView(
            children: [Orders(), Cart()],
          ),
        ),
      ),
    );
  }
}

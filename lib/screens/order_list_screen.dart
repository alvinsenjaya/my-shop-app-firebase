import 'package:flutter/material.dart';
import 'package:my_shop_app/models/auth.dart';
import 'package:my_shop_app/models/order.dart';
import 'package:my_shop_app/widgets/main_drawer.dart';
import 'package:my_shop_app/widgets/order_list_item.dart';
import 'package:provider/provider.dart';

class OrderListScreen extends StatefulWidget {
  static const routeName = '/orders';

  @override
  _OrderListScreenState createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Orders'),
      ),
      drawer: MainDrawer(),
      body: FutureBuilder(
        future: Order.findAll(
          Provider.of<Auth>(context, listen: false).token,
          Provider.of<Auth>(context, listen: false).userId,
        ),
        builder: (context, dataSnapshot) {
          if (dataSnapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (dataSnapshot.error != null) {
            return Center(child: Text('Error fetching data from server'));
          } else {
            List<Order> _orders = dataSnapshot.data;
            return RefreshIndicator(
              onRefresh: () async {
                setState(() {});
              },
              child: _orders.length == 0
                  ? Center(
                      child: Text(
                        'Your order list is empty',
                      ),
                    )
                  : ListView.builder(
                      itemCount: _orders.length,
                      itemBuilder: (context, i) {
                        return OrderListItem(_orders[i]);
                      },
                    ),
            );
          }
        },
      ),
    );
  }
}

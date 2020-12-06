import 'package:flutter/material.dart';
import 'package:my_shop_app/models/auth.dart';
import 'package:my_shop_app/screens/order_list_screen.dart';
import 'package:my_shop_app/screens/user_product_list_manager_screen.dart';
import 'package:provider/provider.dart';

class MainDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          AppBar(
            title: Text('My Shop'),
            automaticallyImplyLeading: false,
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.shop),
            title: Text('Shop'),
            onTap: () => Navigator.of(context).pushReplacementNamed('/'),
          ),
          ListTile(
            leading: Icon(Icons.payment),
            title: Text('My Orders'),
            onTap: () => Navigator.of(context)
                .pushReplacementNamed(OrderListScreen.routeName),
          ),
          ListTile(
            leading: Icon(Icons.edit),
            title: Text('Manage Products'),
            onTap: () => Navigator.of(context)
                .pushReplacementNamed(UserProductListManagerScreen.routeName),
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Signout'),
            onTap: () {
              Provider.of<Auth>(context, listen: false).signOut();
              Navigator.of(context).pushNamed('/');
            },
          ),
        ],
      ),
    );
  }
}

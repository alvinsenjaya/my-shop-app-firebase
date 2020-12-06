import 'package:flutter/material.dart';
import 'package:my_shop_app/models/auth.dart';
import 'package:my_shop_app/models/product.dart';
import 'package:my_shop_app/screens/user_product_list_add_edit_screen.dart';
import 'package:my_shop_app/widgets/main_drawer.dart';
import 'package:my_shop_app/widgets/user_product_list_manager_item.dart';
import 'package:provider/provider.dart';

class UserProductListManagerScreen extends StatefulWidget {
  static const routeName = '/user-products-manager';

  @override
  _UserProductListManagerScreenState createState() =>
      _UserProductListManagerScreenState();
}

class _UserProductListManagerScreenState
    extends State<UserProductListManagerScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Product Manager'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).pushNamed(
                UserProductAddEditScreen.routeName,
              );
            },
          ),
        ],
      ),
      drawer: MainDrawer(),
      body: FutureBuilder(
        future: Product.findAllByUserId(
            Provider.of<Auth>(context, listen: false).token,
            Provider.of<Auth>(context, listen: false).userId),
        builder: (context, dataSnapshot) {
          if (dataSnapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (dataSnapshot.error != null) {
            return Center(
              child: Text('Error fetching data from server'),
            );
          } else {
            List<Product> _products = dataSnapshot.data;
            return _products.length == 0
                ? Center(
                    child: Text(
                      'Your product is empty',
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () async {
                      setState(() {});
                    },
                    child: ListView.builder(
                      itemCount: _products.length,
                      itemBuilder: (context, i) {
                        return UserProductListManagerItem(_products[i]);
                      },
                    ),
                  );
          }
        },
      ),
    );
  }
}

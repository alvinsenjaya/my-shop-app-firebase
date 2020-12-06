import 'package:flutter/material.dart';
import 'package:my_shop_app/models/auth.dart';
import 'package:my_shop_app/models/product.dart';
import 'package:my_shop_app/screens/cart_list_screen.dart';
import 'package:my_shop_app/widgets/main_drawer.dart';
import 'package:my_shop_app/widgets/product_grid_view_builder.dart';
import 'package:provider/provider.dart';

enum FilterOptions {
  FavoriteOnly,
  All,
}

class ProductListScreen extends StatefulWidget {
  static const routeName = '/product-list';

  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  bool _showFavoriteOnly = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MyShop'),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.of(context).pushNamed(CartListScreen.routeName);
            },
          ),
          PopupMenuButton(
            onSelected: (FilterOptions _filterOptions) {
              setState(() {
                if (_filterOptions == FilterOptions.FavoriteOnly) {
                  _showFavoriteOnly = true;
                } else {
                  _showFavoriteOnly = false;
                }
              });
            },
            icon: Icon(Icons.more_vert),
            itemBuilder: (_) {
              return [
                PopupMenuItem(
                  child: Text('Show Favorites'),
                  value: FilterOptions.FavoriteOnly,
                ),
                PopupMenuItem(
                  child: Text('Show All'),
                  value: FilterOptions.All,
                ),
              ];
            },
          ),
        ],
      ),
      drawer: MainDrawer(),
      body: FutureBuilder(
          future: _showFavoriteOnly
              ? Product.findAllByIsFavorite(
                  true,
                  Provider.of<Auth>(context, listen: false).token,
                  Provider.of<Auth>(context, listen: false).userId)
              : Product.findAll(Provider.of<Auth>(context, listen: false).token,
                  Provider.of<Auth>(context, listen: false).userId),
          builder: (context, dataSnapshot) {
            if (dataSnapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else if (dataSnapshot.error != null) {
              return Center(child: Text('Error fetching data from server'));
            } else {
              List<Product> _products = dataSnapshot.data;
              return RefreshIndicator(
                onRefresh: () async {
                  setState(() {});
                },
                child: ProductGridViewBuilder(_products),
              );
            }
          }),
    );
  }
}

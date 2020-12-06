import 'package:flutter/material.dart';
import 'package:my_shop_app/models/auth.dart';
import 'package:my_shop_app/models/cart.dart';
import 'package:my_shop_app/models/product.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class ProductDetailScreen extends StatefulWidget {
  static const routeName = '/product-detail';

  Product _product;

  ProductDetailScreen(this._product);

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget._product.title),
        actions: [
          Builder(
            builder: (context) {
              final scaffold = Scaffold.of(context);
              return IconButton(
                icon: Icon(widget._product.isFavorite
                    ? Icons.favorite
                    : Icons.favorite_outline),
                color: Theme.of(context).accentColor,
                onPressed: () async {
                  setState(() {
                    widget._product.isFavorite = !widget._product.isFavorite;
                  });
                  scaffold.hideCurrentSnackBar();
                  scaffold.showSnackBar(
                    SnackBar(
                      content: Text(
                        widget._product.isFavorite
                            ? 'Item added to favorite'
                            : 'Item removed from favorite',
                      ),
                      duration: Duration(seconds: 2),
                    ),
                  );
                  await Product.setFavoriteById(
                      widget._product.id,
                      widget._product.isFavorite,
                      Provider.of<Auth>(context, listen: false).token,
                      Provider.of<Auth>(context, listen: false).userId);
                },
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Product.findById(
            widget._product.id,
            Provider.of<Auth>(context, listen: false).token,
            Provider.of<Auth>(context, listen: false).userId,
          ).then((value) => setState(() {
                widget._product = value;
              }));
        },
        child: ListView(
          children: [
            Container(
              height: 300,
              width: double.infinity,
              child: Image.network(widget._product.imageUrl, fit: BoxFit.cover),
            ),
            SizedBox(height: 30),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 30),
              width: double.infinity,
              child: Text(
                'Price',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
                textAlign: TextAlign.start,
                softWrap: true,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 30),
              width: double.infinity,
              child: Text(
                'IDR ${widget._product.price.toStringAsFixed(0)}',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 16,
                ),
                textAlign: TextAlign.start,
                softWrap: true,
              ),
            ),
            SizedBox(height: 30),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 30),
              width: double.infinity,
              child: Text(
                'Description',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
                textAlign: TextAlign.start,
                softWrap: true,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 30),
              width: double.infinity,
              child: Text(
                widget._product.description,
                textAlign: TextAlign.start,
                softWrap: true,
              ),
            ),
            SizedBox(height: 30),
          ],
        ),
      ),
      floatingActionButton: Builder(
        builder: (BuildContext context) {
          final scaffold = Scaffold.of(context);
          return FloatingActionButton(
            child: Icon(Icons.shopping_cart_outlined),
            backgroundColor: Theme.of(context).primaryColor,
            onPressed: () {
              Cart.addToCart(
                productId: widget._product.id,
                quantity: 1,
                imageUrl: widget._product.imageUrl,
                price: widget._product.price,
                title: widget._product.title,
                token: Provider.of<Auth>(context, listen: false).token,
                userId: Provider.of<Auth>(context, listen: false).userId,
              );
              scaffold.hideCurrentSnackBar();
              scaffold.showSnackBar(
                SnackBar(
                  content: Text(
                    'Item added to cart',
                  ),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

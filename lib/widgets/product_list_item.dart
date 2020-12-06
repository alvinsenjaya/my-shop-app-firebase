import 'package:flutter/material.dart';
import 'package:my_shop_app/models/auth.dart';
import 'package:my_shop_app/models/cart.dart';
import 'package:my_shop_app/models/product.dart';
import 'package:my_shop_app/screens/product_detail_screen.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class ProductListItem extends StatefulWidget {
  Product _product;

  ProductListItem(this._product);

  @override
  _ProductListItemState createState() => _ProductListItemState();
}

class _ProductListItemState extends State<ProductListItem> {
  @override
  Widget build(BuildContext context) {
    final scaffold = Scaffold.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: GridTile(
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).pushNamed(
              ProductDetailScreen.routeName,
              arguments: widget._product,
            );
          },
          child: Image.network(widget._product.imageUrl, fit: BoxFit.cover),
        ),
        footer: GridTileBar(
          backgroundColor: Theme.of(context).primaryColorDark.withOpacity(0.9),
          leading: IconButton(
            icon: Icon(widget._product.isFavorite
                ? Icons.favorite
                : Icons.favorite_outline),
            color: Theme.of(context).accentColor,
            onPressed: () async {
              Product.setFavoriteById(
                  widget._product.id,
                  !widget._product.isFavorite,
                  Provider.of<Auth>(context, listen: false).token,
                  Provider.of<Auth>(context, listen: false).userId);

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
            },
          ),
          title: Text(
            widget._product.title,
            textAlign: TextAlign.center,
          ),
          trailing: IconButton(
            icon: Icon(Icons.shopping_cart_outlined),
            color: Theme.of(context).accentColor,
            onPressed: () {
              Cart.addToCart(
                quantity: 1,
                productId: widget._product.id,
                title: widget._product.title,
                price: widget._product.price,
                imageUrl: widget._product.imageUrl,
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
          ),
        ),
      ),
    );
  }
}

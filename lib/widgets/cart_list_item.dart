import 'package:flutter/material.dart';
import 'package:my_shop_app/models/auth.dart';
import 'package:my_shop_app/models/cart.dart';
import 'package:my_shop_app/screens/cart_list_screen.dart';
import 'package:provider/provider.dart';

class CartListItem extends StatelessWidget {
  final Cart _cart;

  const CartListItem(this._cart);

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(_cart.id),
      direction: DismissDirection.endToStart,
      background: Container(
        child: Icon(
          Icons.delete,
          color: Colors.white,
          size: 30,
        ),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
        color: Theme.of(context).errorColor,
      ),
      onDismissed: (direction) {
        Cart.deleteById(
          _cart.id,
          Provider.of<Auth>(context, listen: false).token,
          Provider.of<Auth>(context, listen: false).userId,
        ).then((value) {
          Navigator.of(context).pushReplacementNamed(CartListScreen.routeName);
        });
      },
      confirmDismiss: (direction) {
        return buildShowConfirmRemoveItemDialog(context);
      },
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListTile(
            leading: Container(
              width: 60,
              height: 60,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(_cart.imageUrl, fit: BoxFit.cover),
              ),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _cart.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(child: Text('Quantity: ${_cart.quantity}')),
                FittedBox(
                    child:
                        Text('Price: IDR ${_cart.price.toStringAsFixed(0)}')),
                FittedBox(
                    child: Text(
                        'Total: IDR ${(_cart.quantity * _cart.price).toStringAsFixed(0)}')),
              ],
            ),
            trailing: IconButton(
              icon: Icon(
                Icons.delete,
                color: Colors.red[900],
              ),
              onPressed: () {
                buildShowConfirmRemoveItemDialog(context).then((isConfirmed) {
                  if (isConfirmed) {
                    Cart.deleteById(
                      _cart.id,
                      Provider.of<Auth>(context, listen: false).token,
                      Provider.of<Auth>(context, listen: false).userId,
                    ).then((value) => Navigator.of(context)
                        .pushReplacementNamed(CartListScreen.routeName));
                  }
                });
              },
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> buildShowConfirmRemoveItemDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Remove Item'),
          content: Text('Are you sure to remove selected item from cart?'),
          actions: [
            FlatButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text('No'),
            ),
            FlatButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text('Yes'),
            ),
          ],
        );
      },
    );
  }
}

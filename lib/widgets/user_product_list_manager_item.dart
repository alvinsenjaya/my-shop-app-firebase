import 'package:flutter/material.dart';
import 'package:my_shop_app/models/auth.dart';
import 'package:my_shop_app/models/product.dart';
import 'package:my_shop_app/screens/user_product_list_add_edit_screen.dart';
import 'package:my_shop_app/screens/user_product_list_manager_screen.dart';
import 'package:provider/provider.dart';

class UserProductListManagerItem extends StatelessWidget {
  final Product _product;

  const UserProductListManagerItem(this._product);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text(_product.title),
          subtitle: Text(
            'IDR ${_product.price.toStringAsFixed(0)}',
            textAlign: TextAlign.start,
          ),
          leading: Container(
            width: 60,
            height: 60,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(_product.imageUrl, fit: BoxFit.cover),
            ),
          ),
          trailing: Container(
            width: 100,
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  color: Theme.of(context).primaryColor,
                  onPressed: () {
                    Navigator.of(context).pushNamed(
                      UserProductAddEditScreen.routeName,
                      arguments: _product,
                    );
                  },
                ),
                IconButton(
                  icon: Icon(
                    Icons.delete,
                    color: Colors.red[900],
                  ),
                  onPressed: () async {
                    try {
                      await Product.deleteById(_product.id,
                          Provider.of<Auth>(context, listen: false).token);
                      Navigator.of(context).pushReplacementNamed(
                          UserProductListManagerScreen.routeName);
                    } catch (error) {
                      showDialog<Null>(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text('Error Occurred'),
                            content: Text(error.toString()),
                            actions: [
                              FlatButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text('Ok'),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
        Divider(),
      ],
    );
  }
}

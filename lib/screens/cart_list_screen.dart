import 'package:flutter/material.dart';
import 'package:my_shop_app/models/auth.dart';
import 'package:my_shop_app/models/cart.dart';
import 'package:my_shop_app/models/order.dart';
import 'package:my_shop_app/widgets/cart_list_item.dart';
import 'package:provider/provider.dart';

class CartListScreen extends StatefulWidget {
  static const routeName = '/cart';

  @override
  _CartListScreenState createState() => _CartListScreenState();
}

class _CartListScreenState extends State<CartListScreen> {
  bool _isLoading = false;
  List<Cart> _carts;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Shopping Cart'),
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            setState(() {});
          },
          child: FutureBuilder(
              future: Cart.findAll(
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
                  _carts = dataSnapshot.data;
                  return Column(
                    children: [
                      Card(
                        margin: EdgeInsets.all(10),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total',
                                style: TextStyle(fontSize: 20),
                              ),
                              Spacer(),
                              Chip(
                                label: Text(
                                  'IDR ${Cart.totalAmountByListOfCart(_carts).toStringAsFixed(0)}',
                                  style: TextStyle(
                                      color:
                                          Theme.of(context).primaryColorDark),
                                ),
                                backgroundColor:
                                    Theme.of(context).primaryColorLight,
                              ),
                              FlatButton(
                                onPressed: (_carts.length <= 0 || _isLoading)
                                    ? null
                                    : () async {
                                        setState(() {
                                          _isLoading = true;
                                        });

                                        await Order.create(
                                          date: DateTime.now(),
                                          amount: Cart.totalAmountByListOfCart(
                                              _carts),
                                          carts: _carts,
                                          token: Provider.of<Auth>(context,
                                                  listen: false)
                                              .token,
                                          userId: Provider.of<Auth>(context,
                                                  listen: false)
                                              .userId,
                                        );

                                        setState(() {
                                          _isLoading = false;
                                        });

                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              title:
                                                  Text('Checkout Successful'),
                                              content: Text(
                                                  'Checkout successful. Please provide your payment. Thank you.'),
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
                                        Cart.deleteAll(
                                            Provider.of<Auth>(context,
                                                    listen: false)
                                                .token,
                                            Provider.of<Auth>(context,
                                                    listen: false)
                                                .userId);
                                      },
                                child: Text(
                                  'ORDER NOW',
                                  style: TextStyle(
                                      color:
                                          Theme.of(context).primaryColorDark),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: _carts.length == 0
                            ? Center(
                                child: Text(
                                  'Your cart is empty',
                                ),
                              )
                            : ListView.builder(
                                itemCount: _carts.length,
                                itemBuilder: (BuildContext context, int i) {
                                  return CartListItem(_carts[i]);
                                },
                              ),
                      ),
                    ],
                  );
                }
              }),
        ));
  }
}

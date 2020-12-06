import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_shop_app/models/order.dart';

class OrderListItem extends StatefulWidget {
  final Order _order;

  const OrderListItem(this._order);

  @override
  _OrderListItemState createState() => _OrderListItemState();
}

class _OrderListItemState extends State<OrderListItem> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 4,
      ),
      child: Column(
        children: [
          ListTile(
            title: Text('IDR ${widget._order.amount.toStringAsFixed(0)}'),
            subtitle: Text(
                DateFormat('dd MMM yyyy, hh:mm').format(widget._order.date)),
            trailing: IconButton(
              icon: Icon(
                _expanded ? Icons.expand_less : Icons.expand_more,
              ),
              onPressed: () {
                setState(() {
                  _expanded = !_expanded;
                });
              },
            ),
          ),
          if (_expanded)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 3),
              height: min(widget._order.carts.length * 20.0 + 20.0, 150.0),
              child: ListView.builder(
                itemCount: widget._order.carts.length,
                itemBuilder: (context, i) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget._order.carts[i].title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${widget._order.carts[i].quantity.toString()} x IDR ${widget._order.carts[i].price.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:my_shop_app/models/cart.dart';
import 'package:my_shop_app/variable.dart';

import 'http_exception.dart';

class Order {
  String id;
  double amount;
  List<Cart> carts;
  DateTime date;

  Order({
    @required this.date,
    @required this.amount,
    @required this.carts,
  });

  Map<String, dynamic> toJson() {
    List<dynamic> _cartsJson = [];
    carts.forEach((element) {
      _cartsJson.add(element.toJson());
    });

    return {
      'amount': amount.toString(),
      'carts': _cartsJson,
      'date': date.toString(),
    };
  }

  Order.fromJson(Map<String, dynamic> json) {
    List<dynamic> _cartsJson = json['carts'];

    List<Cart> _carts = [];

    _cartsJson.forEach((value) {
      Cart _cart = Cart.fromJson(value);
      _cart.id = value['id'];
      _carts.add(_cart);
    });

    amount = json['amount'];
    carts = _carts;
    date = DateTime.parse(json['date']);
  }

  static Future<List<Order>> findAll(String token, String userId) async {
    final List<Order> _orders = [];

    final _url = '${Variable.databaseUrl}/orders/$userId.json?auth=$token';

    final _response = await http.get(_url);

    if (_response.statusCode >= 400) {
      throw HttpException('Failed to get orders');
    }

    final _jsonResponseBody =
        json.decode(_response.body) as Map<String, dynamic>;

    if (_jsonResponseBody != null) {
      _jsonResponseBody.forEach((key, value) {
        Order _order = Order.fromJson(value);
        _order.id = key;

        _orders.add(_order);
      });
    }

    return _orders.reversed.toList();
  }

  static Future<void> create({
    @required DateTime date,
    @required double amount,
    @required List<Cart> carts,
    @required String token,
    @required String userId,
  }) async {
    if (amount <= 0 || carts.length <= 0) {
      return;
    }

    final url = '${Variable.databaseUrl}/orders/$userId.json?auth=$token';

    final _body = {
      'date': date.toString(),
      'amount': amount,
      'carts': carts,
    };

    final _response = await http.post(url, body: json.encode(_body));

    if (_response.statusCode >= 400) {
      throw HttpException('Failed to create order');
    }
  }
}

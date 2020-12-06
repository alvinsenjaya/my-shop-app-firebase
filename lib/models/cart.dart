import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'package:my_shop_app/models/http_exception.dart';
import 'package:my_shop_app/variable.dart';

class Cart {
  String id;
  int quantity;
  String productId;
  String title;
  double price;
  String imageUrl;

  Cart({
    @required this.id,
    @required this.quantity,
    @required this.productId,
    @required this.title,
    @required this.price,
    @required this.imageUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quantity': quantity,
      'productId': productId,
      'title': title,
      'price': price,
      'imageUrl': imageUrl,
    };
  }

  Cart.fromJson(Map<String, dynamic> json) {
    quantity = json['quantity'];
    productId = json['productId'];
    title = json['title'];
    price = json['price'];
    imageUrl = json['imageUrl'];
  }

  double get amount {
    return this.quantity * this.price;
  }

  static Future<bool> isProductAddedToCart(
      String productId, String token, String userId) async {
    final _url =
        '${Variable.databaseUrl}/carts/$userId.json?auth=$token&orderBy="productId"&equalTo="$productId"';

    final List<Cart> _carts = [];

    final _response = await http.get(_url);

    if (_response.statusCode >= 400) {
      return false;
    }

    final _jsonResponseBody =
        json.decode(_response.body) as Map<String, dynamic>;

    _jsonResponseBody.forEach((key, value) {
      Cart _cart = Cart.fromJson(value);
      _cart.id = key;
      _carts.add(_cart);
    });

    return _carts.length > 0 ? true : false;
  }

  static double totalAmountByListOfCart(List<Cart> carts) {
    double totalAmount = 0;
    carts.forEach((element) {
      totalAmount = totalAmount + element.amount;
    });

    return totalAmount;
  }

  Future<double> totalAmount(String token, String userId) async {
    final List<Cart> _carts = [];

    final _url = '${Variable.databaseUrl}/carts/$userId.json?auth=$token';

    final _response = await http.get(_url);

    if (_response.statusCode >= 400) {
      throw HttpException('Failed to get cart items');
    }

    final _jsonResponseBody =
        json.decode(_response.body) as Map<String, dynamic>;

    if (_jsonResponseBody != null) {
      _jsonResponseBody.forEach((key, value) {
        Cart _cart = Cart.fromJson(value);
        _cart.id = key;
        _carts.add(_cart);
      });
    }

    double totalAmount = 0;
    _carts.forEach((element) {
      totalAmount = totalAmount + element.amount;
    });

    return totalAmount;
  }

  static Future<void> addToCart({
    @required int quantity,
    @required String productId,
    @required String title,
    @required double price,
    @required String imageUrl,
    @required String token,
    @required String userId,
  }) async {
    bool _isProductAddedToCart =
        await isProductAddedToCart(productId, token, userId);

    if (_isProductAddedToCart) {
      findByProductId(productId, token, userId).then((_existingCart) {
        updateQuantityById(
            id: _existingCart.id,
            quantity: _existingCart.quantity + quantity,
            token: token,
            userId: userId);
      });
    } else {
      await create(
        quantity: quantity,
        productId: productId,
        title: title,
        price: price,
        imageUrl: imageUrl,
        token: token,
        userId: userId,
      );
    }
  }

  static Future<void> create({
    @required int quantity,
    @required String productId,
    @required String title,
    @required double price,
    @required String imageUrl,
    @required String token,
    @required String userId,
  }) async {
    final _url = '${Variable.databaseUrl}/carts/$userId.json?auth=$token';

    final _body = {
      'quantity': quantity,
      'productId': productId,
      'title': title,
      'price': price,
      'imageUrl': imageUrl
    };

    final _response = await http.post(_url, body: json.encode(_body));

    if (_response.statusCode >= 400) {
      throw HttpException('Failed to create cart');
    }
  }

  static Future<List<Cart>> findAll(String token, String userId) async {
    final List<Cart> _carts = [];

    final _url = '${Variable.databaseUrl}/carts/$userId.json?auth=$token';

    final _response = await http.get(_url);

    if (_response.statusCode >= 400) {
      throw HttpException('Failed to get cart items');
    }

    final _jsonResponseBody =
        json.decode(_response.body) as Map<String, dynamic>;

    if (_jsonResponseBody != null) {
      _jsonResponseBody.forEach((key, value) {
        Cart _cart = Cart.fromJson(value);
        _cart.id = key;
        _carts.add(_cart);
      });
    }

    return _carts;
  }

  static Future<Cart> findById(String id, String token, String userId) async {
    final _url = '${Variable.databaseUrl}/carts/$userId/$id.json?auth=$token';

    final _response = await http.get(_url);

    if (_response.statusCode >= 400) {
      throw HttpException('Failed to get cart');
    }

    final _jsonResponseBody =
        json.decode(_response.body) as Map<String, dynamic>;

    Cart cart = Cart.fromJson(_jsonResponseBody);
    cart.id = id;

    return cart;
  }

  static Future<Cart> findByProductId(
      String productId, String token, String userId) async {
    final _url =
        '${Variable.databaseUrl}/carts/$userId.json?auth=$token&orderBy="productId"&equalTo="$productId"';

    final List<Cart> _carts = [];

    final _response = await http.get(_url);

    if (_response.statusCode >= 400) {
      return null;
    }

    final _jsonResponseBody =
        json.decode(_response.body) as Map<String, dynamic>;

    _jsonResponseBody.forEach((key, value) {
      Cart _cart = Cart.fromJson(value);
      _cart.id = key;
      _carts.add(_cart);
    });

    return _carts.length > 0 ? _carts[0] : null;
  }

  static Future<void> updateById({
    @required String id,
    @required int quantity,
    @required String productId,
    @required String title,
    @required double price,
    @required String imageUrl,
    @required String token,
    @required String userId,
  }) async {
    final url = '${Variable.databaseUrl}/carts/$userId/$id.json?auth=$token';

    final _body = {
      'quantity': quantity,
      'productId': productId,
      'title': title,
      'price': price,
      'imageUrl': imageUrl
    };

    final _response = await http.patch(url, body: json.encode(_body));

    if (_response.statusCode >= 400) {
      throw HttpException('Failed to update cart');
    }
  }

  static Future<void> updateQuantityById({
    @required String id,
    @required int quantity,
    @required String token,
    @required String userId,
  }) async {
    final url = '${Variable.databaseUrl}/carts/$userId/$id.json?auth=$token';

    final _body = {'quantity': quantity};

    final _response = await http.patch(url, body: json.encode(_body));

    if (_response.statusCode >= 400) {
      throw HttpException('Failed to update quantity');
    }
  }

  static Future<void> deleteById(String id, String token, String userId) async {
    final url = '${Variable.databaseUrl}/carts/$userId/$id.json?auth=$token';

    final response = await http.delete(url);

    if (response.statusCode >= 400) {
      throw HttpException('Failed to delete cart');
    }
  }

  static Future<void> deleteAll(String token, String userId) async {
    final url = '${Variable.databaseUrl}/carts/$userId.json?auth=$token';

    final response = await http.delete(url);

    if (response.statusCode >= 400) {
      throw HttpException('Failed to delete cart items');
    }
  }

  static Future<int> length(String token, String userId) async {
    final List<Cart> _carts = [];

    final _url = '${Variable.databaseUrl}/carts/$userId.json?auth=$token';

    final _response = await http.get(_url);

    if (_response.statusCode >= 400) {
      throw HttpException('Failed to get cart items');
    }

    final _jsonResponseBody =
        json.decode(_response.body) as Map<String, dynamic>;

    if (_jsonResponseBody != null) {
      _jsonResponseBody.forEach((key, value) {
        Cart _cart = Cart.fromJson(value);
        _cart.id = key;
        _carts.add(_cart);
      });
    }

    return _carts.length;
  }
}

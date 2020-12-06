import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'package:my_shop_app/models/http_exception.dart';
import 'package:my_shop_app/variable.dart';

class Product {
  String id;
  String title;
  String description;
  double price;
  String imageUrl;
  String userId;
  bool isFavorite = false;

  Product({
    @required this.id,
    @required this.title,
    @required this.description,
    @required this.price,
    @required this.imageUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'userId': userId,
    };
  }

  Product.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    description = json['description'];
    price = json['price'];
    imageUrl = json['imageUrl'];
    userId = json['userId'];
  }

  static Future<void> create({
    @required String title,
    @required String description,
    @required double price,
    @required String imageUrl,
    @required String token,
    @required String userId,
  }) async {
    final _url = '${Variable.databaseUrl}/products.json?auth=$token';

    final _body = {
      'title': title,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'userId': userId
    };

    final _response = await http.post(_url, body: json.encode(_body));

    if (_response.statusCode >= 400) {
      throw HttpException('Failed to create product');
    }
  }

  static Future<List<Product>> findAll(String token, String userId) async {
    final List<Product> _products = [];

    final _url = '${Variable.databaseUrl}/products.json?auth=$token';

    final _response = await http.get(_url);

    if (_response.statusCode >= 400) {
      throw HttpException('Failed to get all products');
    }

    final _jsonResponseBody =
        json.decode(_response.body) as Map<String, dynamic>;

    final _urlFavorite =
        '${Variable.databaseUrl}/user-favorites/$userId.json?auth=$token&orderBy="isFavorite"&equalTo=true';

    final _responseFavorite = await http.get(_urlFavorite);

    if (_responseFavorite.statusCode >= 400) {
      throw HttpException('Failed to get user favorite');
    }

    final _jsonResponseBodyFavorite =
        json.decode(_responseFavorite.body) as Map<String, dynamic>;

    if (_jsonResponseBody != null) {
      _jsonResponseBody.forEach((key, value) {
        Product product = Product.fromJson(value);
        product.id = key;
        product.isFavorite = (_jsonResponseBodyFavorite == null ||
                _jsonResponseBodyFavorite[product.id] == null ||
                _jsonResponseBodyFavorite[product.id]['isFavorite'] == null)
            ? false
            : _jsonResponseBodyFavorite[product.id]['isFavorite'];

        _products.add(product);
      });
    }

    return _products;
  }

  static Future<List<Product>> findAllByUserId(
      String token, String userId) async {
    final List<Product> _products = [];

    final _url =
        '${Variable.databaseUrl}/products.json?auth=$token&orderBy="userId"&equalTo="$userId"';

    final _response = await http.get(_url);

    if (_response.statusCode >= 400) {
      throw HttpException('Failed to get all products');
    }

    final _jsonResponseBody =
        json.decode(_response.body) as Map<String, dynamic>;

    final _urlFavorite =
        '${Variable.databaseUrl}/user-favorites/$userId.json?auth=$token&orderBy="isFavorite"&equalTo=true';

    final _responseFavorite = await http.get(_urlFavorite);

    if (_responseFavorite.statusCode >= 400) {
      throw HttpException('Failed to get user favorite');
    }

    final _jsonResponseBodyFavorite =
        json.decode(_responseFavorite.body) as Map<String, dynamic>;

    if (_jsonResponseBody != null) {
      _jsonResponseBody.forEach((key, value) {
        Product product = Product.fromJson(value);
        product.id = key;
        product.isFavorite = (_jsonResponseBodyFavorite == null ||
                _jsonResponseBodyFavorite[product.id] == null ||
                _jsonResponseBodyFavorite[product.id]['isFavorite'] == null)
            ? false
            : _jsonResponseBodyFavorite[product.id]['isFavorite'];

        _products.add(product);
      });
    }

    return _products;
  }

  static Future<Product> findById(
      String id, String token, String userId) async {
    final _url = '${Variable.databaseUrl}/products/$id.json?auth=$token';

    final _response = await http.get(_url);

    if (_response.statusCode >= 400) {
      throw HttpException('Failed to get product');
    }

    final _urlFavorite =
        '${Variable.databaseUrl}/user-favorites/$userId.json?auth=$token&orderBy="isFavorite"&equalTo=true';

    final _responseFavorite = await http.get(_urlFavorite);

    if (_responseFavorite.statusCode >= 400) {
      throw HttpException('Failed to get user favorite');
    }

    final _jsonResponseBodyFavorite =
        json.decode(_responseFavorite.body) as Map<String, dynamic>;

    final _jsonResponseBody =
        json.decode(_response.body) as Map<String, dynamic>;

    Product _product = Product.fromJson(_jsonResponseBody);
    _product.id = id;
    _product.isFavorite = (_jsonResponseBodyFavorite == null ||
            _jsonResponseBodyFavorite[_product.id] == null ||
            _jsonResponseBodyFavorite[_product.id]['isFavorite'] == null)
        ? false
        : _jsonResponseBodyFavorite[_product.id]['isFavorite'];

    return _product;
  }

  static Future<void> updateById({
    @required String id,
    @required String title,
    @required String description,
    @required double price,
    @required String imageUrl,
    @required String token,
  }) async {
    final url = '${Variable.databaseUrl}/products/$id.json?auth=$token';

    final _body = {
      'title': title,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
    };

    final _response = await http.patch(url, body: json.encode(_body));

    if (_response.statusCode >= 400) {
      throw HttpException('Failed to update product');
    }
  }

  static Future<void> deleteById(String id, String token) async {
    final url = '${Variable.databaseUrl}/products/$id.json?auth=$token';

    final response = await http.delete(url);

    if (response.statusCode >= 400) {
      throw HttpException('Failed to delete product');
    }
  }

  static Future<void> setFavoriteById(
      String id, bool isFavorite, String token, String userId) async {
    final url =
        '${Variable.databaseUrl}/user-favorites/$userId/$id.json?auth=$token';

    var _response;

    if (isFavorite) {
      final _body = {'isFavorite': isFavorite};

      _response = await http.patch(url, body: json.encode(_body));
    } else {
      _response = await http.delete(url);
    }

    if (_response.statusCode >= 400) {
      throw HttpException('Failed to update favorite');
    }
  }

  static Future<List<Product>> findAllByIsFavorite(
      bool isFavorite, String token, String userId) async {
    final List<Product> _products = [];

    final _url =
        '${Variable.databaseUrl}/user-favorites/$userId.json?auth=$token&orderBy="isFavorite"&equalTo=$isFavorite';

    final _response = await http.get(_url);

    if (_response.statusCode >= 400) {
      throw HttpException('Failed to get user favorite');
    }

    final _jsonResponseBody =
        json.decode(_response.body) as Map<String, dynamic>;

    if (_jsonResponseBody == null) {
      return [];
    }

    await Future.forEach(_jsonResponseBody.entries, (MapEntry entry) async {
      Product product = await Product.findById(entry.key, token, userId);
      product.id = entry.key;
      product.isFavorite = entry.value['isFavorite'];

      _products.add(product);
    });

    return _products;
  }
}

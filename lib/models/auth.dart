import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'package:my_shop_app/models/http_exception.dart';
import 'package:my_shop_app/variable.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Auth with ChangeNotifier {
  String _token;
  DateTime _expiryDate;
  String _userId;
  Timer _authTimer;

  Auth();

  Map<String, dynamic> toJson() {
    return {
      '_token': _token,
      '_expiryDate': _expiryDate.toString(),
      '_userId': _userId,
    };
  }

  Auth.fromJson(Map<String, dynamic> json) {
    _token = json['_token'];
    _expiryDate = DateTime.parse(json['_expiryDate']);
    _userId = json['_userId'];
  }

  String get token {
    return isAuth ? _token : null;
  }

  DateTime get expiryDate {
    return _expiryDate;
  }

  String get userId {
    return isAuth ? _userId : null;
  }

  bool get isAuth {
    if (_expiryDate != null &&
        _expiryDate.isAfter(DateTime.now()) &&
        _token != null) {
      return true;
    }

    return false;
  }

  void signOut() async {
    _token = null;
    _expiryDate = null;
    _userId = null;
    if (_authTimer != null) {
      _authTimer.cancel();
      _authTimer = null;
    }

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();

    notifyListeners();
  }

  void _autoLogout() {
    if (_authTimer != null) {
      _authTimer.cancel();
    }
    _authTimer = Timer(
      Duration(seconds: _expiryDate.difference(DateTime.now()).inSeconds),
      signOut,
    );
  }

  Future<bool> tryAutoLogin() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    if (!prefs.containsKey('auth')) {
      return false;
    }

    final extractedAuth = Auth.fromJson(json.decode(prefs.getString('auth')));

    if (!extractedAuth.isAuth) {
      return false;
    }

    _token = extractedAuth.token;
    _expiryDate = extractedAuth.expiryDate;
    _userId = extractedAuth.userId;

    _autoLogout();
    notifyListeners();
    return true;
  }

  Future<void> signUp(String email, String password) async {
    const url =
        'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=${Variable.authKey}';

    final response = await http.post(
      url,
      body: json.encode(
        {
          'email': email,
          'password': password,
          'returnSecureToken': true,
        },
      ),
    );

    final responseData = json.decode(response.body);

    if (responseData['error'] != null) {
      throw HttpException(responseData['error']['message']);
    }

    _token = responseData['idToken'];
    _userId = responseData['localId'];
    _expiryDate = DateTime.now().add(
      Duration(
        seconds: int.parse(responseData['expiresIn']),
      ),
    );

    _autoLogout();
    notifyListeners();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('auth', json.encode(this.toJson()));
  }

  Future<void> signIn(String email, String password) async {
    const url =
        'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=${Variable.authKey}';

    final response = await http.post(
      url,
      body: json.encode(
        {
          'email': email,
          'password': password,
          'returnSecureToken': true,
        },
      ),
    );

    final responseData = json.decode(response.body);

    if (responseData['error'] != null) {
      throw HttpException(responseData['error']['message']);
    }

    _token = responseData['idToken'];
    _userId = responseData['localId'];
    _expiryDate = DateTime.now().add(
      Duration(
        seconds: int.parse(responseData['expiresIn']),
      ),
    );

    _autoLogout();
    notifyListeners();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('auth', json.encode(this.toJson()));
  }
}

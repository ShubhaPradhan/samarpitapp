import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart' show toBeginningOfSentenceCase;

import '../models/http_exception.dart';
import 'package:http/http.dart' as http;

class Auth with ChangeNotifier {
  String? _token = '';
  late String? _refreshToken = '';
  late String? userName = '';

  bool get isAuth {
    if (_token.toString().isNotEmpty) {
      return true;
    }
    return false;
  }

  String? get token {
    if (_token.toString().isNotEmpty) {
      return _token;
    }
    return null;
  }

  String? get loggedUserName {
    return userName.toString().isEmpty
        ? 'User'
        : toBeginningOfSentenceCase(userName);
  }

  // get the new access token using the refresh token and update the token in the shared preferences and the token in the auth provider every 1 minute
  Future<void> refreshToken() async {
    final url = Uri.parse('http://10.0.2.2:8000/api/token/refresh/');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'refresh': _refreshToken,
        }),
      );
      final responseData = json.decode(response.body);
      if (responseData['access'] != null) {
        _token = responseData['access'];
        _refreshToken = responseData['refresh'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setStringList('items', <String>[
          _token.toString(),
          _refreshToken.toString(),
          userName.toString(),
        ]);
        notifyListeners();
        // call the function again after 1 minute
        Future.delayed(const Duration(hours: 2), () {
          refreshToken();
        });
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<void> signup(String username, String email, String password) async {
    final url = Uri.parse('http://10.0.2.2:8000/api/register/');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'username': username,
          'email': email,
          'password': password,
        }),
      );
      final responseData = json.decode(response.body);
      if (response.statusCode == 409) {
        throw HttpException(responseData['message']);
      }
      if (response.statusCode == 400) {
        throw HttpException(responseData['message']);
      }
      if (response.statusCode == 200) {
        _token = responseData['access'];
        _refreshToken = responseData['refresh'];
        userName = responseData['username'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setStringList('items', <String>[
          _token.toString(),
          _refreshToken.toString(),
          userName.toString(),
        ]);
        refreshToken();
        notifyListeners();
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<void> login(
    String username,
    String password,
  ) async {
    final url = Uri.parse('http://10.0.2.2:8000/api/token/');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'username': username,
          'password': password,
        }),
      );
      final responseData = json.decode(response.body);
      if (response.statusCode >= 400) {
        throw HttpException(responseData['message']);
      }
      if (response.statusCode == 200) {
        _token = responseData['access'];
        _refreshToken = responseData['refresh'];
        userName = username;

        final prefs = await SharedPreferences.getInstance();
        await prefs.setStringList('items', <String>[
          _token.toString(),
          _refreshToken.toString(),
          userName.toString(),
        ]);
        refreshToken();
        notifyListeners();
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();

    if (!prefs.containsKey('items')) {
      return false;
    }
    final List<String>? extractedUserData = prefs.getStringList('items');
    _token = extractedUserData![0];
    _refreshToken = extractedUserData[1];
    userName = extractedUserData[2];
    refreshToken();
    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    _token = '';
    _refreshToken = '';
    userName = '';
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
    notifyListeners();
  }
}

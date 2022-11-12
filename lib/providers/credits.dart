import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/http_exception.dart';

import '../models/credit.dart';

class Credits with ChangeNotifier {
  List<Credit> _items = [];

  String? authToken;

  Future<void> Function() refreshToken;

  Credits(this.authToken, this.refreshToken, this._items);

  // getter for refreshToken
  Future<void> get getRefreshToken {
    return refreshToken();
  }

  List<Credit> get items {
    return [..._items];
  }

  Credit findById(String id) {
    return _items.firstWhere((credit) => credit.id == id);
  }

  Future<void> fetchAndSetCredits() async {
    var url = Uri.parse('http://10.0.2.2:8000/api/credits/all/');

    try {
      var response = await http.get(url, headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      });

      final extractedData = json.decode(response.body) as List<dynamic>;
      final List<Credit> loadedCredits = [];
      for (var creditData in extractedData) {
        loadedCredits.add(Credit(
          id: creditData['id'].toString(),
          customerName: creditData['customer_name'],
          customerPhone: creditData['phone'],
          amount: creditData['amount'],
          date: DateTime.parse(creditData['date']),
        ));
      }
      _items = loadedCredits;
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> addCredit(Credit credit) async {
    final url = Uri.parse('http://10.0.2.2:8000/api/credits/');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: json.encode({
          'customer_name': credit.customerName,
          'phone': credit.customerPhone,
          'amount': credit.amount,
          'date': credit.date.toIso8601String(),
        }),
      );

      if (response.statusCode == 409) {
        throw HttpException(json.decode(response.body)['message']);
      }

      final newCredit = Credit(
        id: json.decode(response.body)['id'].toString(),
        customerName: credit.customerName,
        customerPhone: credit.customerPhone,
        amount: credit.amount,
        date: credit.date,
      );
      _items.insert(0, newCredit);
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> updateCredit(String id, Credit newCredit) async {
    final creditIndex = _items.indexWhere((credit) => credit.id == id);
    if (creditIndex >= 0) {
      final url = Uri.parse('http://10.0.2.2:8000/api/credits/$id/update/');
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: json.encode({
          'customer_name': newCredit.customerName,
          'phone': newCredit.customerPhone,
          'amount': newCredit.amount,
          'date': newCredit.date.toIso8601String(),
        }),
      );
      if (response.statusCode == 409) {
        throw HttpException(json.decode(response.body)['message']);
      }

      _items[creditIndex] = newCredit;
    } else {
      return;
    }
    notifyListeners();
  }

  Future<void> deleteCredit(String id) async {
    final url = Uri.parse('http://10.0.2.2:8000/api/credits/$id/delete/');
    final existingCreditIndex = _items.indexWhere((credit) => credit.id == id);
    var existingCredit = _items[existingCreditIndex];
    _items.removeAt(existingCreditIndex);
    notifyListeners();
    final response = await http.delete(url, headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $authToken',
    });
    if (response.statusCode >= 400) {
      _items.insert(existingCreditIndex, existingCredit);
      notifyListeners();
      throw HttpException('Could not delete credit.');
    }
  }
}

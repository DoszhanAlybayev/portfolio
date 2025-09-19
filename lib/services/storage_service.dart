import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/stock.dart';

class StorageService {
  static Future<List<Stock>> loadPortfolio() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('portfolio');
    if (jsonString != null && jsonString.isNotEmpty) {
      final List<dynamic> data = jsonDecode(jsonString);
      return data.map((e) => Stock.fromJson(e)).toList();
    }
    return [];
  }

  static Future<void> savePortfolio(List<Stock> portfolio) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(portfolio.map((e) => e.toJson()).toList());
    await prefs.setString('portfolio', jsonString);
  }
}

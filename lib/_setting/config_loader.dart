import 'dart:convert';
import 'package:flutter/services.dart';

class ConfigLoader {
  final String environment;
  static Map<String, dynamic>? _config;

  ConfigLoader({required this.environment});

  Future<void> load() async {
    final configString =
    await rootBundle.loadString('assets/config/${environment}_config.json');
    _config = json.decode(configString);
  }

  static dynamic get(String key) {
    return _config?[key];
  }
}
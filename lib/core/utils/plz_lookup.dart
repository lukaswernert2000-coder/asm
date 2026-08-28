import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

abstract final class PlzLookup {
  static Map<String, dynamic>? _cache;

  static Future<({String city, double lat, double lng})?> resolve(
    String plz,
  ) async {
    final data = await _load();
    final entry = data[plz] as Map<String, dynamic>?;
    if (entry == null) return null;
    return (
      city: entry['o'] as String,
      lat: (entry['lat'] as num).toDouble(),
      lng: (entry['lng'] as num).toDouble(),
    );
  }

  static Future<Map<String, dynamic>> _load() async {
    final cached = _cache;
    if (cached != null) return cached;
    final raw = await rootBundle.loadString('assets/data/plz.json');
    final parsed = jsonDecode(raw) as Map<String, dynamic>;
    _cache = parsed;
    return parsed;
  }
}

import 'dart:convert';

import 'package:http/http.dart' as http;

import '../Models/giveaway_model.dart';

class GiveawayService {
  GiveawayService({http.Client? client}) : _client = client ?? http.Client();

  static final _uri = Uri.parse('https://www.gamerpower.com/api/giveaways');
  final http.Client _client;

  Future<List<Giveaway>> fetchGiveaways() async {
    final response = await _client.get(_uri).timeout(
          const Duration(seconds: 15),
        );

    // GamerPower answers 201 with an object (not a list) when nothing is active.
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to load giveaways (HTTP ${response.statusCode}).');
    }

    final decoded = jsonDecode(utf8.decode(response.bodyBytes));
    if (decoded is! List) return const [];

    return decoded
        .whereType<Map<String, dynamic>>()
        .map(Giveaway.fromJson)
        .where((g) => g.status.isEmpty || g.status.toLowerCase() == 'active')
        .toList();
  }
}

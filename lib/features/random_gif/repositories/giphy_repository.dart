import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/api_constants.dart';
import '../models/gif_model.dart';

class GiphyRepository {
  String? _randomId;

  Future<void> initRandomId() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString('giphy_random_id');
    if (cached != null && cached.isNotEmpty) {
      _randomId = cached;
      return;
    }
    if (giphyApiKey.isEmpty) return;

    final uri = Uri.parse('$giphyBaseUrl/randomid?api_key=$giphyApiKey');
    try {
      final res = await http.get(uri);
      if (res.statusCode == 200) {
        final json = jsonDecode(res.body) as Map<String, dynamic>;
        final id = (json['data']?['random_id'] ?? '') as String;
        if (id.isNotEmpty) {
          _randomId = id;
          await prefs.setString('giphy_random_id', id);
        }
      }
    } catch (_) {
    }
  }

  Future<Gif> fetchRandomGif({required String tag, required String rating}) async {
    if (giphyApiKey.isEmpty) {
      throw Exception('API Key da Giphy não definida.');
    }

    final params = <String, String>{
      'api_key': giphyApiKey,
      if (tag.trim().isNotEmpty) 'tag': tag.trim(),
      if (rating.isNotEmpty) 'rating': rating,
      if (_randomId != null) 'random_id': _randomId!,
    };

    final uri = Uri.https('api.giphy.com', '/v1/gifs/random', params);

    final res = await http.get(uri, headers: {'Accept': 'application/json'});

    if (res.statusCode == 200) {
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      final data = json['data'] as Map<String, dynamic>?;

      if (data == null || data.isEmpty) {
        throw Exception('Nenhum GIF retornado pela API.');
      }
      return Gif.fromJson(data);
    } else {
      throw Exception('Erro ${res.statusCode} ao buscar GIF.');
    }
  }

  Future<void> pingAnalytics(String? url) async {
    if (url == null) return;
    try {
      final uri = Uri.parse(url).replace(queryParameters: {
        ...Uri.parse(url).queryParameters,
        if (_randomId != null) 'random_id': _randomId!,
        'ts': DateTime.now().millisecondsSinceEpoch.toString(),
      });
      await http.get(uri).timeout(const Duration(seconds: 3));
    } catch (_) {
    }
  }
}
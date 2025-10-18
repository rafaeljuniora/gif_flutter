import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/gif_model.dart';
import '../../../core/constants/api_constants.dart';

class GiphyRepository {
  final List<String> _apiKeys = giphyApiKeys;
  late String _currentApiKey;
  int _currentKeyIndex = 0;

  GiphyRepository() {
    if (_apiKeys.isEmpty) {
      throw Exception(
        "Giphy API Keys não foram carregadas ou estão vazias em api_constants.dart",
      );
    }
    _currentApiKey = _apiKeys.first;
  }

  Future<void> initRandomId() async {
    await Future.delayed(const Duration(milliseconds: 10));
  }

  bool _switchToNextKey() {
    if (_apiKeys.isEmpty) return false;

    _currentKeyIndex = (_currentKeyIndex + 1) % _apiKeys.length;
    _currentApiKey = _apiKeys[_currentKeyIndex];

    if (_currentKeyIndex == 0) {
      print(
          'AVISO: Todas as ${_apiKeys.length} chaves API falharam. Tente novamente mais tarde.');
      return false;
    }

    print('Chave API trocada para índice $_currentKeyIndex. Tentando novamente...');
    return true;
  }

  void pingAnalytics(String? url) {
    if (url == null) return;
  }

  Future<Gif?> fetchRandomGif({String? tag, String? rating}) async {
    const maxAttempts = 3;
    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      final params = {
        'api_key': _currentApiKey,
        'rating': rating ?? 'g',
      };
      if (tag != null && tag.trim().isNotEmpty) params['tag'] = tag;

      final uri = Uri.https('api.giphy.com', '/v1/gifs/random', params);
      try {
        final res = await http.get(uri, headers: {'Accept': 'application/json'});
        if (res.statusCode == 200) {
          final data = jsonDecode(res.body)['data'] as Map<String, dynamic>?;
          if (data == null) return null;
          final gif = Gif.fromJson(data);
          return gif.hasValidUrl ? gif : null;
        } else if (res.statusCode == 429 || res.statusCode == 401) {
          if (_switchToNextKey()) continue;
          throw Exception('Erro ${res.statusCode}: todas as chaves falharam.');
        } else {
          throw Exception('Erro ${res.statusCode}: ${res.body}');
        }
      } catch (e) {
        if (attempt == maxAttempts - 1) rethrow;
        if (_switchToNextKey()) continue;
      }
    }
    return null;
  }

  Future<List<Gif>> fetchGifs({
    required String tag,
    required String rating,
    required int limit,
    required int offset,
  }) async {
    const maxAttempts = 3;
    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      final endpoint = tag.isEmpty || tag == 'em alta'
          ? '/v1/gifs/trending'
          : '/v1/gifs/search';
      final params = {
        'api_key': _currentApiKey,
        'rating': rating,
        'limit': limit.toString(),
        'offset': offset.toString(),
        if (tag.isNotEmpty && tag != 'em alta') 'q': tag,
      };
      final uri = Uri.https('api.giphy.com', endpoint, params);
      try {
        final res = await http.get(uri, headers: {'Accept': 'application/json'});
        if (res.statusCode == 200) {
          final List data = jsonDecode(res.body)['data'];
          return data
              .map((e) => Gif.fromJson(e))
              .where((g) => g.hasValidUrl)
              .toList();
        } else if (res.statusCode == 429 || res.statusCode == 401) {
          if (_switchToNextKey()) continue;
          throw Exception('Erro ${res.statusCode}: todas as chaves falharam.');
        } else {
          throw Exception('Erro ${res.statusCode}: ${res.body}');
        }
      } catch (e) {
        if (attempt == maxAttempts - 1) rethrow;
        if (_switchToNextKey()) continue;
      }
    }
    return [];
  }
}

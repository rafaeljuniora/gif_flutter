import 'dart:async'; // <- novo
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

const _giphyApiKey = 'ZmQjBKeltbRmRkTtDqwSP7bI5xfEvIjp'; // ideal: passe por --dart-define
const _baseUrl = 'https://api.giphy.com/v1';
const Duration _interval = Duration(seconds: 7); // <- novo (7 segundos)

void main() {
  runApp(const GiphyRandomApp());
}

class GiphyRandomApp extends StatelessWidget {
  const GiphyRandomApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Buscador aleatório de GIF 2.0',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const RandomGifPage(),
    );
  }
}

class RandomGifPage extends StatefulWidget {
  const RandomGifPage({super.key});

  @override
  State<RandomGifPage> createState() => _RandomGifPageState();
}

class _RandomGifPageState extends State<RandomGifPage> {
  String? _randomId;
  String? _gifUrl;
  String? _gifTitle;
  String? _analyticsOnLoad;
  String? _analyticsOnClick;

  final _tagController = TextEditingController(text: '');
  String _rating = 'g';
  bool _loading = false;
  bool _trackedOnLoad = false;

  // ---- auto-shuffle ----
  Timer? _timer;           // <- novo
  bool _autoShuffle = true; // <- novo

  @override
  void initState() {
    super.initState();
    _initRandomId().then((_) {
      _fetchRandom();
      _startAutoShuffle(); // <- inicia o ciclo de 7s
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // <- importante cancelar
    _tagController.dispose();
    super.dispose();
  }

  void _startAutoShuffle() {
    _timer?.cancel();
    if (!_autoShuffle) return;
    _timer = Timer.periodic(_interval, (_) {
      if (!_loading) _fetchRandom(); // evita sobreposição de chamadas
    });
  }

  Future<void> _initRandomId() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString('giphy_random_id');
    if (cached != null && cached.isNotEmpty) {
      _randomId = cached;
      return;
    }
    if (_giphyApiKey.isEmpty) return; // evita chamada sem api key

    final uri = Uri.parse('$_baseUrl/randomid?api_key=$_giphyApiKey');
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
      // segue sem random_id se falhar
    }
  }

  Future<void> _fetchRandom() async {
    if (_giphyApiKey.isEmpty) {
      _snack('Defina GIPHY_API_KEY com --dart-define.');
      return;
    }
    setState(() {
      _loading = true;
      _trackedOnLoad = false;
    });

    final params = <String, String>{
      'api_key': _giphyApiKey,
      if (_tagController.text.trim().isNotEmpty) 'tag': _tagController.text.trim(),
      if (_rating.isNotEmpty) 'rating': _rating,
      if (_randomId != null) 'random_id': _randomId!,
    };

    final uri = Uri.https('api.giphy.com', '/v1/gifs/random', params);

    try {
      final res = await http.get(uri, headers: {'Accept': 'application/json'});
      if (res.statusCode == 200) {
        final json = jsonDecode(res.body) as Map<String, dynamic>;
        final data = json['data'] as Map<String, dynamic>?;

        if (data == null || data.isEmpty) {
          _snack('Nenhum GIF retornado.');
        } else {
          final images = (data['images'] ?? {}) as Map<String, dynamic>;
          final downsized = images['downsized_medium'] as Map<String, dynamic>?;
          final original = images['original'] as Map<String, dynamic>?;
          final url = (downsized?['url'] ?? original?['url']) as String?;

          final analytics = (data['analytics'] ?? {}) as Map<String, dynamic>;
          final onload = (analytics['onload']?['url']) as String?;
          final onclick = (analytics['onclick']?['url']) as String?;

          setState(() {
            _gifUrl = url;
            _gifTitle = (data['title'] ?? 'Random GIF') as String?;
            _analyticsOnLoad = onload;
            _analyticsOnClick = onclick;
          });
        }
      } else {
        _snack('Erro ${res.statusCode} ao buscar GIF.');
      }
    } catch (e) {
      _snack('Falha de rede: $e');
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _ping(String? url) async {
    if (url == null) return;
    try {
      final uri = Uri.parse(url).replace(queryParameters: {
        ...Uri.parse(url).queryParameters,
        if (_randomId != null) 'random_id': _randomId!,
        'ts': DateTime.now().millisecondsSinceEpoch.toString(),
      });
      await http.get(uri).timeout(const Duration(seconds: 3));
    } catch (_) {
      // silencioso: analytics ping é "fire-and-forget"
    }
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final canFetch = !_loading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscador de GIF 2.0 ()'),
        actions: [
          IconButton(
            tooltip: _autoShuffle ? 'Pausar auto (7s)' : 'Retomar auto (7s)',
            icon: Icon(_autoShuffle ? Icons.pause : Icons.play_arrow),
            onPressed: () {
              setState(() => _autoShuffle = !_autoShuffle);
              if (_autoShuffle) {
                _startAutoShuffle();
              } else {
                _timer?.cancel();
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Filtros
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _tagController,
                      decoration: const InputDecoration(
                        labelText: 'Procurar por TAG',
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (_) => _fetchRandom(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  DropdownButton<String>(
                    value: _rating,
                    onChanged: (v) {
                      setState(() => _rating = v ?? 'g');
                      // reinicia o timer para aplicar imediatamente com o mesmo ritmo
                      if (_autoShuffle) _startAutoShuffle();
                    },
                    items: const [
                      DropdownMenuItem(value: 'g', child: Text('G')),
                      DropdownMenuItem(value: 'pg', child: Text('PG')),
                      DropdownMenuItem(value: 'pg-13', child: Text('PG-13')),
                      DropdownMenuItem(value: 'r', child: Text('R')),
                    ],
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: canFetch ? _fetchRandom : null,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Novo GIF'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 6),

            // Área do GIF
            Expanded(
              child: Center(
                child: _loading
                    ? const CircularProgressIndicator()
                    : (_gifUrl == null)
                        ? const Text('Toque em "Novo GIF" ou aguarde o auto-shuffle (7s).')
                        : GestureDetector(
                            onTap: () => _ping(_analyticsOnClick),
                            child: _GifWithOnloadPing(
                              url: _gifUrl!,
                              onFirstFrame: () {
                                if (!_trackedOnLoad) {
                                  _trackedOnLoad = true;
                                  _ping(_analyticsOnLoad);
                                }
                              },
                            ),
                          ),
              ),
            ),

            if (_gifTitle?.isNotEmpty == true)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  _gifTitle!,
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _GifWithOnloadPing extends StatelessWidget {
  const _GifWithOnloadPing({
    required this.url,
    required this.onFirstFrame,
  });

  final String url;
  final VoidCallback onFirstFrame;

  @override
  Widget build(BuildContext context) {
    bool fired = false;
    return Image.network(
      url,
      fit: BoxFit.contain,
      gaplessPlayback: true,
      // Dispara o ping de "onload" quando a primeira frame chegar
      frameBuilder: (context, child, frame, wasSync) {
        if (frame != null && !fired) {
          fired = true;
          WidgetsBinding.instance.addPostFrameCallback((_) => onFirstFrame());
        }
        return child;
      },
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return const SizedBox(
          width: 64,
          height: 64,
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}

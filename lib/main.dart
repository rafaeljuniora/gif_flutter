import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gifador da Aula',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white10),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Exibidor de GIF 1.0'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<String> _gifAssets = <String>[];
  int _index = 0;

  static const Duration _interval = Duration(seconds: 10);
  Timer? _timer;
  bool _manifestLoaded = false;

  String get _currentAsset {
    if (_gifAssets.isEmpty) return '';
    final safe = _index % _gifAssets.length;
    return _gifAssets[safe < 0 ? safe + _gifAssets.length : safe];
  }

  void _next() {
    if (_gifAssets.isEmpty) return;
    setState(() => _index = (_index + 1) % _gifAssets.length);
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(_interval, (_) => _next());
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _loadAssetsFromManifest() async {
    final manifestJson = await DefaultAssetBundle.of(context).loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap = json.decode(manifestJson) as Map<String, dynamic>;

    final gifs = manifestMap.keys
        .where((k) =>
            k.startsWith('assets/gifs/') &&
            (k.toLowerCase().endsWith('.gif')))
        .toList()
      ..sort();

    setState(() {
      _gifAssets = gifs;
      _index = 0;
    });

    for (final a in gifs) {
      await precacheImage(AssetImage(a), context);
    }

    if (gifs.isNotEmpty) {
      _startTimer();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_manifestLoaded) {
      _manifestLoaded = true;
      _loadAssetsFromManifest();
    }
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asset = _currentAsset;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(
            tooltip: _timer == null ? 'Reproduzir' : 'Pausar',
            icon: Icon(_timer == null ? Icons.play_arrow : Icons.pause),
            onPressed: () {
              if (_timer == null) {
                _startTimer();
              } else {
                _stopTimer();
              }
              setState(() {});
            },
          ),
          IconButton(
            tooltip: 'Próximo (pular)',
            icon: const Icon(Icons.skip_next),
            onPressed: _next,
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: AspectRatio(
              aspectRatio: 3 / 4,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: asset.isEmpty
                    ? const ColoredBox(
                        color: Colors.black12,
                        child: Center(
                          child: Text(
                            'Nenhum GIF encontrado em assets/gifs/\n'
                            'Confira o pubspec.yaml e os arquivos.',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    : Image.asset(
                        asset,
                        key: ValueKey(asset),
                        fit: BoxFit.cover, 
                        gaplessPlayback: true,
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.black12,
                          alignment: Alignment.center,
                          child: const Text(
                            'Asset não encontrado.\nConfira pubspec.yaml e o caminho do arquivo.',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
              ),
            ),
          ),
        ),
      )
      // ,
      // floatingActionButton: FloatingActionButton.extended(
      //   onPressed: _next,
      //   icon: const Icon(Icons.shuffle),
      //   label: const Text('Trocar agora'),
      // ),
    );
  }
}

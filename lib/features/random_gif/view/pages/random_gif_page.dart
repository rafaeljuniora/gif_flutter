import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../controllers/random_gif_controller.dart';
import '../../repositories/giphy_repository.dart';
import '../widgets/filter_controls.dart';
import '../widgets/gif_display.dart';
import '../../models/gif_model.dart';

enum GifView { grid, single }

class RandomGifPage extends StatefulWidget {
  const RandomGifPage({super.key});

  @override
  State<RandomGifPage> createState() => _RandomGifPageState();
}

class _RandomGifPageState extends State<RandomGifPage> {
  late final RandomGifController _controller;
  late final ScrollController _scrollController;
  GifView _currentView = GifView.grid;
  final List<Gif> _favorites = [];

  @override
  void initState() {
    super.initState();
    _controller = RandomGifController(GiphyRepository());
    _controller.initialize();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    _controller.fetchGifs(isInitial: true);

    loadFavorites().then((saved) {
      setState(() => _favorites.addAll(saved));
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        _controller.canLoadMore) {
      _controller.fetchGifs(isLoadMore: true);
    }
  }


  void _toggleFavorite(Gif gif) async {
    setState(() {
      if (_favorites.any((f) => f.url == gif.url)) {
        _favorites.removeWhere((f) => f.url == gif.url);
      } else {
        _favorites.add(gif);
      }
    });
    await saveFavorites();
  }

  Future<void> saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favsJson =
        _favorites.map((gif) => json.encode(gif.toJson())).toList();
    await prefs.setStringList('favorites', favsJson);
  }

  Future<List<Gif>> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favsJson = prefs.getStringList('favorites') ?? [];
    final List<Gif> favorites = [];

    for (var jsonStr in favsJson) {
      try {
        final map = json.decode(jsonStr);
        if (map is Map) {
          favorites.add(Gif.fromJson(Map<String, dynamic>.from(map)));
        }
      } catch (_) {}
    }
    return favorites;
  }

  void _openFavorites() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FavoritesPage(
          favorites: _favorites,
          onFavoriteToggle: _toggleFavorite,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GIF Finder'),
        actions: [
          ElevatedButton.icon(
            onPressed: _openFavorites,
            icon: const Icon(Icons.favorite, color: Colors.white),
            label: const Text(
              'Favoritos',
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B5CF6),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Column(
              children: [
                _buildHeader(context),
                _buildViewToggle(),
                FilterControls(
                  tagController: _controller.tagController,
                  rating: _controller.rating,
                  enabled: _controller.state != ScreenState.loading,
                  onRatingChanged: (newRating) {
                    _controller.onRatingChanged(newRating);
                    if (_currentView == GifView.single)
                      _controller.fetchSingleGif();
                  },
                  onFetch: () {
                    if (_currentView == GifView.grid)
                      _controller.fetchGifs(isInitial: true);
                    else
                      _controller.fetchSingleGif();
                  },
                ),
                _buildPopularTags(context),
                if (_currentView == GifView.grid) _buildResultsSection(context),
                Expanded(child: _buildBody()),
                if (_currentView == GifView.single)
                  _buildAutoShuffleControls(context),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildViewToggle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildToggleButton(
            icon: Icons.grid_view_rounded,
            label: 'Exploração (Grid)',
            view: GifView.grid,
          ),
          const SizedBox(width: 16),
          _buildToggleButton(
            icon: Icons.shuffle,
            label: 'Aleatório (Single)',
            view: GifView.single,
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton({
    required IconData icon,
    required String label,
    required GifView view,
  }) {
    final isSelected = _currentView == view;
    final color = isSelected ? const Color(0xFF8B5CF6) : const Color(0xFF9CA3AF);
    return InkWell(
      onTap: () {
        setState(() {
          _currentView = view;
          if (view == GifView.single) {
            _controller.toggleAutoShuffle();
            _controller.fetchSingleGif();
          } else {
            _controller.setAutoShuffle(false);
          }
        });
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() =>
      _currentView == GifView.grid ? _buildGridBody() : _buildSingleBody();

  Widget _buildSingleBody() {
    if (_controller.state == ScreenState.loading && _controller.singleGif == null)
      return const Center(child: CircularProgressIndicator());

    if (_controller.state == ScreenState.error)
      return Center(child: Text('Ocorreu um erro: ${_controller.errorMessage}'));

    final gif = _controller.singleGif;
    if (gif == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Toque no botão de Play para começar o Auto-Load, ou no botão Shuffle abaixo para gerar um GIF aleatório.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            IconButton(
              icon: const Icon(
                Icons.refresh,
                color: Color(0xFF8B5CF6),
                size: 32,
              ),
              onPressed: _controller.fetchSingleGif,
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: GifDisplay(
          gif: gif,
          onTap: () => _controller.ping(gif.analyticsOnClickUrl),
          onFirstFrame: () {},
          isFavorite: _favorites.any((f) => f.url == gif.url),
          onFavoriteToggle: () => _toggleFavorite(gif),
        ),
      ),
    );
  }

  Widget _buildGridBody() {
    if (_controller.state == ScreenState.loading && _controller.gifs.isEmpty)
      return const Center(child: CircularProgressIndicator());

    if (_controller.state == ScreenState.error && _controller.gifs.isEmpty)
      return Center(child: Text('Ocorreu um erro: ${_controller.errorMessage}'));

    if (_controller.gifs.isEmpty)
      return Center(
        child: Text(
          _controller.tagController.text.isEmpty
              ? 'Toque em "Buscar" ou selecione uma tag para começar.'
              : 'Nenhum GIF encontrado para "${_controller.tagController.text}".',
        ),
      );

    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(12),
      itemCount: _controller.gifs.length + (_controller.canLoadMore ? 1 : 0),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (context, index) {
        if (index == _controller.gifs.length) {
          return Center(
            child: _controller.state == ScreenState.loading
                ? const CircularProgressIndicator()
                : const Text('Fim dos resultados.'),
          );
        }
        final gif = _controller.gifs[index];
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: GifDisplay(
            gif: gif,
            onTap: () => _controller.ping(gif.analyticsOnClickUrl),
            onFirstFrame: () {},
            isFavorite: _favorites.any((f) => f.url == gif.url),
            onFavoriteToggle: () => _toggleFavorite(gif),
          ),
        );
      },
    );
  }

  Widget _buildAutoShuffleControls(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            tooltip: _controller.autoShuffle ? 'Pausar auto-load' : 'Retomar auto-load',
            icon: Icon(
              _controller.autoShuffle ? Icons.pause : Icons.play_arrow,
              color: const Color(0xFF8B5CF6),
            ),
            onPressed: _controller.toggleAutoShuffle,
          ),
          const SizedBox(width: 8),
          Text(
            _controller.autoShuffle ? 'Auto-load ativo' : 'Auto-load pausado',
            style: const TextStyle(color: Color(0xFF6B7280), fontSize: 14),
          ),
          const SizedBox(width: 16),
          IconButton(
            icon: const Icon(Icons.skip_next, color: Color(0xFF8B5CF6)),
            onPressed: _controller.fetchSingleGif,
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
              ),
            ),
            child: const Icon(Icons.auto_awesome, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'GIF Finder',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF374151),
                    ),
              ),
              Text(
                'Encontre os melhores GIFs',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: const Color(0xFF9CA3AF)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPopularTags(BuildContext context) {
    const List<String> tags = [
      'gatinho',
      'festa',
      'dança',
      'engraçado',
      'amor',
      'reação',
      'celebração',
      'anime',
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          Text(
            'Tags Populares',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF374151),
                ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: tags.map((tag) => _buildTagButton(context, tag)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTagButton(BuildContext context, String tag) {
    final isSelected = _controller.tagController.text == tag;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected ? const Color(0xFF8B5CF6) : const Color(0xFFE5E7EB),
          width: 1,
        ),
        color: isSelected ? const Color(0xFFF3F4F6) : Colors.white,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            _controller.tagController.text = tag;
            if (_currentView == GifView.grid)
              _controller.fetchGifs(isInitial: true);
            else
              _controller.fetchSingleGif();
          },
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              tag,
              style: TextStyle(
                color: isSelected ? const Color(0xFF8B5CF6) : const Color(0xFF374151),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultsSection(BuildContext context) {
    final searchTerm =
        _controller.tagController.text.isEmpty ? 'em alta' : _controller.tagController.text;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Resultados para "$searchTerm"',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF374151),
                ),
          ),
          Text(
            '${_controller.gifs.length} GIFs',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: const Color(0xFF9CA3AF)),
          ),
        ],
      ),
    );
  }
}


class FavoritesPage extends StatelessWidget {
  final List<Gif> favorites;
  final void Function(Gif) onFavoriteToggle;

  const FavoritesPage({super.key, required this.favorites, required this.onFavoriteToggle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favoritos')),
      body: favorites.isEmpty
          ? const Center(child: Text('Nenhum GIF favoritado.'))
          : GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final gif = favorites[index];
                return ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: GifDisplay(
                    gif: gif,
                    onTap: () {},
                    onFirstFrame: () {},
                    isFavorite: true,
                    onFavoriteToggle: () => onFavoriteToggle(gif),
                  ),
                );
              },
            ),
    );
  }
}

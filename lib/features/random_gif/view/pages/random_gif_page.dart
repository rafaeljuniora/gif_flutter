import 'package:flutter/material.dart';

import '../../controllers/random_gif_controller.dart';
import '../../repositories/giphy_repository.dart';
import '../widgets/filter_controls.dart';
import '../widgets/gif_display.dart';

class RandomGifPage extends StatefulWidget {
  const RandomGifPage({super.key});

  @override
  State<RandomGifPage> createState() => _RandomGifPageState();
}

class _RandomGifPageState extends State<RandomGifPage> {
  late final RandomGifController _controller;

  @override
  void initState() {
    super.initState();
    _controller = RandomGifController(GiphyRepository());
    _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Column(
              children: [
                _buildHeader(context),
                FilterControls(
                  tagController: _controller.tagController,
                  rating: _controller.rating,
                  enabled: _controller.state != ScreenState.loading,
                  onRatingChanged: _controller.onRatingChanged,
                  onFetch: _controller.fetchRandomGif,
                ),
                _buildPopularTags(context),
                _buildResultsSection(context),
                Expanded(child: Center(child: _buildBody())),
                _buildAutoShuffleControls(context),
              ],
            );
          },
        ),
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
                colors: [
                  Color(0xFF8B5CF6),
                  Color(0xFFEC4899),
                ],
              ),
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 24,
            ),
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
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF9CA3AF),
                ),
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
            _controller.fetchRandomGif();
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
    final searchTerm = _controller.tagController.text.isEmpty 
        ? 'aleatório' 
        : _controller.tagController.text;
    
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
            '1 GIF',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF9CA3AF),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAutoShuffleControls(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            tooltip: _controller.autoShuffle
                ? 'Pausar auto'
                : 'Retomar auto',
            icon: Icon(
              _controller.autoShuffle ? Icons.pause : Icons.play_arrow,
              color: const Color(0xFF8B5CF6),
            ),
            onPressed: _controller.toggleAutoShuffle,
          ),
          const SizedBox(width: 8),
          Text(
            _controller.autoShuffle ? 'Auto ativo' : 'Auto pausado',
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    bool trackedOnLoad = false;
    switch (_controller.state) {
      case ScreenState.loading:
        return const CircularProgressIndicator();
      case ScreenState.error:
        return Text('Ocorreu um erro: ${_controller.errorMessage}');
      case ScreenState.success:
        final gif = _controller.gif;
        if (gif == null) {
          return const Text('Nenhum GIF encontrado.');
        }
        return GifDisplay(
          gif: gif,
          onTap: () => _controller.ping(gif.analyticsOnClickUrl),
          onFirstFrame: () {
            if (!trackedOnLoad) {
              trackedOnLoad = true;
              _controller.ping(gif.analyticsOnLoadUrl);
            }
          },
        );
      case ScreenState.idle:
      default:
        return const Text('Toque em "Buscar" ou selecione uma tag.');
    }
  }
}

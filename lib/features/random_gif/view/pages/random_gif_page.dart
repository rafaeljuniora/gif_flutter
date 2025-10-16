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
      appBar: AppBar(
        title: const Text('Buscador de GIF 3.0'),
        actions: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return IconButton(
                tooltip: _controller.autoShuffle
                    ? 'Pausar auto'
                    : 'Retomar auto',
                icon: Icon(
                  _controller.autoShuffle ? Icons.pause : Icons.play_arrow,
                ),
                onPressed: _controller.toggleAutoShuffle,
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Column(
              children: [
                FilterControls(
                  tagController: _controller.tagController,
                  rating: _controller.rating,
                  enabled: _controller.state != ScreenState.loading,
                  onRatingChanged: _controller.onRatingChanged,
                  onFetch: _controller.fetchRandomGif,
                ),
                const SizedBox(height: 6),
                Expanded(child: Center(child: _buildBody())),
              ],
            );
          },
        ),
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
        return const Text('Toque em "Novo GIF" ou aguarde o auto-shuffle.');
    }
  }
}

// lib/features/random_gif/view/widgets/gif_display.dart
import 'package:flutter/material.dart';
import '../../models/gif_model.dart';
import '../../controllers/favorites_controller.dart';

class GifDisplay extends StatefulWidget {
  final Gif gif;
  final VoidCallback onFirstFrame;
  final VoidCallback onTap;

  const GifDisplay({
    super.key,
    required this.gif,
    required this.onFirstFrame,
    required this.onTap,
  });

  @override
  State<GifDisplay> createState() => _GifDisplayState();
}

class _GifDisplayState extends State<GifDisplay> {
  final FavoritesController _favoritesController = FavoritesController();
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    _isFavorite = _favoritesController.isFavorite(widget.gif);
  }

  Future<void> _toggleFavorite() async {
    await _favoritesController.toggleFavorite(widget.gif);
    setState(() {
      _isFavorite = !_isFavorite;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Aqui preservamos a estrutura original do seu widget.
    return Card(
      clipBehavior: Clip.hardEdge,
      child: Column(
        children: [
          // Stack para poder posicionar o botão sobre a imagem
          Stack(
            children: [
              // A imagem (mantive Image.network como provavelmente seu original)
              if (widget.gif.url != null)
                Image.network(widget.gif.url!, fit: BoxFit.cover),
              // Ícone de favorito no canto superior direito
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: _toggleFavorite,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(6),
                    child: Icon(
                      _isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: Colors.redAccent,
                      size: 26,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // resto do conteúdo (título, etc.) — mantive seu layout simples
          if (widget.gif.title?.isNotEmpty == true)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                widget.gif.title!,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}

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
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.hardEdge,
      elevation: 6,
      child: InkWell(
        onTap: widget.onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      color: Colors.grey[200],
                      child: widget.gif.url != null
                          ? Image.network(
                              widget.gif.url!,
                              fit: BoxFit.contain,
                              alignment: Alignment.center,
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) {
                                  widget.onFirstFrame();
                                  return child;
                                }
                                return const Center(child: CircularProgressIndicator());
                              },
                            )
                          : const Center(child: Icon(Icons.broken_image, size: 40)),
                    ),
                  ),
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
            ),
            if (widget.gif.title?.isNotEmpty == true)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  widget.gif.title!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

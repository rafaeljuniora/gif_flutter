import 'package:flutter/material.dart';
import '../../models/gif_model.dart';

class GifDisplay extends StatelessWidget {
  final Gif gif;
  final VoidCallback onTap;
  final VoidCallback? onFirstFrame;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;

  const GifDisplay({
    super.key,
    required this.gif,
    required this.onTap,
    this.onFirstFrame,
    this.isFavorite = false,
    this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    if (gif.url == null) return const Center(child: Text('URL indisponível.'));

    bool firedOnFirstFrame = false;

    return Stack(
      children: [
        GestureDetector(
          onTap: onTap,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              gif.url!,
              fit: BoxFit.cover,
              gaplessPlayback: true,
              frameBuilder: (context, child, frame, wasSync) {
                if (frame != null && !firedOnFirstFrame) {
                  firedOnFirstFrame = true;
                  if (onFirstFrame != null) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      onFirstFrame!();
                    });
                  }
                }
                return child;
              },
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return const Center(child: CircularProgressIndicator());
              },
              errorBuilder: (context, error, stackTrace) {
                return Center(
                  child: Icon(Icons.error, color: Colors.grey[400]),
                );
              },
            ),
          ),
        ),
        if (onFavoriteToggle != null)
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: onFavoriteToggle,
              child: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? Colors.red : Colors.white,
                size: 28,
              ),
            ),
          ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

import '../../models/gif_model.dart';

class GifDisplay extends StatelessWidget {
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
  Widget build(BuildContext context) {
    if (gif.url == null) return const Text('URL do GIF indisponível.');

    bool firedOnFirstFrame = false;
    
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Image.network(
              gif.url!,
              fit: BoxFit.contain,
              gaplessPlayback: true,
              frameBuilder: (context, child, frame, wasSync) {
                if (frame != null && !firedOnFirstFrame) {
                  firedOnFirstFrame = true;
                  WidgetsBinding.instance.addPostFrameCallback((_) => onFirstFrame());
                }
                return child;
              },
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
          if (gif.title?.isNotEmpty == true)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                gif.title!,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}
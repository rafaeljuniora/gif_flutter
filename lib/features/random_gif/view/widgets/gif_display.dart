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
    if (gif.url == null) return const Center(child: Text('URL indisponível.'));

    bool firedOnFirstFrame = false;

    return Tooltip(
      message: gif.title?.isNotEmpty == true ? gif.title! : 'GIF',
      triggerMode: TooltipTriggerMode.longPress,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        borderRadius: BorderRadius.circular(4),
      ),
      textStyle: const TextStyle(color: Colors.white, fontSize: 14),
      child: GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            gif.url!,
            fit: BoxFit.cover,
            gaplessPlayback: true,
            frameBuilder: (context, child, frame, wasSync) {
              if (frame != null && !firedOnFirstFrame) {
                firedOnFirstFrame = true;
                WidgetsBinding.instance.addPostFrameCallback(
                  (_) => onFirstFrame(),
                );
              }
              return child;
            },
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return const Center(child: CircularProgressIndicator());
            },
            errorBuilder: (context, error, stackTrace) {
              return Center(child: Icon(Icons.error, color: Colors.grey[400]));
            },
          ),
        ),
      ),
    );
  }
}

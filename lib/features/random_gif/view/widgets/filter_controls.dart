import 'package:flutter/material.dart';

class FilterControls extends StatelessWidget {
  final TextEditingController tagController;
  final String rating;
  final bool enabled;
  final ValueChanged<String?> onRatingChanged;
  final VoidCallback onFetch;
  
  const FilterControls({
    super.key,
    required this.tagController,
    required this.rating,
    required this.enabled,
    required this.onRatingChanged,
    required this.onFetch,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: tagController,
              decoration: const InputDecoration(
                labelText: 'Procurar por TAG',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => onFetch(),
            ),
          ),
          const SizedBox(width: 8),
          DropdownButton<String>(
            value: rating,
            onChanged: onRatingChanged,
            items: const [
              DropdownMenuItem(value: 'g', child: Text('G')),
              DropdownMenuItem(value: 'pg', child: Text('PG')),
              DropdownMenuItem(value: 'pg-13', child: Text('PG-13')),
              DropdownMenuItem(value: 'r', child: Text('R')),
            ],
          ),
          const SizedBox(width: 8),
          FilledButton.icon(
            onPressed: enabled ? onFetch : null,
            icon: const Icon(Icons.refresh),
            label: const Text('Novo GIF'),
          ),
        ],
      ),
    );
  }
}
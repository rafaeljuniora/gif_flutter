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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Center(
        child: SizedBox(
          width: 600,
          child: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFF8F9FA),
                        Color(0xFFE9ECEF),
                      ],
                    ),
                  ),
                  child: TextField(
                    controller: tagController,
                    enabled: enabled,
                    decoration: InputDecoration(
                      hintText: 'engraçado',
                      hintStyle: const TextStyle(
                        color: Color(0xFF9CA3AF),
                        fontSize: 16,
                      ),
                      prefixIcon: Container(
                        margin: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Color(0xFF8B5CF6),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.search,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.transparent,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 18,
                      ),
                    ),
                    onSubmitted: (_) => onFetch(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF8B5CF6),
                      Color(0xFFEC4899),
                    ],
                  ),
                ),
                child: ElevatedButton.icon(
                  onPressed: enabled ? onFetch : null,
                  icon: const Icon(
                    Icons.auto_awesome,
                    color: Colors.white,
                    size: 16,
                  ),
                  label: const Text(
                    'Buscar',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
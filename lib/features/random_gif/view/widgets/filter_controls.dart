import 'dart:async';
import 'package:flutter/material.dart';

class FilterControls extends StatefulWidget {
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
  State<FilterControls> createState() => _FilterControlsState();
}

class _FilterControlsState extends State<FilterControls> {
  Timer? _debounce;

  final FocusNode _focusNode = FocusNode();

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 750), () {
      widget.onFetch();
    });
  }

  void _onSearchSubmitted(String _) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    widget.onFetch();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _focusNode.dispose();
    super.dispose();
  }

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
                      colors: [Color(0xFFF8F9FA), Color(0xFFE9ECEF)],
                    ),
                  ),
                  child: TextField(
                    controller: widget.tagController,
                    enabled:
                        true,
                    focusNode: _focusNode,
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
                    onChanged: _onSearchChanged,
                    onSubmitted: _onSearchSubmitted,
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
                    colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                  ),
                ),
                child: ElevatedButton.icon(
                  onPressed: widget.enabled
                      ? widget.onFetch
                      : null,
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
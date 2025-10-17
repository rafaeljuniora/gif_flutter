// lib/features/favorites/controllers/favorites_controller.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../random_gif/models/gif_model.dart';

class FavoritesController {
  FavoritesController._privateConstructor();
  static final FavoritesController _instance = FavoritesController._privateConstructor();
  factory FavoritesController() => _instance;

  final String _prefsKey = 'favorites_gifs_v1';
  final List<Gif> _favorites = [];

  /// Inicializar lendo SharedPreferences
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_prefsKey) ?? [];
    _favorites.clear();
    for (final s in list) {
      try {
        final m = jsonDecode(s) as Map<String, dynamic>;
        _favorites.add(Gif.fromMap(Map<String, dynamic>.from(m)));
      } catch (_) {
        // ignorar item corrompido
      }
    }
  }

  /// Lista imutável de favoritos
  List<Gif> getAll() => List.unmodifiable(_favorites);

  /// Verifica se está favoritado (por id/url)
  bool isFavorite(Gif gif) {
    if (gif.id == null) return false;
    return _favorites.any((g) => g.id == gif.id);
  }

  /// Alterna: se existir remove, senão adiciona (persiste)
  Future<void> toggleFavorite(Gif gif) async {
    final prefs = await SharedPreferences.getInstance();
    if (gif.id == null) return;

    final exists = _favorites.any((g) => g.id == gif.id);
    if (exists) {
      _favorites.removeWhere((g) => g.id == gif.id);
    } else {
      _favorites.add(gif);
    }

    final serialized = _favorites.map((g) => jsonEncode(g.toMap())).toList();
    await prefs.setStringList(_prefsKey, serialized);
  }
}

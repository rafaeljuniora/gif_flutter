import 'package:aula04/features/random_gif/controllers/favorites_controller.dart';
import 'package:flutter/material.dart';
import 'app_widget.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FavoritesController().init(); // inicializa favoritos
  runApp(const GiphyRandomApp());
}
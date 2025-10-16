import 'package:flutter/material.dart';
import 'features/random_gif/view/pages/random_gif_page.dart';

class GiphyRandomApp extends StatelessWidget {
  const GiphyRandomApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Buscador aleatório de GIF 3.0',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const RandomGifPage(),
    );
  }
}
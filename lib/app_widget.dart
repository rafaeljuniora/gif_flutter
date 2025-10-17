import 'package:flutter/material.dart';
import 'features/random_gif/view/pages/random_gif_page.dart';

class GiphyRandomApp extends StatelessWidget {
  const GiphyRandomApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GIF Finder',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8B5CF6),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFFAFAFA),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
      ),
      home: const RandomGifPage(),
    );
  }
}
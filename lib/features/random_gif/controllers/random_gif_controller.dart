import 'dart:async';
import 'package:flutter/material.dart';

import '../../../core/constants/api_constants.dart';
import '../models/gif_model.dart';
import '../repositories/giphy_repository.dart';

enum ScreenState { idle, loading, success, error }

class RandomGifController extends ChangeNotifier {
  final GiphyRepository _repository;

  RandomGifController(this._repository);

  ScreenState _state = ScreenState.idle;
  ScreenState get state => _state;

  Gif? _gif;
  Gif? get gif => _gif;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  bool _autoShuffle = true;
  bool get autoShuffle => _autoShuffle;

  Timer? _timer;

  final tagController = TextEditingController(text: '');
  String rating = 'g';

  Future<void> initialize() async {
    await _repository.initRandomId();
    await fetchRandomGif();
    _startAutoShuffle();
  }

  Future<void> fetchRandomGif() async {
    if (_state == ScreenState.loading) return;

    _state = ScreenState.loading;
    notifyListeners();

    try {
      final newGif = await _repository.fetchRandomGif(
        tag: tagController.text,
        rating: rating,
      );
      _gif = newGif;
      _state = ScreenState.success;
    } catch (e) {
      _errorMessage = e.toString();
      _state = ScreenState.error;
    }
    notifyListeners();
  }

  void onRatingChanged(String? newRating) {
    rating = newRating ?? 'g';
    notifyListeners();
    if (_autoShuffle) {
      fetchRandomGif();
      _startAutoShuffle();
    }
  }
  
  void toggleAutoShuffle() {
    _autoShuffle = !_autoShuffle;
    if (_autoShuffle) {
      _startAutoShuffle();
    } else {
      _timer?.cancel();
    }
    notifyListeners();
  }

  void _startAutoShuffle() {
    _timer?.cancel();
    if (!_autoShuffle) return;
    _timer = Timer.periodic(autoShuffleInterval, (_) => fetchRandomGif());
  }
  
  void ping(String? url) {
    _repository.pingAnalytics(url);
  }

  @override
  void dispose() {
    _timer?.cancel();
    tagController.dispose();
    super.dispose();
  }
}
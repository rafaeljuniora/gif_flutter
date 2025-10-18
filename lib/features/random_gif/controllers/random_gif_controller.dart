import 'dart:async';
import 'package:flutter/material.dart';
import '../models/gif_model.dart';
import '../repositories/giphy_repository.dart';

const autoShuffleInterval = Duration(seconds: 3);

enum ScreenState { idle, loading, success, error }

class RandomGifController extends ChangeNotifier {
  final GiphyRepository _repository;

  RandomGifController(this._repository);

  ScreenState _state = ScreenState.idle;
  ScreenState get state => _state;

  List<Gif> _gifs = [];
  List<Gif> get gifs => _gifs;

  Gif? _singleGif;
  Gif? get singleGif => _singleGif;

  int _offset = 0;
  final int _limit = 25;
  bool _canLoadMore = true;
  bool get canLoadMore => _canLoadMore;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  bool _autoShuffle = false;
  bool get autoShuffle => _autoShuffle;

  Timer? _timer;

  final tagController = TextEditingController(text: '');
  String rating = 'g';

  Future<void> initialize() async {
    await _repository.initRandomId();
  }

  Future<void> fetchSingleGif({String? tag, String? rating}) async {
    if (_state == ScreenState.loading) return;
    _state = ScreenState.loading;
    _errorMessage = '';
    notifyListeners();
    try {
      final newGif = await _repository.fetchRandomGif(
        tag: tag ?? tagController.text,
        rating: rating ?? this.rating,
      );
      _singleGif = newGif;
      _state = ScreenState.success;
    } catch (e) {
      _errorMessage = e.toString();
      _state = ScreenState.error;
    }
    notifyListeners();
  }

  Future<void> fetchGifs({bool isInitial = false, bool isLoadMore = false}) async {
    if (_state == ScreenState.loading && !isLoadMore) return;
    if (isLoadMore && !_canLoadMore) return;

    if (isInitial || !isLoadMore) {
      _gifs = [];
      _offset = 0;
      _canLoadMore = true;
      _state = ScreenState.loading;
    } else if (_gifs.isEmpty) {
      _state = ScreenState.loading;
    }

    if (!isLoadMore) notifyListeners();

    try {
      final newGifs = await _repository.fetchGifs(
        tag: tagController.text,
        rating: rating,
        limit: _limit,
        offset: _offset,
      );
      _gifs.addAll(newGifs);
      _offset += _limit;
      _canLoadMore = newGifs.length == _limit;
      _state = _gifs.isEmpty ? ScreenState.idle : ScreenState.success;
    } catch (e) {
      _errorMessage = e.toString();
      _state = ScreenState.error;
    }
    notifyListeners();
  }

  void onRatingChanged(String? newRating) {
    rating = newRating ?? 'g';
    notifyListeners();
  }

  void toggleAutoShuffle() {
    setAutoShuffle(!_autoShuffle);
  }

  void setAutoShuffle(bool value) {
    if (_autoShuffle == value) return;
    _autoShuffle = value;
    _timer?.cancel();
    if (value) {
      _timer = Timer.periodic(autoShuffleInterval, (_) {
        if (_state != ScreenState.loading) fetchSingleGif();
      });
      if (_singleGif == null) fetchSingleGif();
    }
    notifyListeners();
  }

  void ping(String? url) => _repository.pingAnalytics(url);

  @override
  void dispose() {
    _timer?.cancel();
    tagController.dispose();
    super.dispose();
  }
}

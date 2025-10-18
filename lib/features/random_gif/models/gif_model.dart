class Gif {
  final dynamic url;
  final dynamic title;
  final dynamic analyticsOnLoadUrl;
  final dynamic analyticsOnClickUrl;

  Gif({
    this.url,
    this.title,
    this.analyticsOnLoadUrl,
    this.analyticsOnClickUrl,
  });

  factory Gif.fromJson(Map<dynamic, dynamic> json) {
    final images = (json['images'] ?? {}) as Map<dynamic, dynamic>;

    final possibleUrls = [
      images['downsized_medium']?['url'],
      images['downsized']?['url'],
      images['original']?['url'],
      images['fixed_height']?['url'],
    ];

    final url = possibleUrls.firstWhere((u) => u != null, orElse: () => null);

    final analytics = (json['analytics'] ?? {}) as Map<dynamic, dynamic>;
    final onload = analytics['onload']?['url'];
    final onclick = analytics['onclick']?['url'];

    return Gif(
      url: url,
      title: json['title'] ?? 'Random GIF',
      analyticsOnLoadUrl: onload,
      analyticsOnClickUrl: onclick,
    );
  }

  Map<dynamic, dynamic> toJson() {
    return {
      'url': url,
      'title': title,
      'analyticsOnLoadUrl': analyticsOnLoadUrl,
      'analyticsOnClickUrl': analyticsOnClickUrl,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Gif && runtimeType == other.runtimeType && url == other.url;

  @override
  int get hashCode => url.hashCode;
}

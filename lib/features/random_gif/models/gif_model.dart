class Gif {
  final String? url;
  final String? title;
  final String? analyticsOnLoadUrl;
  final String? analyticsOnClickUrl;

  Gif({
    this.url,
    this.title,
    this.analyticsOnLoadUrl,
    this.analyticsOnClickUrl,
  });

  factory Gif.fromJson(Map<dynamic, dynamic> json) {
    final images = (json['images'] ?? {}) as Map<dynamic, dynamic>;
    final downsized = images['downsized_medium'] as Map<dynamic, dynamic>?;
    final original = images['original'] as Map<dynamic, dynamic>?;
    final url = (downsized?['url'] ?? original?['url']) as dynamic?;

    final analytics = (json['analytics'] ?? {}) as Map<dynamic, dynamic>;
    final onload = (analytics['onload']?['url']) as String?;
    final onclick = (analytics['onclick']?['url']) as String?;

    return Gif(
      url: url,
      title: (json['title'] ?? 'Random GIF') as String?,
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

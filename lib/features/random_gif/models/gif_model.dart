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

  factory Gif.fromJson(Map<String, dynamic> json) {
    final images = (json['images'] ?? {}) as Map<String, dynamic>;
    final downsized = images['downsized_medium'] as Map<String, dynamic>?;
    final original = images['original'] as Map<String, dynamic>?;
    final url = (downsized?['url'] ?? original?['url']) as String?;

    final analytics = (json['analytics'] ?? {}) as Map<String, dynamic>;
    final onload = (analytics['onload']?['url']) as String?;
    final onclick = (analytics['onclick']?['url']) as String?;

    return Gif(
      url: url,
      title: (json['title'] ?? 'Random GIF') as String?,
      analyticsOnLoadUrl: onload,
      analyticsOnClickUrl: onclick,
    );
  }
}
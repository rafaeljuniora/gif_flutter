class Gif {
  final String? id; 
  final String? url;
  final String? title;
  final String? analyticsOnLoadUrl;
  final String? analyticsOnClickUrl;

  Gif({
    this.id,
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
      id: url, 
      url: url,
      title: (json['title'] ?? 'Random GIF') as String?,
      analyticsOnLoadUrl: onload,
      analyticsOnClickUrl: onclick,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'url': url,
      'title': title,
      'analyticsOnLoadUrl': analyticsOnLoadUrl,
      'analyticsOnClickUrl': analyticsOnClickUrl,
    };
  }

  factory Gif.fromMap(Map<String, dynamic> map) {
    return Gif(
      id: map['id'] as String?,
      url: map['url'] as String?,
      title: map['title'] as String?,
      analyticsOnLoadUrl: map['analyticsOnLoadUrl'] as String?,
      analyticsOnClickUrl: map['analyticsOnClickUrl'] as String?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Gif && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

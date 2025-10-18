class Gif {
  final String? url;
  final String title;
  final String? analyticsOnClickUrl;
  final String? analyticsOnLoadUrl;

  Gif({
    required this.url,
    required this.title,
    this.analyticsOnClickUrl,
    this.analyticsOnLoadUrl,
  });

  bool get hasValidUrl => url != null && url!.isNotEmpty;

  factory Gif.fromJson(Map<String, dynamic> json) {
    return Gif(
      url: json['images']?['original']?['url'] ??
          json['url'], 
      title: json['title'] ?? '',
      analyticsOnClickUrl: json['analytics']?['onClick']?['url'],
      analyticsOnLoadUrl: json['analytics']?['onLoad']?['url'],
    );
  }

  Map<String, dynamic> toJson() => {
        'url': url,
        'title': title,
        'analyticsOnClickUrl': analyticsOnClickUrl,
        'analyticsOnLoadUrl': analyticsOnLoadUrl,
      };
}

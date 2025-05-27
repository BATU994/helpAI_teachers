class NewsResponse {
  final String? title;
  final String? description;
  final String? source_icon;
  final String? pubDate;

  NewsResponse({this.title, this.description, this.source_icon, this.pubDate});

  factory NewsResponse.fromJson(Map<String, dynamic> json) {
    return NewsResponse(
      title: json['title'] as String?,
      description: json['description'] as String?,
     source_icon: json['image_url'] as String?,
      pubDate: json['pubDate'] as String?,
    );
  }
}

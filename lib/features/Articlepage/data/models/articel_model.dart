class NewsResponse {
  final String? title;
  final String? description;

  NewsResponse({
    this.title,
    this.description,
  });

  factory NewsResponse.fromJson(Map<String, dynamic> json) {
    return NewsResponse(
      title: json['title'] as String?,
      description: json['description'] as String?,
    );
  }
}

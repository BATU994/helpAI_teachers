import 'package:dio/dio.dart';
import 'package:helpai_teachers/features/Articlepage/data/models/articel_model.dart';

class ArticleService {
  final Dio _dio=Dio();

  Future<List<NewsResponse>> fetchArticles() async {
    final response = await _dio.get(
      'https://newsdata.io/api/1/latest?apikey=pub_cd11daa3b4944fed9d311e1f9c88900b&language=kz',
    );

    if (response.statusCode == 200) {
      final data = response.data['results'] as List<dynamic>;

      return data
          .map((json) => NewsResponse.fromJson(json as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Failed to load articles: ${response.statusCode}');
    }
  }
}

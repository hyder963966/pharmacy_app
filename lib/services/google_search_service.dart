import 'dart:convert';
import 'package:http/http.dart' as http;

class GoogleSearchService {
  // مفتاح API و CX خاصين بك (سنشرح كيف تحصل عليهم لاحقاً)
  final String apiKey = 'YOUR_GOOGLE_API_KEY'; // ← بدله بمفتاحك
  final String cx = 'YOUR_SEARCH_ENGINE_ID';   // ← بدله بمعرف محرك البحث

  Future<String?> fetchDrugUsage(String drugName) async {
    try {
      final query = Uri.encodeComponent('$drugName دواعي الاستعمال');
      final url = Uri.parse(
        'https://www.googleapis.com/customsearch/v1?key=$apiKey&cx=$cx&q=$query',
      );
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['items'] != null && data['items'].isNotEmpty) {
          // نأخذ أول مقتطف نصي
          final snippet = data['items'][0]['snippet'];
          return snippet;
        }
      }
    } catch (e) {
      // لا إنترنت أو خطأ، نتجاهل بصمت
    }
    return null;
  }
}
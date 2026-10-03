import '../api/api_client.dart';
import '../api/api_response.dart';
import '../../models/content_block.dart';

class ContentService {
  const ContentService();

  Future<List<ContentBlock>> getActive() async {
    final response = await ApiClient.get(
      '/content',
      query: {'compact': 'true'},
    );
    return ApiResponse.list(
      response,
      expectedStatusCodes: {200},
      fallback: 'Erro ao buscar conteúdo do app',
    ).whereType<Map<String, dynamic>>().map(ContentBlock.fromJson).toList();
  }
}

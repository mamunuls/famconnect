import 'package:get/get.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GiftSuggestionController extends GetxController {
  final RxList<String> suggestions = <String>[].obs;
  final RxBool isLoading = false.obs;

  final model = GenerativeModel(
    model: 'gemini-1.5-flash-latest',
    apiKey: 'AIzaSyAfImDliOrnfBhwdRQOFuGnSIzMRyMj8y4',
  );

  Future<void> fetchGiftSuggestions({
    required String occasion,
    required String interest,
    required String gender,
    required String ageGroup,
  }) async {
    isLoading.value = true;
    suggestions.clear();

    final prompt = '''
Suggest 5 unique and creative gift ideas for a $gender who is $ageGroup years old, 
interested in $interest, for a $occasion. Only list the gift names in bullet points.
''';

    try {
      final response = await model.generateContent([Content.text(prompt)]);
      final resultText = response.text ?? '';

      final parsed = resultText
          .split('\n')
          .where((line) => line.trim().isNotEmpty)
          .map((line) => line.replaceAll(RegExp(r'^[-•\d.]+\s*'), ''))
          .take(5)
          .toList();

      suggestions.assignAll(parsed.isEmpty ? ['No gifts found.'] : parsed);
    } catch (e) {
      suggestions.assignAll(['Error: ${e.toString()}']);
    } finally {
      isLoading.value = false;
    }
  }
}

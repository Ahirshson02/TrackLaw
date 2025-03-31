import 'package:google_generative_ai/google_generative_ai.dart';

const String apiKey = "AIzaSyAV_l2AufaBT4lBvl8IWt2-_K9JBMxFnic";

class GeminiAPI {

  void main() async {
    final model = GenerativeModel(
        model: 'gemini-1.5-flash-latest',
        apiKey: apiKey,
    );

    final prompt = 'Write a story about a magic backpack.';
    final content = [Content.text(prompt)];
    final response = await model.generateContent(content);

    print(response.text);
  }
}
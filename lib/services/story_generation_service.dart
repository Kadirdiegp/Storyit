import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/story.dart';

class StoryGenerationService {
  static const String _baseUrl = 'https://api-inference.huggingface.co/models';
  static const String _modelId = 'mistralai/Mistral-7B-Instruct-v0.2';

  Future<(String, String)> generateStory({
    required String theme,
    required String childName,
    required int ageGroup,
    String? additionalIdeas,
  }) async {
    if (Story.huggingFaceApiKey == null) {
      throw Exception('API Key nicht gesetzt');
    }

    final prompt =
        '''<s>[INST] Erstelle eine kurze, magische Kindergeschichte (maximal 200 Wörter) für ein $ageGroup-jähriges Kind.

Die Geschichte soll:
- Einen kreativen, kindgerechten Titel haben
- Mit "Es war einmal..." beginnen
- $theme als zentrales Element haben
${additionalIdeas != null ? '- $additionalIdeas\n' : ''}
- Einen sympathischen Hauptcharakter haben
- Eine wichtige Lektion vermitteln
- Mit "Und wenn sie nicht gestorben sind..." enden

Wichtig:
- Die Geschichte soll für ein $ageGroup-jähriges Kind verständlich sein
- In korrektem, kindgerechtem Deutsch geschrieben sein
- Kurze, klare Sätze verwenden
- Aktive statt passive Formulierungen nutzen
- Deutsche Redewendungen und Ausdrücke verwenden
- Positive und lehrreiche Botschaft vermitteln
- Spannend und unterhaltsam sein

Formatierung:
TITEL: [Hier den Titel einfügen]
GESCHICHTE: [Hier die Geschichte einfügen]
[/INST]</s>''';

    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/$_modelId'),
            headers: {
              'Authorization': 'Bearer ${Story.huggingFaceApiKey}',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'inputs': prompt,
              'parameters': {
                'max_new_tokens': 500,
                'temperature': 0.8,
                'top_p': 0.9,
                'do_sample': true,
                'return_full_text': false
              }
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final result = jsonDecode(utf8.decode(response.bodyBytes));
        final text = result[0]['generated_text'] as String;

        final titleMatch = RegExp(r'TITEL:\s*(.+)\n').firstMatch(text);
        final storyMatch =
            RegExp(r'GESCHICHTE:\s*(.+)$', dotAll: true).firstMatch(text);

        final title = titleMatch?.group(1)?.trim() ?? 'Magische Geschichte';
        final content = storyMatch?.group(1)?.trim() ?? text;

        return (title, content);
      } else {
        throw Exception(
            'Fehler bei der Story-Generierung: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Zeitüberschreitung oder Fehler: $e');
    }
  }
}

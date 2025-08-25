import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class WhatsAppBusinessService {
  final String accessToken =
      "EAFYzEZCtDqsoBPP4GeVK3B1ff2gRuuHfYq4bqn3sKUPFACMlOwAX7WDLx05TwjSL8FqNDqEU8tq6VKE6qDZAiCpkguBso2lOgqnP9QmnvB5EQZAAZCRYkVfF09jng42JQgCT3iBA0ZC8SEzIuxbToxi9iodRhXRExOCsHo4oRl0C1WZBjFg9umZCZBb8DZAV2NycGdqiZAYBuzgH8Gu5Jd1BwueaF1ylZB1QlINgltUCYadd58ZD";
  final String phoneNumberId = "780372031819382";

  /// Uploads PDF and returns media_id
  Future<String> uploadPdf(File pdfFile) async {
    var request = http.MultipartRequest(
      "POST",
      Uri.parse("https://graph.facebook.com/v22.0/$phoneNumberId/media"),
    );

    request.headers["Authorization"] = "Bearer $accessToken";
    request.fields["messaging_product"] = "whatsapp";

    request.files.add(
      await http.MultipartFile.fromPath(
        "file",
        pdfFile.path,
        contentType: MediaType("application", "pdf"),
      ),
    );

    var response = await request.send();
    final body = await response.stream.bytesToString();
    print("Upload response: $body");

    if (response.statusCode == 200) {
      final data = jsonDecode(body);
      return data["id"]; // ✅ Return media_id
    } else {
      throw Exception("Upload failed: ${response.statusCode} $body");
    }
  }

  /// Sends uploaded PDF to recipient (must be in 24h session window)
  Future<void> sendPdf(String recipient, String mediaId) async {
    final response = await http.post(
      Uri.parse("https://graph.facebook.com/v22.0/$phoneNumberId/messages"),
      headers: {
        "Authorization": "Bearer $accessToken",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "messaging_product": "whatsapp",
        "to": recipient,
        "type": "document",
        "document": {"id": mediaId, "caption": "Here is your PDF"},
      }),
    );

    print("Send response: ${response.body}");

    if (response.statusCode != 200) {
      throw Exception("Message send failed: ${response.body}");
    }
  }

  /// Combined helper: upload + send
  Future<void> uploadAndSend(File file, String recipient) async {
    final mediaId = await uploadPdf(file);
    await Future.delayed(Duration(seconds: 2)); // wait for processing
    await sendPdf(recipient, mediaId);
  }
}

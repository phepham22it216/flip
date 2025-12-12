import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

class AIChatService {
  // Gọi webhook n8n để kick off workflow (ai analysis)
  Future<void> sendUserMessage(String uid, String text) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('No logged user');

    final idToken = await user.getIdToken();

    // <-- cập nhật URL webhook của bạn ở đây
    final webhookUrl = 'https://piximan.online/webhook/chat';

    final payload = {
      'uid': uid,
      'idToken': idToken,
      'text': text,
      'time': DateTime.now().millisecondsSinceEpoch,
    };

    final resp = await http.post(
      Uri.parse(webhookUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $idToken', // gửi idToken để n8n verify nếu cần
      },
      body: jsonEncode(payload),
    );

    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw Exception('Webhook call failed: ${resp.statusCode} ${resp.body}');
    }
  }
}

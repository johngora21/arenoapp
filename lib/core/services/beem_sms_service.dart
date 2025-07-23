import 'dart:convert';
import 'package:http/http.dart' as http;

class BeemSmsService {
  static const String apiKey = '<YOUR_BEEM_API_KEY>';
  static const String secretKey = '<YOUR_BEEM_SECRET_KEY>';
  static const String senderId = 'INFO'; // Or your approved sender name

  static Future<bool> sendSms({
    required String phone,
    required String message,
  }) async {
    final url = Uri.parse('https://apisms.beem.africa/v1/send');
    final auth = base64Encode(utf8.encode('$apiKey:$secretKey'));
    final body = jsonEncode({
      'source_addr': senderId,
      'encoding': 0,
      'schedule_time': '',
      'message': message,
      'recipients': [
        {
          'recipient_id': '1',
          'dest_addr': phone,
        }
      ],
    });
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Basic $auth',
        'Content-Type': 'application/json',
      },
      body: body,
    );
    return response.statusCode == 200;
  }
} 
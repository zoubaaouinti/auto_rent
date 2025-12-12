import 'package:http/http.dart' as http;
import 'dart:convert';

class EmailService {
  static const String _serviceId = 'service_o6jt1gj';
  static const String _templateId = 'template_ufme16q';
  static const String _userId = 'HwkqFeJ-iru4f1Pbm';

  static Future<void> sendOTP(String email, String otp) async {
    final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');
    
    try {
      final response = await http.post(
        url,
        headers: {
          'origin': 'http://localhost',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'service_id': _serviceId,
          'template_id': _templateId,
          'user_id': _userId,
          'template_params': {
            'to_email': email,
            'otp': otp,
            'app_name': 'Auto Rent'
          }
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Échec de l\'envoi de l\'e-mail: ${response.body}');
      }
    } catch (e) {
      throw Exception('Erreur lors de l\'envoi de l\'e-mail: $e');
    }
  }
}
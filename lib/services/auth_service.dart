import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile_app/config.dart';

class AuthService {
  final String baseUrl = '${Appconfig.baseUrl}/api/auth';

  Future<bool> signUp(String nom, String prenom, String email, String phone, String password, String confirmPassword) async {
    final url = Uri.parse('$baseUrl/register');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nom': nom,
        'prenom': prenom,
        'email': email,
        'phone': phone,
        'password': password,
        'confirmPassword': confirmPassword,
      }),
    );
    return response.statusCode == 200;
  }

  Future<bool> signIn(String email, String password) async {
    final url = Uri.parse('$baseUrl/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    return response.statusCode == 200;
  }

  Future<bool> verifyEmail(String email, String otpCode) async {
    final url = Uri.parse('$baseUrl/verify-email');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'otpCode': otpCode}),
    );
    return response.statusCode == 200;
  }
}
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile_app/config.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final token = responseData['token'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('jwt', token);

      return true;
    }
    return false;
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

  Future<bool> forgotPassword(String email) async {
    final url = Uri.parse('$baseUrl/forgot-password?email=$email');
    final response = await http.post(url);

    return response.statusCode == 200;
  }

  Future<bool> resetPassword(String token, String newPassword, String confirmPassword) async {
    final url = Uri.parse('$baseUrl/reset-password?token=$token');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'newPassword': newPassword, 'confirmNewPassword': confirmPassword}),
    );
    return response.statusCode == 200;
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt');
  }

  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt');
  }
}
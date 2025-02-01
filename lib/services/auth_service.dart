// lib/services/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final String baseUrl = 'http://your-backend-url:5000/api';
  final storage = const FlutterSecureStorage();

  Future<Map<String, dynamic>> register({
    required String fullName,
    required String email,
    required String password,
    required String phone,
    required String userType,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'fullName': fullName,
          'email': email,
          'password': password,
          'phone': phone,
          'userType': userType,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        await storage.write(key: 'token', value: data['token']);
        return data;
      } else {
        throw jsonDecode(response.body)['message'];
      }
    } catch (e) {
      throw e.toString();
    }
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await storage.write(key: 'token', value: data['token']);
        return data;
      } else {
        throw jsonDecode(response.body)['message'];
      }
    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> logout() async {
    await storage.delete(key: 'token');
  }
}

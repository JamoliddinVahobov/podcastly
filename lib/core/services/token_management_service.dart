import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class TokenManagementService {
  static final Dio _dio = Dio();
  static String clientId = dotenv.env['CLIENT_ID'] ?? 'default_client_id';
  static String clientSecret =
      dotenv.env['CLIENT_SECRET'] ?? 'default_client_secret';

  String? _accessToken;
  DateTime? _expiryTime;

  Future<String> getAccessToken() async {
    if (_accessToken != null &&
        _expiryTime != null &&
        _expiryTime!.isAfter(DateTime.now())) {
      return _accessToken!;
    }

    final String basicAuth =
        'Basic ${base64Encode(utf8.encode('$clientId:$clientSecret'))}';
    try {
      final response = await _dio.post(
        'https://accounts.spotify.com/api/token',
        options: Options(
          headers: {
            'Authorization': basicAuth,
            'Content-Type': 'application/x-www-form-urlencoded',
          },
        ),
        data: {
          'grant_type': 'client_credentials',
        },
      );

      if (response.statusCode == 200) {
        _accessToken = response.data['access_token'];
        _expiryTime =
            DateTime.now().add(Duration(seconds: response.data['expires_in']));
        return _accessToken!;
      } else {
        throw Exception('Failed to obtain access token: ${response.data}');
      }
    } catch (e) {
      throw Exception('Error fetching access token: $e');
    }
  }
}

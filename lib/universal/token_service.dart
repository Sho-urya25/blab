import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  final Dio _dio = Dio();

  ApiService() {
    // Set base URL and headers
    _dio.options.baseUrl = dotenv.get("TOKENSERVER_BASE_URL"); // Replace with your backend URL
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  // Helper method to handle errors
  Future<Response> _handleRequest(Future<Response> request) async {
    try {
      final response = await request;
      return response;
    } on DioException catch (e) {
      // Handle Dio errors
      if (e.response != null) {
        throw Exception('Server error: ${e.response!.data}');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  // Join a random room
  Future<Map<String, dynamic>> joinRandomRoom(String firebaseToken) async {
    final response = await _handleRequest(
      _dio.post(
        '/join-randomroom',
        options: Options(headers: {'Authorization': 'Bearer $firebaseToken'}),
      ),
    );
    return response.data;
  }

  // Leave a room
  Future<Map<String, dynamic>> leaveRoom(String firebaseToken, String roomId) async {
    final response = await _handleRequest(
      _dio.post(
        '/leave-room',
        data: {'roomId': roomId},
        options: Options(headers: {'Authorization': 'Bearer $firebaseToken'}),
      ),
    );
    return response.data;
  }

  // Get room information
  Future<Map<String, dynamic>> getRoomInfo(String firebaseToken) async {
    final response = await _handleRequest(
      _dio.get(
        '/get-room',
        options: Options(headers: {'Authorization': 'Bearer $firebaseToken'}),
      ),
    );
    return response.data;
  }
}
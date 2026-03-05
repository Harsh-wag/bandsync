import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;

class AudioAnalysisService {
  // Render deployment URL
  static const String baseUrl = 'https://bandsync-audio-analysis.onrender.com';
  
  static Future<Map<String, dynamic>> analyzeAudio(String audioFilePath) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/analyze'));
      
      // Web doesn't support file paths, use bytes instead
      if (kIsWeb) {
        throw Exception('Audio analysis is not supported on web. Please use mobile or desktop app.');
      }
      
      request.files.add(await http.MultipartFile.fromPath('audio', audioFilePath));
      
      var response = await request.send().timeout(const Duration(seconds: 120));
      var responseData = await response.stream.bytesToString();
      
      if (response.statusCode == 200) {
        return json.decode(responseData);
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}

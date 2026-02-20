import 'package:http/http.dart' as http;
import 'dart:convert';

class AudioAnalysisService {
  // Local development - Python service running on your machine
  static const String baseUrl = 'http://localhost:5000';
  
  static Future<Map<String, dynamic>> analyzeAudio(String audioFilePath) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/analyze'));
      request.files.add(await http.MultipartFile.fromPath('audio', audioFilePath));
      
      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      
      if (response.statusCode == 200) {
        return json.decode(responseData);
      } else {
        throw Exception('Failed to analyze audio');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}

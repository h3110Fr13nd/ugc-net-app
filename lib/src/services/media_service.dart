import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:convert';
import 'package:path/path.dart' as path;
import '../models/composite_question.dart';
import 'api_client.dart';
import 'api_factory.dart';

/// Service for uploading and managing media files
class MediaService {
  final ApiClient _client;

  MediaService([ApiClient? client]) : _client = client ?? ApiFactory.getClient();

  /// Detect MIME type from file extension
  String _detectMimeType(String filePath) {
    final extension = path.extension(filePath).toLowerCase();
    
    switch (extension) {
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.gif':
        return 'image/gif';
      case '.webp':
        return 'image/webp';
      case '.svg':
        return 'image/svg+xml';
      case '.mp4':
        return 'video/mp4';
      case '.webm':
        return 'video/webm';
      case '.ogg':
        return 'video/ogg';
      case '.mp3':
        return 'audio/mpeg';
      case '.wav':
        return 'audio/wav';
      case '.pdf':
        return 'application/pdf';
      default:
        return 'application/octet-stream';
    }
  }

  /// Upload a file and return the Media object
  Future<Media> uploadFile(File file, {String? mimeType}) async {
    try {
      final uri = Uri.parse('${_client.baseUrl}/media/upload');
      final request = http.MultipartRequest('POST', uri);
      
      // Detect MIME type if not provided
      final detectedMimeType = mimeType ?? _detectMimeType(file.path);
      
      // Add the file
      final multipartFile = await http.MultipartFile.fromPath(
        'file',
        file.path,
        contentType: MediaType.parse(detectedMimeType),
      );
      request.files.add(multipartFile);
      
      // Add headers
      request.headers.addAll(_client.defaultHeaders);
      
      // Send request with timeout
      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException('File upload timed out after 30 seconds');
        },
      );
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 201) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return Media.fromJson(data);
      } else {
        throw Exception('Failed to upload file: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error uploading file: $e');
    }
  }

  /// Upload an image file
  Future<Media> uploadImage(File file) async {
    try {
      final uri = Uri.parse('${_client.baseUrl}/media/upload-image');
      final request = http.MultipartRequest('POST', uri);
      
      // Detect MIME type from file extension
      final mimeType = _detectMimeType(file.path);
      
      // Add the file
      final multipartFile = await http.MultipartFile.fromPath(
        'file', 
        file.path,
        contentType: MediaType.parse(mimeType),
      );
      request.files.add(multipartFile);
      
      // Add headers
      request.headers.addAll(_client.defaultHeaders);
      
      // Send request with timeout
      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException('Image upload timed out after 30 seconds');
        },
      );
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 201) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return Media.fromJson(data);
      } else {
        throw Exception('Failed to upload image: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error uploading image: $e');
    }
  }

  /// Get media by ID
  Future<Media> getMedia(String mediaId) async {
    final response = await _client.get('/media/$mediaId');
    
    if (response.statusCode == 200) {
      return Media.fromJson(_client.decode(response.body));
    } else if (response.statusCode == 404) {
      throw Exception('Media not found');
    } else {
      throw Exception('Failed to load media: ${response.statusCode}');
    }
  }

  /// Delete media
  Future<void> deleteMedia(String mediaId) async {
    final response = await http.delete(
      Uri.parse('${_client.baseUrl}/media/$mediaId'),
      headers: _client.defaultHeaders,
    );
    
    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('Failed to delete media: ${response.statusCode}');
    }
  }

  /// List all media
  Future<List<Media>> listMedia({int skip = 0, int limit = 50}) async {
    final params = {
      'skip': skip.toString(),
      'limit': limit.toString(),
    };
    
    final uri = Uri.parse('${_client.baseUrl}/media').replace(queryParameters: params);
    final response = await http.get(uri, headers: _client.defaultHeaders);
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List<dynamic>;
      return data.map((item) => Media.fromJson(item as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to load media list: ${response.statusCode}');
    }
  }

  /// Get full URL for a media file
  String getMediaUrl(String mediaPath) {
    if (mediaPath.startsWith('http')) {
      return mediaPath;
    }
    // Media files are served from the root server path, not under /api/v1
    // Extract base server URL without the API path
    final baseUrl = _client.baseUrl.replaceFirst(RegExp(r'/api/v\d+$'), '');
    return '$baseUrl$mediaPath';
  }
}

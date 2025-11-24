import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'auth_service.dart';
import '../config/app_config.dart';

class WebSocketService {
  WebSocketChannel? _channel;
  final _messageController = StreamController<Map<String, dynamic>>.broadcast();
  
  Stream<Map<String, dynamic>> get messages => _messageController.stream;

  Future<void> connect(String attemptId, String questionId) async {
    // TODO: Add authentication when needed
    // For now, WebSocket endpoint doesn't require auth token

    // Get WebSocket URL from config
    final url = AppConfig.getWsUrl(attemptId, questionId);
    
    print('WebSocket connecting to: $url'); // Debug log

    // Note: Passing headers in WebSocket connect depends on platform implementation.
    // Standard WebSocket API in browsers doesn't support headers.
    // Dart's IOWebSocketChannel does.
    // If running on web, we might need to pass token in query param.
    // For mobile (IO), headers work.
    
    try {
      _channel = WebSocketChannel.connect(
        Uri.parse(url),
      );
      
      // Listen to stream
      _channel!.stream.listen(
        (message) {
          print('WS: Received raw message: $message');
          try {
            final decoded = jsonDecode(message as String);
            print('WS: Decoded message type: ${decoded['type']}');
            _messageController.add(decoded);
          } catch (e) {
            print('WS Parse Error: $e');
          }
        },
        onError: (error) {
          print('WS Error: $error');
          _messageController.addError(error);
        },
        onDone: () {
          print('WS Closed');
        },
      );
    } catch (e) {
      print('WS Connect Error: $e');
      rethrow;
    }
  }

  void sendAnswer(Map<String, dynamic> answer) {
    if (_channel != null) {
      _channel!.sink.add(jsonEncode(answer));
    } else {
      print('WS Not connected');
    }
  }

  void disconnect() {
    if (_channel != null) {
      _channel!.sink.close(status.goingAway);
      _channel = null;
    }
  }
  
  void dispose() {
    disconnect();
    _messageController.close();
  }
}

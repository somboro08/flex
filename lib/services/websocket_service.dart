import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'api_client.dart';

class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;
  WebSocketService._internal();

  WebSocketChannel? _channel;
  final StreamController<Map<String, dynamic>> _messageController =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get stream => _messageController.stream;
  bool get isConnected => _channel != null;

  Future<void> connect() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id') ?? '';
      final baseUrl = ApiClient.getBaseUrl();
      final wsUrl = baseUrl
          .replaceAll('http://', 'ws://')
          .replaceAll('https://', 'wss://');
      
      final Uri uri = Uri.parse('$wsUrl/ws?userId=$userId');

      _channel = IOWebSocketChannel.connect(uri);
      _channel!.stream.listen(
        (data) {
          try {
            final Map<String, dynamic> jsonMsg = jsonDecode(data.toString());
            _messageController.add(jsonMsg);
          } catch (e) {
            debugPrint('Error parsing WS message: $e');
          }
        },
        onError: (err) {
          debugPrint('WebSocket error: $err');
          _reconnect();
        },
        onDone: () {
          debugPrint('WebSocket closed');
          _channel = null;
        },
      );
    } catch (e) {
      debugPrint('Failed to connect WebSocket: $e');
    }
  }

  void _reconnect() {
    _channel = null;
    Future.delayed(const Duration(seconds: 5), () {
      connect();
    });
  }

  void sendMessage(String recipientId, String content, {String? listingId}) {
    if (_channel != null) {
      final msg = jsonEncode({
        'type': 'chat',
        'recipientId': recipientId,
        'payload': {
          'content': content,
          'listingId': listingId,
        }
      });
      _channel!.sink.add(msg);
    }
  }

  void disconnect() {
    _channel?.sink.close();
    _channel = null;
  }
}

import 'package:socket_io_client/socket_io_client.dart' as socket_io;
import '../config/app_config.dart';

class SocketService {
  socket_io.Socket? _socket;

  void connect(String deviceCode, void Function(Map<String, dynamic>) onTelemetry, void Function(String) onStatus) {
    _socket = socket_io.io(
      AppConfig.socketBaseUrl,
      socket_io.OptionBuilder().setTransports(['websocket']).disableAutoConnect().build(),
    );

    _socket!.connect();

    _socket!.onConnect((_) {
      _socket!.emit('subscribe:device', deviceCode);
    });

    _socket!.on('telemetry', (data) {
      if (data is Map && data['data'] is Map) {
        onTelemetry(Map<String, dynamic>.from(data['data'] as Map));
      }
    });

    _socket!.on('status', (data) {
      if (data is Map && data['data'] is Map) {
        onStatus(data['data']['status'] as String);
      }
    });
  }

  void disconnect(String deviceCode) {
    _socket?.emit('unsubscribe:device', deviceCode);
    _socket?.disconnect();
    _socket?.dispose();
  }
}

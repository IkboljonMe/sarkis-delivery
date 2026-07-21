import 'dart:async';

import 'package:socket_io_client/socket_io_client.dart' as io;

import '../services/api_client.dart';
import '../utils/constants.dart';

/// One event received from the realtime gateway (see backend
/// `src/realtime/realtime.gateway.ts`): `order:created`, `order:updated`,
/// `message:created`, `message:updated`, `topic:updated`,
/// `notification:created`, `approval:created`, `approval:updated`.
class RealtimeEvent {
  final String name;
  final dynamic payload;
  RealtimeEvent(this.name, this.payload);
}

/// Thin wrapper around socket_io_client: connects with the current access
/// token, auto-reconnects (socket.io's own backoff), and republishes every
/// domain event as a single [events] stream for SyncEngine to consume.
///
/// Sockets only carry live updates while the app is open/foregrounded — there
/// is no background wake signal, so SyncEngine falls back to a REST `since=`
/// pull on reconnect for anything missed while disconnected.
class SocketService {
  SocketService._();
  static final SocketService instance = SocketService._();

  io.Socket? _socket;
  final _controller = StreamController<RealtimeEvent>.broadcast();
  Stream<RealtimeEvent> get events => _controller.stream;

  bool get isConnected => _socket?.connected ?? false;

  static const _domainEvents = [
    'order:created',
    'order:updated',
    'message:created',
    'message:updated',
    'topic:updated',
    'notification:created',
    'approval:created',
    'approval:updated',
  ];

  void connect() {
    final token = ApiClient.instance.accessToken;
    if (token == null) return;
    disconnect();

    final socket = io.io(
      AppConstants.apiBaseUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setAuth({'token': token})
          .build(),
    );
    for (final name in _domainEvents) {
      socket.on(name, (data) => _controller.add(RealtimeEvent(name, data)));
    }
    socket.connect();
    _socket = socket;
  }

  /// Re-connects with a fresh access token — call after a successful
  /// silent-refresh so the socket doesn't keep using a token that just
  /// expired (the gateway only checks the token once, at handshake time).
  void reconnectWithFreshToken() => connect();

  void joinChat(String topicId) => _socket?.emit('chat:join', topicId);
  void leaveChat(String topicId) => _socket?.emit('chat:leave', topicId);

  void disconnect() {
    _socket?.dispose();
    _socket = null;
  }
}

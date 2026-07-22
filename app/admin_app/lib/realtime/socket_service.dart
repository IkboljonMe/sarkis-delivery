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
/// ADMIN/SUPERADMIN accounts join the gateway's `staff` room automatically
/// (see backend `RealtimeGateway.handleConnection`) so this app receives
/// order/topic/approval broadcasts for everything, not just its own user.
class SocketService {
  SocketService._();
  static final SocketService instance = SocketService._();

  io.Socket? _socket;
  final _controller = StreamController<RealtimeEvent>.broadcast();
  final _connects = StreamController<void>.broadcast();

  /// Chat rooms currently open in the UI. Re-emitted on every (re)connect so
  /// room membership self-heals after a network blip or token refresh — the
  /// `staff` room is rejoined server-side automatically, but per-customer
  /// `chat:<topicId>` rooms are not, so we rejoin whatever is open.
  final Set<String> _activeTopics = {};

  Stream<RealtimeEvent> get events => _controller.stream;

  /// Fires on every successful (re)connect handshake. SyncEngine listens to
  /// run a `since=` catch-up pull for anything missed while disconnected.
  Stream<void> get onConnect => _connects.stream;

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
          // Allow polling as a fallback so a proxy that won't upgrade the
          // websocket still establishes a connection.
          .setTransports(['websocket', 'polling'])
          .disableAutoConnect()
          .setAuth({'token': token})
          .build(),
    );
    socket.onConnect((_) {
      for (final topicId in _activeTopics) {
        socket.emit('chat:join', topicId);
      }
      _connects.add(null);
    });
    for (final name in _domainEvents) {
      socket.on(name, (data) => _controller.add(RealtimeEvent(name, data)));
    }
    socket.connect();
    _socket = socket;
  }

  void reconnectWithFreshToken() => connect();

  void joinChat(String topicId) {
    _activeTopics.add(topicId);
    _socket?.emit('chat:join', topicId);
  }

  void leaveChat(String topicId) {
    _activeTopics.remove(topicId);
    _socket?.emit('chat:leave', topicId);
  }

  void disconnect() {
    _socket?.dispose();
    _socket = null;
  }
}

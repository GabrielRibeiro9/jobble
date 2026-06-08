import 'dart:async';
import 'package:flutter_tcc/core/services/token_service.dart';

class ConnectionMonitor {
  final TokenService tokenService;
  final StreamController<bool> _connectionController = StreamController<bool>.broadcast();

  ConnectionMonitor({required this.tokenService});

  Stream<bool> get connectionStream => _connectionController.stream;

  void onConnectionError() async {
    await tokenService.deleteToken();
    _connectionController.add(false);
  }

  void dispose() {
    _connectionController.close();
  }
}
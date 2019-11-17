import 'dart:convert';

import 'package:rxdart/rxdart.dart';
import 'package:web_socket_channel/io.dart';

import '../model.dart';

abstract class ServerRepository {
  Observable<List<VehicleStateModel>> get vehicleStates;
}

class ServerStorage extends ServerRepository {
  static const _HEADERS = {
    'Host': 'smartarea.info',
    'Connection': 'Upgrade',
    'Pragma': 'no-cache',
    'Cache-Control': 'no-cache',
    'Upgrade': 'websocket',
    'Sec-WebSocket-Extensions': 'permessage-deflate; client_max_window_bits',
    'Sec-WebSocket-Version': '13',
    'Accept-Encoding': 'gzip, deflate, br',
    'Accept-Language': 'ru,en-US;q=0.9,en;q=0.8'
  };

  @override
  Observable<List<VehicleStateModel>> get vehicleStates {
    var eventCounter = 0;
    final socketChannel = IOWebSocketChannel.connect(
        'wss://smartarea.info/socket.io/?EIO=3&transport=websocket',
        headers: _HEADERS);
    return Observable(socketChannel.stream)
        .doOnData((event) {
          eventCounter++;
          if (eventCounter == 5) {
            eventCounter = 0;
            socketChannel.sink.add('2');
          }
          if ((event as String).startsWith('40')) {
            socketChannel.sink.add('42["sendltLn"]');
          }
        })
        .doOnError((error) => print('Socket error: $error'))
        .doOnDone(
            () => print('Socket done. Close code: ${socketChannel.closeCode}'))
        .where((event) => (event as String).startsWith('42'))
        .doOnData((event) => print('data event'))
        .map((event) {
          final eventStr = event as String;
          final encoded = eventStr.substring(2, eventStr.length);
          List<dynamic> decoded = jsonDecode(encoded);
          return _map(decoded);
        });
  }

  List<VehicleStateModel> _map(List<dynamic> from) {
    List<dynamic> maps = from[1];
    return maps.map((map) {
      return VehicleStateModel.fromJson(map);
    }).toList(growable: false);
  }
}

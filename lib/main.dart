import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong/latlong.dart';
import 'package:smart_city/model.dart';
import 'package:web_socket_channel/io.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final home = MapPage();
    return MaterialApp(
        title: 'Flutter Smart City Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: home);
  }
}

class MapPage extends StatefulWidget {
  static final _headers = {
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
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> with SingleTickerProviderStateMixin {
  final _channel = IOWebSocketChannel.connect(
      'wss://smartarea.info/socket.io/?EIO=3&transport=websocket',
      headers: MapPage._headers);
  final _streamController = StreamController<List<VehicleStateModel>>();
  final _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _listen();
  }

  @override
  void dispose() {
    super.dispose();
    _streamController.close();
  }

  void _listen() {
    var eventCounter = 0;
    _channel.stream.listen((event) {
      eventCounter++;
      if (eventCounter == 5) {
        eventCounter = 0;
        _channel.sink.add('2');
      }
      final eventStr = event as String;
      if (eventStr.startsWith('40')) {
        _channel.sink.add('42["sendltLn"]');
      }
      if (eventStr.startsWith('42')) {
        final encoded = eventStr.substring(2, eventStr.length);
        List<dynamic> decoded = jsonDecode(encoded);
        final models = map(decoded);
        _streamController.add(models);
      }
    }, onError: (error) {
      print('Socket error: $error');
    }, onDone: () {
      print('Socket done. Close code: ${_channel.closeCode}');
    });
  }

  List<VehicleStateModel> map(List<dynamic> from) {
    List<dynamic> maps = from[1];
    return maps.map((map) {
      return VehicleStateModel.fromJson(map);
    }).toList(growable: false);
  }

  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Geolocator().getCurrentPosition(),
      builder: (BuildContext context, AsyncSnapshot<Position> snapshot) {
        if (!snapshot.hasData) return Container();
        final userPosition = snapshot.data;
        return StreamBuilder(
          stream: _streamController.stream,
          builder: (BuildContext context,
              AsyncSnapshot<List<VehicleStateModel>> snapshot) {
            if (!snapshot.hasData) return Container();
            final models = snapshot.data;
            return Scaffold(
              body: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  center: LatLng(userPosition.latitude, userPosition.longitude),
                  zoom: 15.0,
                ),
                layers: [
                  TileLayerOptions(
                    urlTemplate:
                        'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                    subdomains: ['a', 'b', 'c'],
                  ),
                  MarkerLayerOptions(
                    markers: models.map((model) {
                      String imgPath = 'assets/images/tram.svg';
                      Color color = Colors.blue;
                      Color colorBack = Colors.yellow;
                      if (model.type == 2) {
                        imgPath = 'assets/images/trolleybus.svg';
                        color = Colors.red;
                        colorBack = Colors.green;
                      }
                      return Marker(
                        width: 40.0,
                        height: 40.0,
                        point: LatLng(model.latitude, model.longitude),
                        builder: (ctx) => Container(
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: colorBack.withOpacity(0.5)),
                          child: Column(
                            children: <Widget>[
                              Text(
                                model.routeNumber,
                                style: TextStyle(fontSize: 15, color: color),
                              ),
                              SizedBox(
                                  height: 20.0,
                                  child: SvgPicture.asset(
                                    imgPath,
                                    color: color,
                                  ))
                            ],
                          ),
                        ),
                      );
                    }).toList()
                      ..add(Marker(
                          width: 100.0,
                          height: 35.0,
                          point: LatLng(
                              userPosition.latitude, userPosition.longitude),
                          builder: (ctx) => Column(
                                children: <Widget>[
                                  SizedBox(
                                      height: 19.0,
                                      child: Text(
                                        'You are here!',
                                        style: TextStyle(fontSize: 19),
                                      )),
                                  Container(
                                    height: 15.0,
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.deepPurpleAccent),
                                  ),
                                ],
                              ))),
                  ),
                ],
              ),
              floatingActionButton: FloatingActionButton(
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.gps_fixed,
                  color: Colors.grey,
                ),
                onPressed: () {
                  Geolocator().getCurrentPosition().then((v) {
                    _mapController.move(LatLng(v.latitude, v.longitude), 15);
                  });
                },
              ),
            );
          },
        );
      },
    );
  }
}

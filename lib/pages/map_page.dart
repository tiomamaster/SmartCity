import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong/latlong.dart';
import 'package:smart_city/bloc/bloc_provider.dart';
import 'package:smart_city/bloc/map_block.dart';
import 'package:smart_city/model.dart';

import '../destination.dart';

class MapPage extends StatefulWidget {
  MapPage({Key key, this.destination}) : super(key: key);

  final Destination destination;

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> with SingleTickerProviderStateMixin {
  MapBloc _bloc;
  final _mapController = MapController();
  Position _userPosition;
  AnimationController _animationController;
  Animation _colorTween;

  @override
  void initState() {
    super.initState();
    _bloc = MapBloc();

    _animationController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 1000));
    _colorTween = ColorTween(begin: Colors.red, end: Colors.green)
        .animate(_animationController)
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              _animationController.reverse();
            } else if (status == AnimationStatus.dismissed) {
              _animationController.forward();
            }
          });
    _animationController.forward();
  }

  Widget build(BuildContext context) {
    return BlocProvider<MapBloc>(
      child: FutureBuilder(
        future: Geolocator().getCurrentPosition(),
        builder: (BuildContext context, AsyncSnapshot<Position> snapshot) {
          if (!snapshot.hasData) {
            return Scaffold(
              body: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  center: LatLng(49.9935, 36.2304),
                  zoom: 11.0,
                ),
                layers: [
                  TileLayerOptions(
                    urlTemplate:
                        'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                    subdomains: ['a', 'b', 'c'],
                  ),
                ],
              ),
            );
          }
          _userPosition = snapshot.data;
          return StreamBuilder(
            stream: _bloc.vehicleStates,
            builder: (BuildContext context,
                AsyncSnapshot<List<VehicleStateModel>> snapshot) {
              if (!snapshot.hasData) return Container();
              final models = snapshot.data;
              return Scaffold(
                body: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    center:
                        LatLng(_userPosition.latitude, _userPosition.longitude),
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
                            point: LatLng(_userPosition.latitude,
                                _userPosition.longitude),
                            builder: (ctx) => AnimatedBuilder(
                                  animation: _colorTween,
                                  builder: (context, child) => Column(
                                    children: <Widget>[
                                      SizedBox(
                                          height: 19.0,
                                          child: Text(
                                            'You are here!',
                                            style: TextStyle(
                                                fontSize: 19,
                                                color: _colorTween.value),
                                          )),
                                      Container(
                                        height: 15.0,
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: _colorTween.value),
                                      ),
                                    ],
                                  ),
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
                    _mapController.move(
                        LatLng(_userPosition.latitude, _userPosition.longitude),
                        15);
                  },
                ),
              );
            },
          );
        },
      ),
      bloc: MapBloc(),
    );
  }
}

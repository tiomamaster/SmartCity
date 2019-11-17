import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smart_city/pages/favourites_page.dart';
import 'package:smart_city/pages/map_page.dart';
import 'package:smart_city/pages/search_page.dart';
import 'package:smart_city/pages/stops_page.dart';

import 'destination.dart';

class ViewNavigatorObserver extends NavigatorObserver {
  ViewNavigatorObserver(this.onNavigation);

  final VoidCallback onNavigation;

  void didPop(Route<dynamic> route, Route<dynamic> previousRoute) {
    onNavigation();
  }

  void didPush(Route<dynamic> route, Route<dynamic> previousRoute) {
    onNavigation();
  }
}

class DestinationView extends StatefulWidget {
  const DestinationView({Key key, this.destination, this.onNavigation})
      : super(key: key);

  final Destination destination;
  final VoidCallback onNavigation;

  @override
  _DestinationViewState createState() => _DestinationViewState();
}

class _DestinationViewState extends State<DestinationView> {
  @override
  Widget build(BuildContext context) {
    return Navigator(
      observers: <NavigatorObserver>[
        ViewNavigatorObserver(widget.onNavigation),
      ],
      onGenerateRoute: (RouteSettings settings) {
        return MaterialPageRoute(
          settings: settings,
          builder: (BuildContext context) {
            if (widget.destination.index == 0) {
              switch (settings.name) {
                case '/':
                  return MapPage(destination: widget.destination);
                default:
                  return Container();
              }
            } else if (widget.destination.index == 1) {
              switch (settings.name) {
                case '/':
                  return StopsPage(destination: widget.destination);
                default:
                  return Container();
              }
            } else if (widget.destination.index == 2) {
              switch (settings.name) {
                case '/':
                  return SearchPage(destination: widget.destination);
                default:
                  return Container();
              }
            } else if (widget.destination.index == 3) {
              switch (settings.name) {
                case '/':
                  return FavouritesPage(destination: widget.destination);
                default:
                  return Container();
              }
            } else {
              return Container();
            }
          },
        );
      },
    );
  }
}

import 'package:flutter/cupertino.dart';

import '../destination.dart';

class FavouritesPage extends StatelessWidget {
  FavouritesPage({Key key, this.destination}) : super(key: key);

  final Destination destination;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "${destination.title} page in development...",
        style: TextStyle(fontSize: 22),
      ),
    );
  }
}

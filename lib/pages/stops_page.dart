import 'package:flutter/cupertino.dart';
import 'package:smart_city/destination.dart';

class StopsPage extends StatelessWidget {
  StopsPage({Key key, this.destination}) : super(key: key);

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

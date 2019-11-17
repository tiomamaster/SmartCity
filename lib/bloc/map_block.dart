import 'dart:async';

import 'package:smart_city/bloc/bloc_provider.dart';
import 'package:smart_city/model.dart';
import 'package:smart_city/repository/server_repository.dart';

class MapBloc extends BlocBase {
  ServerRepository _serverRepo = ServerStorage();

  Stream<List<VehicleStateModel>> get vehicleStates {
    return _serverRepo.vehicleStates;
  }

  @override
  void dispose() {}
}

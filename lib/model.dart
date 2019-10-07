import 'package:json_annotation/json_annotation.dart';

part 'model.g.dart';

@JsonSerializable()
class VehicleStateModel {
  VehicleStateModel(this.routeNumber, this.direction, this.latitude,
      this.longitude, this.type, this.vehicleId, this.speed);

  String routeNumber;
  int direction;
  double latitude;
  double longitude;
  int type;
  int vehicleId;
  int speed;

  factory VehicleStateModel.fromJson(Map<String, dynamic> json) =>
      _$VehicleStateModelFromJson(json);

  Map<String, dynamic> toJson() => _$VehicleStateModelToJson(this);
}

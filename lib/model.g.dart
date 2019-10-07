// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VehicleStateModel _$VehicleStateModelFromJson(Map<String, dynamic> json) {
  return VehicleStateModel(
    json['routeNumber'] as String,
    json['direction'] as int,
    (json['latitude'] as num)?.toDouble(),
    (json['longitude'] as num)?.toDouble(),
    json['type'] as int,
    json['vehicleId'] as int,
    json['speed'] as int,
  );
}

Map<String, dynamic> _$VehicleStateModelToJson(VehicleStateModel instance) =>
    <String, dynamic>{
      'routeNumber': instance.routeNumber,
      'direction': instance.direction,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'type': instance.type,
      'vehicleId': instance.vehicleId,
      'speed': instance.speed,
    };

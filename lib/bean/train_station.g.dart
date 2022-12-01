// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'train_station.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TrainStation _$TrainStationFromJson(Map<String, dynamic> json) {
  return TrainStation(
    trainCode: json['trainCode'] as String,
    stationTelecode: json['stationTelecode'] as String,
    arriveDayDiff: json['arriveDayDiff'] as num,
    arriveTime: json['arriveTime'],
    updateArriveTime: json['updateArriveTime'],
    startTime: json['startTime'],
    updateStartTime: json['updateStartTime'],
    startDayDiff: json['startDayDiff'] as num,
    stationNo: json['stationNo'] as num,
  );
}

Map<String, dynamic> _$TrainStationToJson(TrainStation instance) =>
    <String, dynamic>{
      'trainCode': instance.trainCode,
      'stationTelecode': instance.stationTelecode,
      'arriveDayDiff': instance.arriveDayDiff,
      'arriveTime': instance.arriveTime,
      'updateArriveTime': instance.updateArriveTime,
      'startTime': instance.startTime,
      'updateStartTime': instance.updateStartTime,
      'startDayDiff': instance.startDayDiff,
      'stationNo': instance.stationNo,
    };

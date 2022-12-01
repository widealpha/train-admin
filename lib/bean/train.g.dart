// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'train.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Train _$TrainFromJson(Map<String, dynamic> json) {
  return Train(
    trainNo: json['trainNo'] as String?,
    trainCode: json['trainCode'] as String?,
    startStationTelecode: json['startStationTelecode'] as String?,
    startStation: json['startStation'] == null
        ? null
        : Station.fromJson(json['startStation'] as Map<String, dynamic>),
    startStartTime: json['startStartTime'] as String?,
    endStationTelecode: json['endStationTelecode'] as String?,
    endStation: json['endStation'] == null
        ? null
        : Station.fromJson(json['endStation'] as Map<String, dynamic>),
    endArriveTime: json['endArriveTime'] as String?,
    trainTypeCode: json['trainTypeCode'] as String?,
    trainClassCode: json['trainClassCode'] as String?,
    tranClass: json['tranClass'] == null
        ? null
        : TrainClass.fromJson(json['tranClass'] as Map<String, dynamic>),
    seatTypes: json['seatTypes'] as String?,
    seatType: json['seatType'] == null
        ? null
        : SeatType.fromJson(json['seatType'] as Map<String, dynamic>),
    startDate: json['startDate'] as String?,
    stopDate: json['stopDate'] as String?,
    trainStations: (json['trainStations'] as List<dynamic>?)
        ?.map((e) => TrainStation.fromJson(e as Map<String, dynamic>))
        .toList(),
    nowStartStationTelecode: json['nowStartStationTelecode'] as String?,
    nowEndStationTelecode: json['nowEndStationTelecode'] as String?,
  );
}

Map<String, dynamic> _$TrainToJson(Train instance) => <String, dynamic>{
      'trainNo': instance.trainNo,
      'trainCode': instance.trainCode,
      'startStationTelecode': instance.startStationTelecode,
      'startStation': instance.startStation,
      'startStartTime': instance.startStartTime,
      'endStationTelecode': instance.endStationTelecode,
      'endStation': instance.endStation,
      'endArriveTime': instance.endArriveTime,
      'trainTypeCode': instance.trainTypeCode,
      'trainClassCode': instance.trainClassCode,
      'tranClass': instance.tranClass,
      'seatTypes': instance.seatTypes,
      'seatType': instance.seatType,
      'startDate': instance.startDate,
      'stopDate': instance.stopDate,
      'trainStations': instance.trainStations,
      'nowStartStationTelecode': instance.nowStartStationTelecode,
      'nowEndStationTelecode': instance.nowEndStationTelecode,
    };

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'train.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Train _$TrainFromJson(Map<String, dynamic> json) {
  return Train(
    trainNo: json['trainNo'] as String?,
    stationTrainCode: json['stationTrainCode'] as String?,
    startStationTelecode: json['startStationTelecode'] as String?,
    startStartTime: json['startStartTime'] as String?,
    endStationTelecode: json['endStationTelecode'] as String?,
    endArriveTime: json['endArriveTime'] as String?,
    trainTypeCode: json['trainTypeCode'] as String?,
    trainClassCode: json['trainClassCode'] as String?,
    seatTypes: json['seatTypes'] as String?,
    startDate: json['startDate'] as String?,
    stopDate: json['stopDate'] as String?,
  );
}

Map<String, dynamic> _$TrainToJson(Train instance) => <String, dynamic>{
      'trainNo': instance.trainNo,
      'stationTrainCode': instance.stationTrainCode,
      'startStationTelecode': instance.startStationTelecode,
      'startStartTime': instance.startStartTime,
      'endStationTelecode': instance.endStationTelecode,
      'endArriveTime': instance.endArriveTime,
      'trainTypeCode': instance.trainTypeCode,
      'trainClassCode': instance.trainClassCode,
      'seatTypes': instance.seatTypes,
      'startDate': instance.startDate,
      'stopDate': instance.stopDate,
    };

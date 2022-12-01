// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'remain_seat.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RemainSeat _$RemainSeatFromJson(Map<String, dynamic> json) {
  return RemainSeat(
    startStationTelecode: json['startStationTelecode'] as String?,
    endStationTelecode: json['endStationTelecode'] as String?,
    remaining: json['remaining'] as num?,
    trainCode: json['trainCode'] as String?,
    trainClassCode: json['trainClassCode'] as String?,
    trainClassName: json['trainClassName'] as String?,
    seatTypeCode: json['seatTypeCode'] as String?,
    seatTypeName: json['seatTypeName'] as String?,
    date: json['date'] as String?,
  );
}

Map<String, dynamic> _$RemainSeatToJson(RemainSeat instance) =>
    <String, dynamic>{
      'startStationTelecode': instance.startStationTelecode,
      'endStationTelecode': instance.endStationTelecode,
      'remaining': instance.remaining,
      'trainCode': instance.trainCode,
      'trainClassCode': instance.trainClassCode,
      'trainClassName': instance.trainClassName,
      'seatTypeCode': instance.seatTypeCode,
      'seatTypeName': instance.seatTypeName,
      'date': instance.date,
    };

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coach.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Coach _$CoachFromJson(Map<String, dynamic> json) {
  return Coach(
    coachId: json['coachId'] as num,
    coachNo: json['coachNo'] as num,
    trainCode: json['trainCode'] as String,
    seatTypeCode: json['seatTypeCode'] as String,
    seat: json['seat'] as num,
    seatCount: json['seatCount'] as num,
  );
}

Map<String, dynamic> _$CoachToJson(Coach instance) => <String, dynamic>{
      'coachId': instance.coachId,
      'coachNo': instance.coachNo,
      'trainCode': instance.trainCode,
      'seatTypeCode': instance.seatTypeCode,
      'seat': instance.seat,
      'seatCount': instance.seatCount,
    };

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ticket.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Ticket _$TicketFromJson(Map<String, dynamic> json) {
  return Ticket(
    ticketId: json['ticketId'] as num?,
    coachId: json['coachId'] as num?,
    trainCode: json['trainCode'] as String?,
    startStationTelecode: json['startStationTelecode'] as String?,
    endStationTelecode: json['endStationTelecode'] as String?,
    startStation: json['startStation'] == null
        ? null
        : Station.fromJson(json['startStation'] as Map<String, dynamic>),
    endStation: json['endStation'] == null
        ? null
        : Station.fromJson(json['endStation'] as Map<String, dynamic>),
    startTime: json['startTime'] as String?,
    endTime: json['endTime'] as String?,
    price: json['price'] as num?,
    passengerId: json['passengerId'] as num?,
    orderId: json['orderId'] as num?,
    student: json['student'] as bool?,
    seat: json['seat'] as num?,
  );
}

Map<String, dynamic> _$TicketToJson(Ticket instance) => <String, dynamic>{
      'ticketId': instance.ticketId,
      'coachId': instance.coachId,
      'trainCode': instance.trainCode,
      'startStationTelecode': instance.startStationTelecode,
      'endStationTelecode': instance.endStationTelecode,
      'startStation': instance.startStation,
      'endStation': instance.endStation,
      'startTime': instance.startTime,
      'endTime': instance.endTime,
      'price': instance.price,
      'passengerId': instance.passengerId,
      'orderId': instance.orderId,
      'student': instance.student,
      'seat': instance.seat,
    };

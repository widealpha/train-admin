import 'package:json_annotation/json_annotation.dart';
import 'package:train/bean/station.dart';

part 'ticket.g.dart';

@JsonSerializable()
class Ticket {
  num? ticketId;
  num? coachId;
  String? trainCode;
  String? startStationTelecode;
  String? endStationTelecode;
  Station? startStation;
  Station? endStation;
  String? startTime;
  String? endTime;
  num? price;
  num? passengerId;
  num? orderId;
  bool? student;
  num? seat;
  @JsonKey(ignore: true)
  String? startStationName;
  @JsonKey(ignore: true)
  String? endStationName;

  Ticket(
      {this.ticketId,
      this.coachId,
      this.trainCode,
      this.startStationTelecode,
      this.endStationTelecode,
      this.startStation,
      this.endStation,
      this.startTime,
      this.endTime,
      this.price,
      this.passengerId,
      this.orderId,
      this.student,
      this.seat});

  factory Ticket.fromJson(Map<String, dynamic> json) => _$TicketFromJson(json);

  Map<String, dynamic> toJson() => _$TicketToJson(this);
}


import 'package:json_annotation/json_annotation.dart';

part 'remain_seat.g.dart';

@JsonSerializable()
class RemainSeat {
  String? startStationTelecode;
  String? endStationTelecode;
  num? remaining;
  String? trainCode;
  String? trainClassCode;
  String? trainClassName;
  String? seatTypeCode;
  String? seatTypeName;
  String? date;

  RemainSeat({this.startStationTelecode, this.endStationTelecode, this.remaining, this.trainCode, this.trainClassCode, this.trainClassName, this.seatTypeCode, this.seatTypeName, this.date});

  factory RemainSeat.fromJson(Map<String, dynamic> json) => _$RemainSeatFromJson(json);

  Map<String, dynamic> toJson() => _$RemainSeatToJson(this);
}


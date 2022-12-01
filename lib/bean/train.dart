import 'package:json_annotation/json_annotation.dart';
import 'package:train/bean/seat_type.dart';
import 'package:train/bean/station.dart';
import 'package:train/bean/train_class.dart';
import 'package:train/bean/train_station.dart';

part 'train.g.dart';

@JsonSerializable()
class Train {
  String? trainNo;
  String? trainCode;
  String? startStationTelecode;
  Station? startStation;
  String? startStartTime;
  String? endStationTelecode;
  Station? endStation;
  String? endArriveTime;
  String? trainTypeCode;
  String? trainClassCode;
  TrainClass? tranClass;
  String? seatTypes;
  SeatType? seatType;
  String? startDate;
  String? stopDate;
  List<TrainStation>? trainStations;
  String? nowStartStationTelecode;
  String? nowEndStationTelecode;


  Train(
      {this.trainNo,
      this.trainCode,
      this.startStationTelecode,
      this.startStation,
      this.startStartTime,
      this.endStationTelecode,
      this.endStation,
      this.endArriveTime,
      this.trainTypeCode,
      this.trainClassCode,
      this.tranClass,
      this.seatTypes,
      this.seatType,
      this.startDate,
      this.stopDate,
      this.trainStations,
      this.nowStartStationTelecode,
      this.nowEndStationTelecode});

  factory Train.fromJson(Map<String, dynamic> json) => _$TrainFromJson(json);

  Map<String, dynamic> toJson() => _$TrainToJson(this);
}

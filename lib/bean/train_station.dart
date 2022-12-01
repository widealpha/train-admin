import 'package:json_annotation/json_annotation.dart';

part 'train_station.g.dart';

@JsonSerializable()
class TrainStation {
  String trainCode;
  String stationTelecode;
  num arriveDayDiff;
  dynamic arriveTime;
  dynamic updateArriveTime;
  dynamic startTime;
  dynamic updateStartTime;
  num startDayDiff;
  num stationNo;

  TrainStation({required this.trainCode, required this.stationTelecode, required this.arriveDayDiff, required this.arriveTime, required this.updateArriveTime, required this.startTime, required this.updateStartTime, required this.startDayDiff, required this.stationNo});

  factory TrainStation.fromJson(Map<String, dynamic> json) => _$TrainStationFromJson(json);

  Map<String, dynamic> toJson() => _$TrainStationToJson(this);
}


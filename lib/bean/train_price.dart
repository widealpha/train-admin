import 'package:json_annotation/json_annotation.dart';

part 'train_price.g.dart';

@JsonSerializable()
class TrainPrice {
  String trainCode;
  String seatTypeCode;
  String seatTypeName;
  String trainClassCode;
  String trainClassName;
  num price;
  String startStationTelecode;
  String endStationTelecode;

  TrainPrice({required this.trainCode, required this.seatTypeCode, required this.seatTypeName, required this.trainClassCode, required this.trainClassName, required this.price, required this.startStationTelecode, required this.endStationTelecode});

  factory TrainPrice.fromJson(Map<String, dynamic> json) => _$TrainPriceFromJson(json);

  Map<String, dynamic> toJson() => _$TrainPriceToJson(this);
}


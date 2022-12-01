// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'train_price.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TrainPrice _$TrainPriceFromJson(Map<String, dynamic> json) {
  return TrainPrice(
    trainCode: json['trainCode'] as String,
    seatTypeCode: json['seatTypeCode'] as String,
    seatTypeName: json['seatTypeName'] as String,
    trainClassCode: json['trainClassCode'] as String,
    trainClassName: json['trainClassName'] as String,
    price: json['price'] as num,
    startStationTelecode: json['startStationTelecode'] as String,
    endStationTelecode: json['endStationTelecode'] as String,
  );
}

Map<String, dynamic> _$TrainPriceToJson(TrainPrice instance) =>
    <String, dynamic>{
      'trainCode': instance.trainCode,
      'seatTypeCode': instance.seatTypeCode,
      'seatTypeName': instance.seatTypeName,
      'trainClassCode': instance.trainClassCode,
      'trainClassName': instance.trainClassName,
      'price': instance.price,
      'startStationTelecode': instance.startStationTelecode,
      'endStationTelecode': instance.endStationTelecode,
    };

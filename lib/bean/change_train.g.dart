// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'change_train.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChangeTrain _$ChangeTrainFromJson(Map<String, dynamic> json) {
  return ChangeTrain(
    firstTrainCode: json['firstTrainCode'] as String,
    firstTrainArriveTime: json['firstTrainArriveTime'] as String,
    lastTrainCode: json['lastTrainCode'] as String,
    lastTrainStartTime: json['lastTrainStartTime'] as String,
    changeStation: json['changeStation'] as String,
    interval: json['interval'] as num,
    firstTrain: Train.fromJson(json['firstTrain'] as Map<String, dynamic>),
    lastTrain: Train.fromJson(json['lastTrain'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$ChangeTrainToJson(ChangeTrain instance) =>
    <String, dynamic>{
      'firstTrainCode': instance.firstTrainCode,
      'firstTrainArriveTime': instance.firstTrainArriveTime,
      'lastTrainCode': instance.lastTrainCode,
      'lastTrainStartTime': instance.lastTrainStartTime,
      'changeStation': instance.changeStation,
      'firstTrain': instance.firstTrain,
      'lastTrain': instance.lastTrain,
      'interval': instance.interval,
    };

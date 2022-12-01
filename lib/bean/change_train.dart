import 'package:json_annotation/json_annotation.dart';
import 'package:train/bean/train.dart';

part 'change_train.g.dart';

@JsonSerializable()
class ChangeTrain {
  String firstTrainCode;
  String firstTrainArriveTime;
  String lastTrainCode;
  String lastTrainStartTime;
  String changeStation;
  Train firstTrain;
  Train lastTrain;
  num interval;

  ChangeTrain({required this.firstTrainCode, required this.firstTrainArriveTime, required this.lastTrainCode, required this.lastTrainStartTime, required this.changeStation, required this.interval, required this.firstTrain, required this.lastTrain});

  factory ChangeTrain.fromJson(Map<String, dynamic> json) => _$ChangeTrainFromJson(json);

  Map<String, dynamic> toJson() => _$ChangeTrainToJson(this);
}


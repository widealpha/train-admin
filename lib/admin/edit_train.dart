import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:train/api/api.dart';
import 'package:train/bean/coach.dart';
import 'package:train/bean/train.dart';
import 'package:train/bean/train_station.dart';

class EditTrainPage extends StatefulWidget {
  final String stationTrainCode;

  const EditTrainPage({Key? key, required this.stationTrainCode})
      : super(key: key);

  @override
  _EditTrainPageState createState() => _EditTrainPageState();
}

class _EditTrainPageState extends State<EditTrainPage> {
  Map<String, String> seatTypeMapper = {};
  List<Coach> coachList = [];
  List<TrainStation> trainStationList = [];
  late Train train;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('编辑列车: ${widget.stationTrainCode}'),
      ),
      body: buildBody(context),
    );
  }

  Widget buildBody(BuildContext context) {
    if (loading) {
      return Center(child: CircularProgressIndicator());
    } else {
      return Row(
        children: [
          Expanded(
              child: Column(
            children: [
              Text('运行状态'),
              Divider(),
              ListTile(
                leading: Icon(
                  Icons.train,
                  color: isLate() ? Colors.deepOrange : Colors.blue,
                  size: 48,
                ),
                title: Text(
                  '始发站--${getStationName(train.startStationTelecode)}\n'
                  '终点站--${getStationName(train.endStationTelecode)}',
                  style: TextStyle(color: Colors.blue),
                ),
                trailing: isRunning()
                    ? Icon(
                        Icons.check_circle,
                        color: Colors.green,
                      )
                    : Icon(
                        Icons.remove_circle_rounded,
                        color: Colors.red,
                      ),
              ),
              Divider(),
              Expanded(
                  child: ListView.builder(
                itemBuilder: (c, i) {
                  TrainStation station = trainStationList[i];
                  return ListTile(
                    key: ValueKey(trainStationList[i]),
                    leading: Text('${i + 1}'),
                    title: Text(getStationName(station.stationTelecode)),
                    subtitle: Text(
                        '正点时间:${station.arriveTime.substring(0, 5)}-${station.startTime.substring(0, 5)}'
                        '\n${isLate() ? '晚点时间:${station.updateArriveTime ?? station.arriveTime.substring(0, 5)}'
                            '-${station.updateStartTime ?? station.startTime.substring(0, 5)}' : ''}'),
                    trailing: TextButton(
                        onPressed: () {
                          updateTrainStatus(station);
                        },
                        child: Text('编辑')),
                  );
                },
                itemCount: trainStationList.length,
              )),
              Row(
                children: [
                  Expanded(
                      child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                        onPressed: !isRunning()
                            ? null
                            : () async {
                                await TrainApi.stopTrain(
                                    widget.stationTrainCode);
                                fetchData();
                              },
                        child: Text('停运')),
                  )),
                  Expanded(
                      child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                        onPressed: isRunning()
                            ? null
                            : () async {
                                await TrainApi.startTrain(
                                    widget.stationTrainCode);
                                fetchData();
                              },
                        child: Text('启运')),
                  ))
                ],
              )
            ],
          )),
          VerticalDivider(),
          Expanded(
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('车厢管理'),
                    TextButton.icon(
                        onPressed: () {
                          addCoach();
                        },
                        icon: Icon(Icons.add_circle_outline_rounded),
                        label: Text('添加车厢'))
                  ],
                ),
                Divider(),
                Expanded(
                    child: ListView.separated(
                  itemBuilder: (c, i) => ListTile(
                    leading: Text('${coachList[i].coachNo}车厢'),
                    title: Text('${seatTypeMapper[coachList[i].seatTypeCode]}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextButton(
                            onPressed: () async {
                              await CoachApi.deleteCoach(coachList[i].coachId);
                              fetchData();
                            },
                            child: Text('删除')),
                        TextButton(
                            onPressed: () {
                              updateCoach(coachList[i]);
                            },
                            child: Text('编辑'))
                      ],
                    ),
                  ),
                  itemCount: coachList.length,
                  separatorBuilder: (BuildContext context, int index) =>
                      Divider(),
                ))
              ],
            ),
          ),
          VerticalDivider(),
          Expanded(
            child: Column(children: [
              Text('列车到站管理'),
              Divider(),
              Expanded(
                  child: ListView.separated(
                itemBuilder: (c, i) => ListTile(
                  leading: Text('${i + 1}'),
                  title: Text(
                      '${getStationName(trainStationList[i].stationTelecode)}->${i < trainStationList.length - 1 ? getStationName(trainStationList[i + 1].stationTelecode) : '终点'}'),
                  trailing: TextButton(
                      onPressed: () async {
                        await CoachApi.deleteCoach(coachList[i].coachId);
                        fetchData();
                      },
                      child: Text('删除')),
                ),
                itemCount: trainStationList.length,
                separatorBuilder: (context, index) => Column(
                  children: [
                    Divider(),
                    TextButton.icon(
                        onPressed: () {},
                        icon: Icon(Icons.add_circle_outline_rounded),
                        label: Text('添加')),
                    Divider(),
                  ],
                ),
              ))
            ]),
          )
        ],
      );
    }
  }

  Future<void> updateTrainStatus(TrainStation trainStation) async {
    final TextEditingController startController = TextEditingController(
        text: trainStation.updateStartTime?.substring(0, 5) ??
            trainStation.startTime.substring(0, 5));
    final TextEditingController arriveController = TextEditingController(
        text: trainStation.updateArriveTime?.substring(0, 5) ??
            trainStation.arriveTime.substring(0, 5));
    Get.dialog(StatefulBuilder(
        builder: (c, state) => AlertDialog(
              title: Text('编辑正晚点信息'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: arriveController,
                      readOnly: true,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: '更新延误到达时间',
                          labelText: '更新延误到达时间',
                          suffixIcon: TextButton.icon(
                            onPressed: () async {
                              late int hour;
                              late int minute;
                              if (trainStation.updateArriveTime == null) {
                                hour = int.tryParse(
                                    trainStation.arriveTime.substring(0, 2))!;
                                minute = int.tryParse(
                                    trainStation.arriveTime.substring(0, 2))!;
                              } else {
                                hour = int.tryParse(trainStation
                                    .updateArriveTime
                                    .substring(0, 2))!;
                                minute = int.tryParse(trainStation
                                    .updateArriveTime
                                    .substring(0, 2))!;
                              }
                              TimeOfDay t =
                                  TimeOfDay(hour: hour, minute: minute);
                              t = await Get.dialog(
                                  TimePickerDialog(initialTime: t));
                              arriveController.text = t.format(context);
                            },
                            icon: Icon(Icons.edit_rounded),
                            label: Text('编辑'),
                          )),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: startController,
                      readOnly: true,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: '更新延误出发时间',
                          labelText: '更新延误出发时间',
                          suffixIcon: TextButton.icon(
                            onPressed: () async {
                              late int hour;
                              late int minute;
                              if (trainStation.updateStartTime == null) {
                                hour = int.tryParse(
                                    trainStation.startTime.substring(0, 2))!;
                                minute = int.tryParse(
                                    trainStation.startTime.substring(0, 2))!;
                              } else {
                                hour = int.tryParse(trainStation.updateStartTime
                                    .substring(0, 2))!;
                                minute = int.tryParse(trainStation
                                    .updateStartTime
                                    .substring(0, 2))!;
                              }
                              TimeOfDay t =
                                  TimeOfDay(hour: hour, minute: minute);
                              t = await Get.dialog(
                                  TimePickerDialog(initialTime: t));
                              startController.text = t.format(context);
                            },
                            icon: Icon(Icons.edit_rounded),
                            label: Text('编辑'),
                          )),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                    onPressed: () async {
                      await TrainApi.updateStartTime(
                          trainStation.stationTrainCode,
                          trainStation.stationTelecode,
                          trainStation.stationNo,
                          startController.text + ':00');
                      await TrainApi.updateArriveTime(
                          trainStation.stationTrainCode,
                          trainStation.stationTelecode,
                          trainStation.stationNo,
                          arriveController.text + ':00');
                      Get.back();
                      fetchData();
                    },
                    child: Text('确认')),
                TextButton(
                    onPressed: () {
                      Get.back();
                    },
                    child: Text('取消')),
                TextButton(
                    onPressed: () async {
                      await TrainApi.updateStartTime(
                          trainStation.stationTrainCode,
                          trainStation.stationTelecode,
                          trainStation.stationNo,
                          null);
                      await TrainApi.updateArriveTime(
                          trainStation.stationTrainCode,
                          trainStation.stationTelecode,
                          trainStation.stationNo,
                          null);
                      Get.back();
                      fetchData();
                    },
                    child: Text('清空')),
              ],
            )));
  }

  Future<void> updateCoach(Coach coach) async {
    final TextEditingController typeController =
        TextEditingController(text: seatTypeMapper[coach.seatTypeCode]);
    final TextEditingController seatNumController =
        TextEditingController(text: '${coach.seatCount}');
    Get.dialog(StatefulBuilder(
        builder: (c, state) => AlertDialog(
              title: Text('编辑座位信息'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: typeController,
                      readOnly: true,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: '更新座位种类',
                          labelText: '更新座位种类',
                          suffixIcon: TextButton.icon(
                            onPressed: () async {
                              String s = await Get.dialog(SimpleDialog(
                                children: seatTypeMapper.keys
                                    .map((e) => RadioListTile(
                                        title: Text('$e: ${seatTypeMapper[e]}'),
                                        value: e,
                                        groupValue: '',
                                        onChanged: (v) {
                                          Get.back(result: v);
                                        }))
                                    .toList(),
                              ));
                              typeController.text = seatTypeMapper[s]!;
                            },
                            icon: Icon(Icons.edit_rounded),
                            label: Text('编辑'),
                          )),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: seatNumController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: '更新座位数量',
                        labelText: '更新座位数量',
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                    onPressed: () async {
                      late String s;
                      seatTypeMapper.forEach((key, value) {
                        if (value == typeController.text) {
                          s = key;
                        }
                      });
                      CoachApi.updateCoach(
                          coach.coachId, num.parse(seatNumController.text), s);
                      Get.back();
                      fetchData();
                    },
                    child: Text('确认')),
                TextButton(
                    onPressed: () {
                      Get.back();
                    },
                    child: Text('取消')),
              ],
            )));
  }

  Future<void> addCoach() async {
    final TextEditingController typeController = TextEditingController();
    final TextEditingController coachNoController =
        TextEditingController(text: '1');
    final TextEditingController seatNumController =
        TextEditingController(text: '64');
    Get.dialog(StatefulBuilder(
        builder: (c, state) => AlertDialog(
              title: Text('添加座位信息'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: typeController,
                      readOnly: true,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: '座位种类',
                          labelText: '座位种类',
                          suffixIcon: TextButton.icon(
                            onPressed: () async {
                              String s = await Get.dialog(SimpleDialog(
                                children: seatTypeMapper.keys
                                    .map((e) => RadioListTile(
                                        title: Text('$e: ${seatTypeMapper[e]}'),
                                        value: e,
                                        groupValue: '',
                                        onChanged: (v) {
                                          Get.back(result: v);
                                        }))
                                    .toList(),
                              ));
                              typeController.text = seatTypeMapper[s]!;
                            },
                            icon: Icon(Icons.edit_rounded),
                            label: Text('编辑'),
                          )),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: seatNumController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: '座位数量',
                        labelText: '座位数量',
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: coachNoController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: '车厢号',
                        labelText: '车厢号',
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                    onPressed: () async {
                      late String s;
                      seatTypeMapper.forEach((key, value) {
                        if (value == typeController.text) {
                          s = key;
                        }
                      });
                      await CoachApi.addCoach(
                          num.parse(coachNoController.text),
                          num.parse(seatNumController.text),
                          s,
                          widget.stationTrainCode);
                      Get.back();
                      fetchData();
                    },
                    child: Text('确认')),
                TextButton(
                    onPressed: () {
                      Get.back();
                    },
                    child: Text('取消')),
              ],
            )));
  }

  String getStationName(String? telecode) {
    if (telecode == null) {
      return '---';
    }
    return StationApi.cachedStationInfo(telecode)?.name ?? '---';
  }

  void fetchData() async {
    setState(() {
      loading = true;
    });
    train = (await TrainApi.trainInfo(widget.stationTrainCode))!;
    coachList = await CoachApi.trainCoachList(widget.stationTrainCode);
    trainStationList = await TrainApi.trainStations(widget.stationTrainCode);
    var seatTypes = await SeatTypeApi.allSeatTypes();
    seatTypes.forEach((element) {
      seatTypeMapper[element.seatTypeCode!] = element.seatTypeName!;
    });
    setState(() {
      loading = false;
    });
  }

  bool isLate() {
    for (TrainStation s in trainStationList) {
      if (s.updateArriveTime != null || s.updateStartTime != null) {
        return true;
      }
    }
    return false;
  }

  bool isRunning() {
    try {
      return DateTime.parse(train.stopDate!).isAfter(DateTime.now());
    } catch (e) {
      return false;
    }
  }
}

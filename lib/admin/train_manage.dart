import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:train/admin/edit_train.dart';
import 'package:train/api/api.dart';
import 'package:train/bean/station.dart';
import 'package:train/ui/station_page.dart';

class TrainManagePage extends StatefulWidget {
  const TrainManagePage({Key? key}) : super(key: key);

  @override
  _TrainManagePageState createState() => _TrainManagePageState();
}

class _TrainManagePageState extends State<TrainManagePage> {
  TextEditingController _controller = TextEditingController();
  TextEditingController _addTrainController = TextEditingController();
  TextEditingController _startStationController = TextEditingController();
  TextEditingController _startTimeController = TextEditingController();
  TextEditingController _endStationController = TextEditingController();
  TextEditingController _endTimeController = TextEditingController();
  TextEditingController _arriveDayDifferController = TextEditingController();
  late String startStation;
  late String endStation;
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  bool loading = true;
  List<String> trainCodeList = [];

  @override
  void initState() {
    fetchData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? Center(child: CircularProgressIndicator())
        : Scaffold(
            body: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: Get.width,
                    child: Card(
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: '请输入列车号搜索列车',
                            suffixIcon: TextButton.icon(
                              onPressed: () {
                                if (trainCodeList
                                    .contains(_controller.text.toUpperCase())) {
                                  Get.to(
                                    () => EditTrainPage(
                                        trainCode:
                                            _controller.text.toUpperCase()),
                                  );
                                } else {
                                  BotToast.showText(text: '列车数据不存在');
                                }
                              },
                              icon: Icon(Icons.search_rounded),
                              label: Text('搜索列车'),
                            )),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    controller: ScrollController(),
                    itemBuilder: (c, i) {
                      return Row(
                        children: [0, 1, 2, 3, 4]
                            .map((n) => (i + n) < trainCodeList.length
                                ? Expanded(
                                    child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: InkWell(
                                      child: Chip(
                                        label: Text(
                                            trainCodeList[i * 5 + n]),
                                        labelStyle:
                                            TextStyle(color: Colors.white),
                                        backgroundColor: Colors.blue,
                                      ),
                                      onTap: () {
                                        Get.to(() => EditTrainPage(
                                            trainCode:
                                                trainCodeList[
                                                    i * 5 + n]));
                                      },
                                    ),
                                  ))
                                : Container())
                            .toList(),
                      );
                    },
                    itemCount: trainCodeList.length ~/ 5,
                  ),
                )
              ],
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                Get.dialog(AlertDialog(
                  title: Text('新建火车'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          controller: _addTrainController,
                          readOnly: false,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: '火车号',
                              labelText: '火车号',
                              suffixIcon: TextButton.icon(
                                onPressed: () async {},
                                icon: Icon(Icons.edit_rounded),
                                label: Text('编辑'),
                              )),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          controller: _startStationController,
                          readOnly: true,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: '始发站',
                            labelText: '始发站',
                            suffix: TextButton(
                                onPressed: () async {
                                  Station? s = await Get.to(() => StationPage(),
                                      preventDuplicates: false);
                                  if (s != null) {
                                    _startStationController.text = s.name;
                                    startStation = s.telecode;
                                  }
                                },
                                child: Text('选择')),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          controller: _startTimeController,
                          readOnly: true,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: '出发时间',
                            labelText: '出发时间',
                            suffix: TextButton(
                                onPressed: () async {
                                  TimeOfDay? t = await Get.dialog(
                                      TimePickerDialog(
                                          initialTime:
                                              startTime ?? TimeOfDay.now()));

                                  if (t != null) {
                                    startTime = t;
                                    _startTimeController.text =
                                        t.format(context);
                                  }
                                },
                                child: Text('选择')),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          controller: _endStationController,
                          readOnly: true,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: '终点站',
                            labelText: '终点站',
                            suffix: TextButton(
                                onPressed: () async {
                                  Station? s = await Get.to(() => StationPage(),
                                      preventDuplicates: false);
                                  if (s != null) {
                                    _endStationController.text = s.name;
                                    endStation = s.telecode;
                                  }
                                },
                                child: Text('选择')),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          controller: _endTimeController,
                          readOnly: true,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: '到达时间',
                            labelText: '到达时间',
                            suffix: TextButton(
                                onPressed: () async {
                                  TimeOfDay? t = await Get.dialog(
                                      TimePickerDialog(
                                          initialTime:
                                              endTime ?? TimeOfDay.now()));

                                  if (t != null) {
                                    endTime = t;
                                    _endTimeController.text = t.format(context);
                                  }
                                },
                                child: Text('选择')),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          controller: _arriveDayDifferController,
                          readOnly: false,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: '到达相隔天数',
                            labelText: '到达相隔天数',
                          ),
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                        onPressed: () async {
                          if (trainCodeList
                              .contains(_addTrainController.text)) {
                            BotToast.showText(text: '已存在列车');
                            return;
                          }
                          bool b = await TrainApi.addTrain(
                              _addTrainController.text,
                              startStation,
                              endStation,
                              startTime!.format(context),
                              endTime!.format(context),
                              int.tryParse(_arriveDayDifferController.text));
                          if (!b) {
                            BotToast.showText(text: '新建失败');
                          } else {
                            Get.back();
                            Get.to(() => EditTrainPage(
                                trainCode: _addTrainController.text));
                            fetchData();
                          }
                        },
                        child: Text('确认')),
                    TextButton(
                        onPressed: () {
                          Get.back();
                        },
                        child: Text('取消')),
                  ],
                ));
              },
              child: Icon(Icons.add),
            ),
          );
  }

  void fetchData() async {
    loading = true;
    setState(() {});
    trainCodeList = await TrainApi.allTrainCode();
    loading = false;
    setState(() {});
  }

  String getStationName(String? telecode) {
    if (telecode == null) {
      return '---';
    }
    return StationApi.cachedStationInfo(telecode)?.name ?? '---';
  }
}

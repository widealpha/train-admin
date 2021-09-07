import 'dart:ui';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:train/api/api.dart';
import 'package:train/bean/system_setting.dart';

class AdminSettingPage extends StatefulWidget {
  ///是否在打开设置界面后自动弹出更新窗口
  final bool showUpdate;

  AdminSettingPage({this.showUpdate = false});

  @override
  State<StatefulWidget> createState() {
    return _AdminSettingPageState();
  }
}

class _AdminSettingPageState extends State<AdminSettingPage> {
  late SystemSetting setting;
  bool loading = true;
  TextEditingController _controller = TextEditingController();
  TextEditingController _trainClassController = TextEditingController();
  TextEditingController _seatTypeController = TextEditingController();
  Map<String, String> trainClassMap = {};
  Map<String, String> seatTypeMap = {};
  late String trainClass;
  late String seatType;

  @override
  void initState() {
    super.initState();
    fetchSetting();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: loading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: SwitchListTile(
                        title: Text('系统状态'),
                        subtitle: Text(setting.start == 1 ? '启动' : '关闭'),
                        value: setting.start == 1,
                        onChanged: (value) async {
                          setting.start = (value ? 1 : 0);
                          SystemApi.updateSystemSetting(setting);
                          setState(() {});
                        },
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          controller: _controller,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: '中转换乘搜索返回的最大数据量',
                              labelText: '中转换乘搜索返回的最大数据量',
                              suffixIcon: TextButton.icon(
                                onPressed: () {
                                  if (_controller.text.isNotEmpty) {
                                    setting.maxTransferCalculate =
                                        int.tryParse(_controller.text) ?? 20;
                                    SystemApi.updateSystemSetting(setting);
                                  }
                                },
                                icon: Icon(Icons.upgrade_rounded),
                                label: Text('提交'),
                              )),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          controller: _trainClassController,
                          readOnly: false,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: '火车种类名称调整',
                              labelText: '火车种类名称调整',
                              prefix: TextButton(
                                  onPressed: () async {
                                    String? s = await Get.dialog(SimpleDialog(
                                      children: trainClassMap.keys
                                          .map((e) => RadioListTile(
                                              title: Text(
                                                  '$e: ${trainClassMap[e]}'),
                                              value: e,
                                              groupValue: '',
                                              onChanged: (v) {
                                                Get.back(result: v);
                                              }))
                                          .toList(),
                                    ));
                                    if (s != null) {
                                      setState(() {
                                        trainClass = s;
                                        _trainClassController.text =
                                            trainClassMap[trainClass]!;
                                      });
                                    }
                                  },
                                  child: Text(trainClassMap[trainClass]!)),
                              suffix: TextButton.icon(
                                  onPressed: () async {
                                    bool b = await TrainClassApi
                                        .renameTrainClassName(trainClass,
                                            _trainClassController.text);
                                    if (!b) {
                                      BotToast.showText(text: '更新失败');
                                    }
                                  },
                                  icon: Icon(Icons.update),
                                  label: Text('更新'))),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          controller: _seatTypeController,
                          readOnly: false,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: '座位名称调整',
                              labelText: '座位名称调整',
                              prefix: TextButton(
                                  onPressed: () async {
                                    String? s = await Get.dialog(SimpleDialog(
                                      children: seatTypeMap.keys
                                          .map((e) => RadioListTile(
                                              title:
                                                  Text('$e: ${seatTypeMap[e]}'),
                                              value: e,
                                              groupValue: '',
                                              onChanged: (v) {
                                                Get.back(result: v);
                                              }))
                                          .toList(),
                                    ));
                                    if (s != null) {
                                      setState(() {
                                        seatType = s;
                                        _seatTypeController.text =
                                            seatTypeMap[seatType]!;
                                      });
                                    }
                                  },
                                  child: Text(seatTypeMap[seatType]!)),
                              suffix: TextButton.icon(
                                  onPressed: () async {
                                    bool b =
                                        await SeatTypeApi.renameSeatTypeName(
                                            seatType, _seatTypeController.text);
                                    if (!b) {
                                      BotToast.showText(text: '更新失败');
                                    }
                                  },
                                  icon: Icon(Icons.update),
                                  label: Text('更新'))),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
    );
  }

  void fetchSetting() async {
    setState(() {
      loading = true;
    });
    setting = (await SystemApi.getSystemSetting())!;
    _controller.text = setting.maxTransferCalculate.toString();
    (await SeatTypeApi.allSeatTypes()).forEach((type) {
      seatTypeMap[type.seatTypeCode!] = type.seatTypeName!;
      seatType = type.seatTypeCode!;
    });
    (await TrainClassApi.allTrainClasses()).forEach((c) {
      trainClassMap[c.trainClassCode!] = c.trainClassName!;
      trainClass = c.trainClassCode!;
    });
    _trainClassController.text = trainClassMap[trainClass]!;
    _seatTypeController.text = seatTypeMap[seatType]!;

    setState(() {
      loading = false;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }
}

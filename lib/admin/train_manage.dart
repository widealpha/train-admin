import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:train/admin/edit_train.dart';
import 'package:train/api/api.dart';

class TrainManagePage extends StatefulWidget {
  const TrainManagePage({Key? key}) : super(key: key);

  @override
  _TrainManagePageState createState() => _TrainManagePageState();
}

class _TrainManagePageState extends State<TrainManagePage> {
  TextEditingController _controller = TextEditingController();
  bool loading = true;
  List<String> stationTrainCodeList = [];

  @override
  void initState() {
    fetchData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? Center(child: CircularProgressIndicator())
        : Column(
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
                              if (stationTrainCodeList
                                  .contains(_controller.text.toUpperCase())) {
                                Get.to(
                                  () => EditTrainPage(
                                      stationTrainCode:
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
                  itemBuilder: (c, i) {
                    return Row(
                      children: [0, 1, 2, 3, 4]
                          .map((n) => i + n < stationTrainCodeList.length
                              ? Expanded(
                                  child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: InkWell(
                                    child: Chip(
                                      label: Text(stationTrainCodeList[i + n]),
                                      labelStyle:
                                          TextStyle(color: Colors.white),
                                      backgroundColor: Colors.blue,
                                    ),
                                    onTap: () {
                                      Get.to(() => EditTrainPage(
                                          stationTrainCode:
                                              stationTrainCodeList[i + n]));
                                    },
                                  ),
                                ))
                              : Container())
                          .toList(),
                    );
                  },
                  itemCount: stationTrainCodeList.length ~/ 5,
                ),
              )
            ],
          );
  }

  void fetchData() async {
    loading = true;
    setState(() {});
    stationTrainCodeList = await TrainApi.allStationTrainCode();
    loading = false;
    setState(() {});
  }
}

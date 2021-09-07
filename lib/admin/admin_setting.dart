import 'dart:ui';

import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    fetchSetting();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('设置'),
      ),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : Container(
              child: Row(
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
            ),
    );
  }

  void fetchSetting() async {
    setting = (await SystemApi.getSystemSetting())!;
    loading = false;
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    IsolateNameServer.removePortNameMapping('downloader_send_port');
  }
}

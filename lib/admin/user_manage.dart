import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:train/api/api.dart';
import 'package:train/bean/passenger.dart';
import 'package:train/bean/user_info.dart';

class UserManagePage extends StatefulWidget {
  const UserManagePage({Key? key}) : super(key: key);

  @override
  _UserManagePageState createState() => _UserManagePageState();
}

class _UserManagePageState extends State<UserManagePage> {
  bool loading = true;
  List<Passenger> passengers = [];
  List<UserInfo> users = [];

  @override
  void initState() {
    fetchData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? Center(child: CircularProgressIndicator())
        : Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text('用户管理'),
                    Divider(),
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('用户Id'),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('用户昵称'),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('实名状态'),
                          ),
                        ),
                        TextButton(onPressed: () {}, child: Text('              ')),
                      ],
                    ),
                    Expanded(
                      child: ListView.separated(
                        controller: ScrollController(),
                        itemBuilder: (c, i) => Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(users[i].userId.toString()),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(users[i].nickname!),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(users[i].selfPassengerId == null
                                    ? '未实名'
                                    : '已实名'),
                              ),
                            ),
                            TextButton(
                                onPressed: () async {
                                  if (await UserApi.deleteUser(users[i].userId!)){
                                    BotToast.showText(text: '注销成功');
                                    fetchData();
                                  } else {
                                    BotToast.showText(text: '注销失败');
                                  }
                                },
                                child: Text('注销用户')),
                          ],
                        ),
                        itemCount: users.length,
                        separatorBuilder: (_, __) => Divider(),
                      ),
                    )
                  ],
                ),
              ),
              VerticalDivider(),
              Expanded(
                child: Column(
                  children: [
                    Text('乘客管理'),
                    Divider(),
                    Expanded(
                      child: ListView.separated(
                        controller: ScrollController(),
                        itemBuilder: (c, i) {
                          Passenger p = passengers[i];
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                  child: Text(p.name!,
                                      textAlign: TextAlign.center)),
                              Expanded(
                                flex: 2,
                                child: Text(p.idCardNo!,
                                    textAlign: TextAlign.center),
                              ),
                              Expanded(
                                child: Text(p.student ?? false ? '学生' : '成人',
                                    style: TextStyle(color: Colors.blue)),
                              ),
                              Text(
                                p.verified ?? false ? '正常' : '失信状态',
                                style: TextStyle(
                                    color: p.verified ?? false
                                        ? Colors.green
                                        : Colors.red),
                              ),
                              TextButton(
                                  onPressed: () async {
                                    await PassengerApi.alterPassenger(
                                        p.passengerId!);
                                    fetchData();
                                  },
                                  child: Text('   取消/标记失信')),
                            ],
                          );
                        },
                        itemCount: passengers.length,
                        separatorBuilder: (_, __) => Divider(),
                      ),
                    )
                  ],
                ),
              ),
            ],
          );
  }

  Future<void> fetchData() async {
    setState(() {
      loading = true;
    });
    users = await UserApi.allUserInfo();
    passengers = await PassengerApi.adminAllPassengers();
    setState(() {
      loading = false;
    });
  }
}

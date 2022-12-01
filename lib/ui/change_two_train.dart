import 'package:bot_toast/bot_toast.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:train/api/api.dart';
import 'package:train/bean/change_train.dart';
import 'package:train/bean/remain_seat.dart';
import 'package:train/bean/station.dart';
import 'package:train/bean/ticket.dart';
import 'package:train/bean/train.dart';
import 'package:train/bean/train_price.dart';
import 'package:train/bean/train_station.dart';
import 'package:train/ui/order_confirm_two.dart';
import 'package:train/ui/train_page.dart';
import 'package:train/util/date_util.dart';

class ChangeTwoTrainPage extends StatefulWidget {
  final Ticket ticket;
  final DateTime date;
  final bool onlyHighWay;
  final bool student;

  const ChangeTwoTrainPage(
      {Key? key,
      required this.ticket,
      required this.date,
      required this.onlyHighWay,
      required this.student})
      : super(key: key);

  @override
  _ChangeTwoTrainPageState createState() => _ChangeTwoTrainPageState();
}

class _ChangeTwoTrainPageState extends State<ChangeTwoTrainPage> {
  final RefreshController _controller = RefreshController();
  bool _loading = true;
  late Ticket _ticket = widget.ticket;
  late DateTime _date = widget.date;
  late bool _canBeforeDay;
  late bool _canAfterDay;
  List<ChangeTrain> trains = [];
  List<ChangeTrain> filteredTrains = [];
  bool sortByEarly = true;
  bool sortByLate = false;
  bool sortByTimeShort = false;
  bool sortByTimeLong = false;
  late bool onlyHighWay = widget.onlyHighWay;
  late bool student = widget.student;

  @override
  void initState() {
    super.initState();
    changeDate(_date);
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: GestureDetector(
            onTap: () {
              Get.dialog(AlertDialog(
                title: Text('温馨提醒'),
                content: Text('确认交换发到站吗?'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Get.back();
                    },
                    child: Text('取消'),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        Station? station = _ticket.startStation;
                        _ticket.startStation = _ticket.endStation;
                        _ticket.endStation = station;

                        String? temp = _ticket.startStationTelecode;
                        _ticket.startStationTelecode =
                            _ticket.endStationTelecode;
                        _ticket.endStationTelecode = temp;
                      });
                      Get.back();
                      fetchData();
                    },
                    child: Text('确定'),
                  ),
                ],
              ));
            },
            child: Text(
                '${_ticket.startStation!.name}<>${_ticket.endStation!.name}')),
        bottom: PreferredSize(
            preferredSize: Size.fromHeight(40),
            child: Container(
              padding: EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                      child: TextButton(
                    onPressed: _canBeforeDay
                        ? () {
                            changeDate(_date.subtract(Duration(days: 1)));
                            fetchData();
                          }
                        : null,
                    child: Text(
                      '前一天',
                      style: TextStyle(color: Colors.white),
                    ),
                  )),
                  Expanded(
                      child: TextButton(
                    style: TextButton.styleFrom(backgroundColor: Colors.white),
                    onPressed: () async {
                      DateTime? time = await showDatePicker(
                          context: context,
                          initialDate: _date.isAfter(DateTime.now())
                              ? _date
                              : DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(Duration(days: 10)));
                      if (time != null) {
                        setState(() {
                          changeDate(time);
                          fetchData();
                        });
                      }
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                              '${DateUtil.date(_date)} (${DateUtil.weekday(_date)})',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 18)),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Icon(
                            Icons.calendar_today_rounded,
                            color: Colors.blueAccent,
                          ),
                        ),
                      ],
                    ),
                  )),
                  Expanded(
                      child: TextButton(
                    onPressed: _canAfterDay
                        ? () {
                            changeDate(_date.add(Duration(days: 1)));
                            fetchData();
                          }
                        : null,
                    child: Text(
                      '后一天',
                      style: TextStyle(color: Colors.white),
                    ),
                  )),
                ],
              ),
            )),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              fetchData();
            },
          )
        ],
      ),
      body: buildBody(context),
    );
  }

  Widget buildBody(BuildContext context) {
    if (_loading) {
      return Center(child: CircularProgressIndicator());
    } else if (filteredTrains.isEmpty) {
      return Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Text.rich(
              TextSpan(children: [
                TextSpan(text: '很抱歉没有找到从 '),
                TextSpan(
                    text: _ticket.startStation!.name,
                    style: TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: ' 到 '),
                TextSpan(
                    text: _ticket.endStation!.name,
                    style: TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: ' 的换乘列车\n'),
              ]),
              style: TextStyle(fontSize: 18),
            ),
            TextButton(
                style: TextButton.styleFrom(backgroundColor: Colors.blue),
                onPressed: () {
                  Get.back();
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Text('返回',
                      style: TextStyle(color: Colors.white, fontSize: 18)),
                )),
            Padding(padding: EdgeInsets.all(12)),
          ],
        ),
      );
    } else {
      return Column(
        children: [
          Expanded(
            child: SmartRefresher(
                controller: _controller,
                child: ListView.builder(
                  itemBuilder: (c, i) {
                    return ListTile(
                      key: ValueKey(filteredTrains[i]),
                      title: ChangeTwoTrainCard(
                        changeTrain: filteredTrains[i],
                        ticket: _ticket,
                        date: _date,
                        student: student,
                      ),
                    );
                  },
                  itemCount: filteredTrains.length,
                )),
          ),
          Divider(height: 1, thickness: 1),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        seePrice = !seePrice;
                      });
                    },
                    child: Column(
                      children: [
                        seePrice
                            ? Icon(
                                Icons.price_check_rounded,
                                color: Colors.blue,
                                size: 32,
                              )
                            : Icon(
                                Icons.credit_card_rounded,
                                color: Colors.blue,
                                size: 32,
                              ),
                        seePrice
                            ? Text('显示价格', style: TextStyle(fontSize: 12))
                            : Text('显示余票', style: TextStyle(fontSize: 12))
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (sortByTimeShort) {
                        sortByTimeLong = true;
                        sortByTimeShort = false;
                      } else {
                        sortByTimeLong = false;
                        sortByTimeShort = true;
                      }
                      sortByEarly = false;
                      sortByLate = false;
                      filteredTrains = filter(trains);
                      setState(() {});
                    },
                    child: Column(
                      children: [
                        Icon(
                          Icons.hourglass_bottom_rounded,
                          color: (sortByTimeShort || sortByTimeLong)
                              ? Colors.blue
                              : Colors.grey,
                          size: 32,
                        ),
                        Text('耗时最${sortByTimeShort ? '短' : '长'}',
                            style: TextStyle(
                              fontSize: 12,
                              color: (sortByTimeShort || sortByTimeLong)
                                  ? Colors.blue
                                  : Colors.grey,
                            ))
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (sortByEarly) {
                        sortByLate = true;
                        sortByEarly = false;
                      } else {
                        sortByLate = false;
                        sortByEarly = true;
                      }
                      sortByTimeLong = false;
                      sortByTimeShort = false;
                      filteredTrains = filter(trains);
                      setState(() {});
                    },
                    child: Column(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          color: (sortByLate || sortByEarly)
                              ? Colors.blue
                              : Colors.grey,
                          size: 32,
                        ),
                        Text('最${sortByLate ? '晚' : '早'}发车',
                            style: TextStyle(
                              fontSize: 12,
                              color: (sortByLate || sortByEarly)
                                  ? Colors.blue
                                  : Colors.grey,
                            ))
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      onlyHighWay = !onlyHighWay;
                      filteredTrains = filter(trains);
                      setState(() {});
                    },
                    child: Column(
                      children: [
                        Icon(
                          Icons.directions_train,
                          color: onlyHighWay ? Colors.blue : Colors.grey,
                          size: 32,
                        ),
                        Text('只查高铁/动车',
                            style: TextStyle(
                              fontSize: 12,
                              color: onlyHighWay ? Colors.blue : Colors.grey,
                            ))
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      student = !student;
                      filteredTrains = filter(trains);
                      setState(() {});
                    },
                    child: Column(
                      children: [
                        Icon(
                          Icons.child_care_rounded,
                          color: student ? Colors.blue : Colors.grey,
                          size: 32,
                        ),
                        Text('学生票',
                            style: TextStyle(
                              fontSize: 12,
                              color: student ? Colors.blue : Colors.grey,
                            ))
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }
  }

  void changeDate(DateTime date) {
    DateTime now =
        DateTime.parse(DateTime.now().toIso8601String().substring(0, 10));
    _date = DateTime.parse(_date.toIso8601String().substring(0, 10));
    date = DateTime.parse(date.toIso8601String().substring(0, 10));
    _date = date;
    _canBeforeDay = _date.isAfter(now);
    _canAfterDay = _date.isBefore(now.add(Duration(days: 10)));
    setState(() {});
  }

  List<ChangeTrain> filter(List<ChangeTrain> trains) {
    List<ChangeTrain> list = List.from(trains);
    var nowString = DateTime.now().toIso8601String();
    if (_date.toIso8601String().substring(0, 10) ==
        nowString.substring(0, 10)) {
      list.removeWhere((element) =>
          getTrainStartTime(element).compareTo(nowString.substring(11, 19)) <=
          0);
    }

    if (sortByEarly) {
      list.sort((a, b) => getTrainStartTime(a).compareTo(getTrainStartTime(b)));
    } else if (sortByLate) {
      list.sort((a, b) => getTrainStartTime(b).compareTo(getTrainStartTime(a)));
    } else if (sortByTimeShort) {
      list.sort((a, b) =>
          DateUtil.timeInterval(getTrainStartTime(a), getTrainArriveTime(a))
              .compareTo(DateUtil.timeInterval(
                  getTrainStartTime(b), getTrainArriveTime(b))));
    } else {
      list.sort((a, b) =>
          DateUtil.timeInterval(getTrainStartTime(b), getTrainArriveTime(b))
              .compareTo(DateUtil.timeInterval(
                  getTrainStartTime(a), getTrainArriveTime(a))));
    }

    if (onlyHighWay) {
      list.removeWhere((element) =>
          element.firstTrain.trainClassCode != 'D' &&
          element.firstTrain.trainClassCode != '8' &&
          element.lastTrain.trainClassCode != 'D' &&
          element.lastTrain.trainClassCode != '8');
    }

    return list;
  }

  String getTrainStartTime(ChangeTrain train) {
    if (train.firstTrain.trainStations == null) {
      return '---';
    }
    for (TrainStation station in train.firstTrain.trainStations!) {
      if (station.stationTelecode == train.firstTrain.nowStartStationTelecode) {
        return station.startTime;
      }
    }
    return '---';
  }

  String getTrainArriveTime(ChangeTrain train) {
    if (train.lastTrain.trainStations == null) {
      return '---';
    }
    for (TrainStation station in train.lastTrain.trainStations!) {
      if (station.stationTelecode == train.lastTrain.nowEndStationTelecode) {
        if (station.arriveDayDiff - station.startDayDiff > 0) {
          return '${station.arriveTime}  + ${station.arriveDayDiff - station.startDayDiff}';
        }
        return station.arriveTime;
      }
    }
    return '---';
  }

  Future<void> fetchData() async {
    _loading = true;
    setState(() {});
    TrainApi.trainsBetweenWithChange(
            _ticket.startStationTelecode!,
            _ticket.endStationTelecode!,
            _date.toIso8601String().substring(0, 10))
        .then((list) {
      setState(() {
        trains = list;
        _loading = false;
        filteredTrains = filter(trains);
      });
    });

    setState(() {});
  }
}

class ChangeTwoTrainCard extends StatefulWidget {
  final Ticket ticket;
  final ChangeTrain changeTrain;
  final DateTime date;
  final bool student;

  const ChangeTwoTrainCard(
      {Key? key,
      required this.changeTrain,
      required this.ticket,
      required this.date,
      required this.student})
      : super(key: key);

  @override
  _ChangeTwoTrainCardState createState() => _ChangeTwoTrainCardState();
}

class _ChangeTwoTrainCardState extends State<ChangeTwoTrainCard> {
  late final ChangeTrain train = widget.changeTrain;
  late final List<Train> trains = [
    widget.changeTrain.firstTrain,
    widget.changeTrain.lastTrain
  ];
  late final Ticket ticket = widget.ticket;
  final ExpandableController _expandableController = ExpandableController();
  Map<Train, List<TrainPrice>> trainPriceList = {};
  Map<Train, List<RemainSeat>> remainSeatList = {};

  @override
  void initState() {
    super.initState();
    for (Train train in trains) {
      trainPriceList[train] = [];
      remainSeatList[train] = [];
    }
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpandablePanel(
        controller: _expandableController,
        theme: const ExpandableThemeData(
            headerAlignment: ExpandablePanelHeaderAlignment.center,
            useInkWell: false,
            tapBodyToCollapse: true,
            tapHeaderToExpand: false),
        header: GestureDetector(
          behavior: HitTestBehavior.translucent,
          child: Padding(
              padding: EdgeInsets.all(10),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      child: Text(
                          getStationName(
                              train.firstTrain.nowStartStationTelecode!),
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      width: 80,
                    ),
                  ),
                  Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          Text(train.firstTrainCode,
                              style: TextStyle(fontSize: 16)),
                          Divider(
                            height: 2,
                            thickness: 1,
                          ),
                          Text(
                              '${train.firstTrain.startStartTime!.substring(0, 5)}-${train.firstTrainArriveTime.substring(0, 5)}',
                              style: TextStyle(fontSize: 12, color: Colors.blue))
                        ],
                      ),
                      width: 80,
                    ),
                  ),
                  Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          Text('${train.interval ~/ 60}时${train.interval % 60}分',
                              style: TextStyle(fontSize: 12, color: Colors.blue)),
                          Text(getStationName(train.changeStation),
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold))
                        ],
                      ),
                      width: 80,
                    ),
                  ),
                  Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          Text(train.lastTrainCode,
                              style: TextStyle(fontSize: 16)),
                          Divider(
                            height: 2,
                            thickness: 1,
                          ),
                          Text(
                              '${train.lastTrainStartTime.substring(0, 5)}-${train.lastTrain.endArriveTime!.substring(0, 5)}',
                              style: TextStyle(fontSize: 12, color: Colors.blue))
                        ],
                      ),
                      width: 80,
                    ),
                  ),
                  Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      child: Text(
                          getStationName(train.lastTrain.nowEndStationTelecode!),
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      width: 80,
                    ),
                  ),
                ],
              )),
          onTap: () {
            Get.showOverlay(
                asyncFunction: () async {
                  List<RemainSeat> l1 = await TrainApi.trainTicketRemaining(
                      train.firstTrain.nowStartStationTelecode!,
                      train.firstTrain.nowEndStationTelecode!,
                      train.firstTrain.trainCode!,
                      widget.date.toIso8601String().substring(0, 10));
                  List<TrainPrice> l2 = await TrainApi.trainPrice(
                      train.firstTrain.nowStartStationTelecode!,
                      train.firstTrain.nowEndStationTelecode!,
                      train.firstTrain.trainCode!);
                  List<RemainSeat> l3 = await TrainApi.trainTicketRemaining(
                      train.lastTrain.nowStartStationTelecode!,
                      train.lastTrain.nowEndStationTelecode!,
                      train.lastTrain.trainCode!,
                      widget.date.toIso8601String().substring(0, 10));
                  List<TrainPrice> l4 = await TrainApi.trainPrice(
                      train.lastTrain.nowStartStationTelecode!,
                      train.lastTrain.nowEndStationTelecode!,
                      train.lastTrain.trainCode!);
                  if (l1.isEmpty || l2.isEmpty) {
                    BotToast.showText(text: '数据已过期');
                  } else {
                    Get.to(() => OrderConfirmTwoPage(
                      remainSeatList: l1,
                      trainPriceList: l2,
                      remainSeatList2: l3,
                      trainPriceList2: l4,
                      date: widget.date,
                      ticket: ticket,
                      train: train.firstTrain,
                      train2: train.lastTrain,
                    ));
                  }
                },
                loadingWidget: Dialog(
                  child: Container(
                    padding: EdgeInsets.all(8),
                    alignment: Alignment.center,
                    child: Text(
                      '正在生成订单,请稍后...',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ));
          },
        ),
        collapsed: buildCollapsed(),
        expanded: Container(),
        builder: (_, collapsed, expanded) {
          return Padding(
            padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
            child: Expandable(
              collapsed: collapsed,
              expanded: Container(),
              theme: const ExpandableThemeData(crossFadePoint: 0),
            ),
          );
        },
      ),
    );
  }

  Widget buildCollapsed() {
    if (seePrice) {
      return Column(
        children: [
          Divider(),
          ...trains.map((train) => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    margin: EdgeInsets.symmetric(horizontal: 4),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle, color: Colors.blue),
                    child: Text('${trains.indexOf(train) + 1}',
                        style: TextStyle(color: Colors.white)),
                  ),
                  ...trainPriceList[train]!.map((e) => Expanded(
                        child: Text.rich(
                          TextSpan(children: [
                            TextSpan(text: '${e.seatTypeName}:  '),
                            TextSpan(
                                text:
                                    '￥${widget.student ? e.price * (e.seatTypeCode == 'WZ' || e.seatTypeCode == 'A1' ? 0.5 : 0.75) : e.price}',
                                style: TextStyle(
                                    color: widget.student
                                        ? Colors.redAccent
                                        : Colors.green))
                          ]),
                          textAlign: TextAlign.center,
                        ),
                      ))
                ],
              ))
        ],
      );
    } else {
      return Column(
        children: [
          Divider(),
          ...trains.map(
            (train) =>
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(
                width: 24,
                height: 24,
                margin: EdgeInsets.symmetric(horizontal: 4),
                alignment: Alignment.center,
                decoration:
                    BoxDecoration(shape: BoxShape.circle, color: Colors.blue),
                child: Text('${trains.indexOf(train) + 1}',
                    style: TextStyle(color: Colors.white)),
              ),
              ...remainSeatList[train]!.map((e) => Expanded(
                    child: Text.rich(
                      TextSpan(children: [
                        TextSpan(
                            text: '${e.seatTypeName}:  ',
                            style: TextStyle(
                                color: e.remaining == 0
                                    ? Colors.grey
                                    : Colors.black)),
                        TextSpan(
                            text: e.remaining == 0 ? '无' : '${e.remaining}张',
                            style: TextStyle(
                                color: e.remaining == 0
                                    ? Colors.grey
                                    : Colors.green))
                      ]),
                      textAlign: TextAlign.center,
                    ),
                  ))
            ]),
          )
        ],
      );
    }
  }

  Widget stationTextWidget(
      String stationTelecode, List<TrainStation> stations) {
    String s = '过';
    if (stationTelecode == stations.first.stationTelecode) {
      s = '始';
    } else if (stationTelecode == stations.last.stationTelecode) {
      s = '终';
    }

    return Material(
      borderRadius: BorderRadius.all(Radius.circular(5)),
      color: s == '过'
          ? Colors.blue
          : s == '始'
              ? Colors.deepOrange
              : Colors.green,
      child: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(4),
        child: Text(
          s,
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  String getStationName(String? telecode) {
    if (telecode == null) {
      return '---';
    }
    return StationApi.cachedStationInfo(telecode)?.name ?? '---';
  }

  String getTrainStartTime(Train train) {
    if (train.trainStations == null) {
      return '-----';
    }
    for (TrainStation station in train.trainStations!) {
      if (station.stationTelecode == train.nowStartStationTelecode) {
        return station.startTime;
      }
    }
    return '-----';
  }

  String getTrainArriveTime(Train train) {
    if (train.trainStations == null) {
      return '-----';
    }
    for (TrainStation station in train.trainStations!) {
      if (station.stationTelecode == train.nowEndStationTelecode) {
        return station.arriveTime;
      }
    }
    return '-----';
  }

  void fetchData() async {
    for (Train train in trains) {
      trainPriceList[train] = await TrainApi.trainPrice(
          train.nowStartStationTelecode!,
          train.nowEndStationTelecode!,
          train.trainCode!);
      remainSeatList[train] = await TrainApi.trainTicketRemaining(
          train.nowStartStationTelecode!,
          train.nowEndStationTelecode!,
          train.trainCode!,
          widget.date.toIso8601String().substring(0, 10));
      if (mounted) {
        setState(() {});
      }
    }
  }
}

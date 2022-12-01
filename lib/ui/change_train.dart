import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:train/api/api.dart';
import 'package:train/bean/remain_seat.dart';
import 'package:train/bean/ticket.dart';
import 'package:train/bean/train.dart';
import 'package:train/bean/train_price.dart';
import 'package:train/bean/train_station.dart';
import 'package:train/ui/train_page.dart';
import 'package:train/util/date_util.dart';

import 'main_page.dart';

class ChangeTrainPage extends StatefulWidget {
  final Ticket ticket;
  const ChangeTrainPage({Key? key, required this.ticket}) : super(key: key);

  @override
  _ChangeTrainPageState createState() => _ChangeTrainPageState();
}

class _ChangeTrainPageState extends State<ChangeTrainPage> {
  late bool _canBeforeDay;
  late bool _canAfterDay;
  late DateTime _date = DateTime.now();
  late Ticket ticket = widget.ticket;
  final RefreshController _controller = RefreshController();
  bool _loading = true;
  List<Train> trains = [];
  List<Train> filteredTrains = [];
  bool sortByEarly = true;
  bool sortByLate = false;
  bool sortByTimeShort = false;
  bool sortByTimeLong = false;
  late bool onlyHighWay = false;
  late bool student = widget.ticket.student!;
  @override
  void initState() {
    changeDate(_date);
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('车票改签 : ${ticket.startStation!.name}->${ticket.endStation!.name}'),
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
                    text: ticket.startStation!.name,
                    style: TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: ' 到 '),
                TextSpan(
                    text: ticket.endStation!.name,
                    style: TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: ' 的直达列车\n'),
              ]),
              style: TextStyle(fontSize: 18),
            ),
            TextButton(
                style: TextButton.styleFrom(backgroundColor: Colors.blue),
                onPressed: () {
                  Get.toEnd(() => MainPage());
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Text('接续换乘',
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
                  // key: ValueKey([sortByTime, sortByEarly, onlyHighWay]),
                  itemBuilder: (c, i) {
                    return ListTile(
                      key: ValueKey(filteredTrains[i]),
                      title: ChangeTrainCard(
                        train: filteredTrains[i],
                        ticket: ticket,
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

  List<Train> filter(List<Train> trains) {
    List<Train> list = List.from(trains);

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
      element.trainClassCode != 'D' && element.trainClassCode != '8');
    }

    return list;
  }

  String getTrainStartTime(Train train) {
    if (train.trainStations == null) {
      return '---';
    }
    for (TrainStation station in train.trainStations!) {
      if (station.stationTelecode == train.nowStartStationTelecode) {
        return station.startTime;
      }
    }
    return '---';
  }

  String getTrainArriveTime(Train train) {
    if (train.trainStations == null) {
      return '---';
    }
    for (TrainStation station in train.trainStations!) {
      if (station.stationTelecode == train.nowEndStationTelecode) {
        if (station.arriveDayDiff - station.startDayDiff > 0){
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
    TrainApi.trainsBetween(
        ticket.startStationTelecode!, ticket.endStationTelecode!)
        .then((list) {
      setState(() {
        trains = list;
        _loading = false;
        filteredTrains = filter(trains);
      });
    });

    setState(() {});
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

}


class ChangeTrainCard extends StatefulWidget {
  final Ticket ticket;
  final Train train;
  final DateTime date;
  final bool student;

  const ChangeTrainCard(
      {Key? key,
        required this.train,
        required this.ticket,
        required this.date,
        required this.student})
      : super(key: key);

  @override
  _ChangeTrainCardState createState() => _ChangeTrainCardState();
}

class _ChangeTrainCardState extends State<ChangeTrainCard> {
  late final Train train = widget.train;
  late final Ticket ticket = widget.ticket;
  final ExpandableController _expandableController = ExpandableController();
  List<TrainPrice> trainPriceList = [];
  List<RemainSeat> remainSeatList = [];

  @override
  void initState() {
    TrainApi.trainPrice(train.nowStartStationTelecode!,
        train.nowEndStationTelecode!, train.trainCode!)
        .then((list) {
      trainPriceList.clear();
      trainPriceList.addAll(list);
      if (mounted) {
        setState(() {});
      }
    });
    TrainApi.trainTicketRemaining(
        train.nowStartStationTelecode!,
        train.nowEndStationTelecode!,
        train.trainCode!,
        widget.date.toIso8601String().substring(0, 10))
        .then((list) {
      remainSeatList.clear();
      remainSeatList.addAll(list);
      if (mounted) {
        setState(() {});
      }
    });
    super.initState();
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
                  Container(
                    alignment: Alignment.center,
                    child: Text(train.trainCode!,
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    width: 80,
                  ),
                  Container(
                    child: Column(children: [
                      Row(children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: stationTextWidget(
                              train.nowStartStationTelecode!,
                              train.trainStations!),
                        ),
                        Text(getStationName(ticket.startStationTelecode))
                      ]),
                      Text(getTrainStartTime(train),
                          style: TextStyle(color: Colors.blue))
                    ]),
                    width: 100,
                  ),
                  Expanded(
                      child: Column(
                        children: [
                          Text(
                            DateUtil.timeInterval(getTrainStartTime(train),
                                getTrainArriveTime(train)),
                            style: TextStyle(color: Colors.black45),
                          ),
                          Icon(Icons.arrow_right_alt_rounded,
                              color: Colors.blueAccent)
                        ],
                      )),
                  Container(
                    width: 100,
                    child: Column(children: [
                      Row(children: [
                        Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: stationTextWidget(
                                train.nowEndStationTelecode!,
                                train.trainStations!)),
                        Text(getStationName(ticket.endStationTelecode!))
                      ]),
                      Text(getTrainArriveTime(train),
                          style: TextStyle(color: Colors.blue))
                    ]),
                  ),
                ],
              )),
          onTap: () {
            Get.back(result: train);
          },
        ),
        collapsed: buildCollapsed(),
        expanded: buildExpand(),
        builder: (_, collapsed, expanded) {
          return Padding(
            padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
            child: Expandable(
              collapsed: collapsed,
              expanded: expanded,
              theme: const ExpandableThemeData(crossFadePoint: 0),
            ),
          );
        },
      ),
    );
  }

  Widget buildExpand() {
    List<TableRow> rows = [];
    rows.add(
        TableRow(decoration: BoxDecoration(color: Colors.grey[100]), children: [
          Padding(
              padding: EdgeInsets.all(6),
              child: Text('站序号', style: TextStyle(color: Colors.blueAccent))),
          Text('站名', style: TextStyle(color: Colors.blueAccent)),
          Text('到时', style: TextStyle(color: Colors.blueAccent)),
          Text('发时', style: TextStyle(color: Colors.blueAccent)),
          Text('时长', style: TextStyle(color: Colors.blueAccent)),
        ]));
    List<TrainStation> trainStations = train.trainStations!;
    for (int i = 0; i < trainStations.length; i++) {
      rows.add(TableRow(children: [
        Padding(
          padding: EdgeInsets.all(6),
          child: Text('${i + 1}'),
        ),
        Text(
          StationApi.cachedStationInfo(trainStations[i].stationTelecode)!.name,
          style: TextStyle(
              color: (trainStations[i].stationTelecode ==
                  train.nowStartStationTelecode ||
                  trainStations[i].stationTelecode ==
                      train.nowEndStationTelecode)
                  ? Colors.blueAccent
                  : Colors.black),
        ),
        Text(
          trainStations[i].arriveTime ?? '---',
          style: TextStyle(
              color: (trainStations[i].stationTelecode ==
                  train.nowStartStationTelecode ||
                  trainStations[i].stationTelecode ==
                      train.nowEndStationTelecode)
                  ? Colors.blueAccent
                  : Colors.black),
        ),
        Text(
          trainStations[i].startTime ?? '---',
          style: TextStyle(
              color: (trainStations[i].stationTelecode ==
                  train.nowStartStationTelecode ||
                  trainStations[i].stationTelecode ==
                      train.nowEndStationTelecode)
                  ? Colors.blueAccent
                  : Colors.black),
        ),
        Text(
          (trainStations[i].arriveTime == null ||
              trainStations[i].startTime == null ||
              trainStations[i].startTime == trainStations[i].arriveTime)
              ? '---'
              : DateUtil.timeInterval(
              trainStations[i].startTime, trainStations[i].arriveTime)
              .substring(3),
          style: TextStyle(
              color: (trainStations[i].stationTelecode ==
                  train.nowStartStationTelecode ||
                  trainStations[i].stationTelecode ==
                      train.nowEndStationTelecode)
                  ? Colors.blueAccent
                  : Colors.black),
        ),
      ]));
    }
    return Table(
      border: TableBorder(
          horizontalInside: BorderSide(color: Colors.grey, width: 0.2)),
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: rows,
    );
  }

  Widget buildCollapsed() {
    if (seePrice) {
      return Column(
        children: [
          Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: trainPriceList
                .map((e) => Expanded(
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
                .toList(),
          )
        ],
      );
    } else {
      return Column(
        children: [
          Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: remainSeatList
                .map((e) => Expanded(
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
                .toList(),
          ),
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
      return '---';
    }
    for (TrainStation station in train.trainStations!) {
      if (station.stationTelecode == train.nowStartStationTelecode) {
        return station.startTime;
      }
    }
    return '---';
  }

  String getTrainArriveTime(Train train) {
    if (train.trainStations == null) {
      return '---';
    }
    for (TrainStation station in train.trainStations!) {
      if (station.stationTelecode == train.nowEndStationTelecode) {
        return station.arriveTime;
      }
    }
    return '---';
  }
}
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:train/api/api.dart';
import 'package:train/bean/order.dart';
import 'package:train/bean/passenger.dart';
import 'package:train/bean/remain_seat.dart';
import 'package:train/bean/ticket.dart';
import 'package:train/bean/train.dart';
import 'package:train/bean/train_price.dart';
import 'package:train/bean/train_station.dart';
import 'package:train/ui/pay_order.dart';
import 'package:train/util/date_util.dart';

import 'choose_passenger.dart';

class OrderConfirmPage extends StatefulWidget {
  final DateTime date;
  final List<TrainPrice> trainPriceList;
  final List<RemainSeat> remainSeatList;
  final Ticket ticket;
  final Train train;

  const OrderConfirmPage(
      {Key? key,
      required this.date,
      required this.trainPriceList,
      required this.remainSeatList,
      required this.ticket,
      required this.train})
      : super(key: key);

  @override
  _OrderConfirmPageState createState() => _OrderConfirmPageState();
}

class _OrderConfirmPageState extends State<OrderConfirmPage> {
  late bool _canBeforeDay;
  late bool _canAfterDay;
  late DateTime _date;
  late final Ticket ticket = widget.ticket;
  late final List<TrainPrice> trainPriceList = List.from(widget.trainPriceList);
  late final List<RemainSeat> remainSeatList = List.from(widget.remainSeatList);
  List<Passenger> passengers = [];
  Map<Passenger, String?> passengerChooseSeat = {};
  int choose = 0;

  @override
  void initState() {
    _date = widget.date;
    changeDate(_date);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('确认订单'),
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
      ),
      body: ListView(
        children: [
          Padding(
            padding: EdgeInsets.all(4),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        StationApi.cachedStationInfo(
                                widget.train.nowStartStationTelecode!)!
                            .name,
                        style: TextStyle(fontSize: 18),
                      ),
                      Padding(padding: EdgeInsets.all(2)),
                      Text(
                        getTrainStartTime(widget.train),
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Expanded(
                    child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.credit_card_rounded,
                          color: Colors.blue,
                        ),
                        Text('   ' + widget.train.trainCode!),
                      ],
                    ),
                    SizedBox(
                        width: 200,
                        height: 30,
                        child: Image.asset(
                          'assets/icon/right_arrow.png',
                          fit: BoxFit.fill,
                        )),
                    Text(
                      DateUtil.timeInterval(getTrainStartTime(widget.train),
                          getTrainArriveTime(widget.train)),
                    ),
                  ],
                )),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        StationApi.cachedStationInfo(
                                widget.train.nowEndStationTelecode!)!
                            .name,
                        style: TextStyle(fontSize: 18),
                      ),
                      Padding(padding: EdgeInsets.all(2)),
                      Text(
                        getTrainArriveTime(widget.train),
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          Divider(),
          buildSeatChoose(),
          Divider(thickness: 6),
          Container(
            color: Colors.white,
            width: double.infinity,
            child: Column(
              children: [
                ...passengers.map((p) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                            child: Text(p.name!, textAlign: TextAlign.center)),
                        Expanded(
                          flex:2,
                          child:
                              Text(p.idCardNo!.replaceRange(5, 16, '*' * 11), textAlign: TextAlign.center),
                        ),
                        Expanded(
                          child: Text(p.student ?? false ? '学生' : '成人',
                              style: TextStyle(color: Colors.blue)),
                        ),
                        Expanded(
                          child: Text(trainPriceList[choose].seatTypeName,
                              style: TextStyle(color: Colors.blue)),
                        ),
                        Expanded(
                            child: IconButton(
                          onPressed: () {
                            setState(() {
                              passengers.remove(p);
                            });
                          },
                          icon: Icon(Icons.delete_rounded, color: Colors.grey),
                        )),
                      ],
                    ),
                  );
                }),
                Container(
                  padding: EdgeInsets.all(8),
                  alignment: Alignment.center,
                  child: GestureDetector(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_circle,
                          color: Colors.deepOrange,
                        ),
                        Text(
                          ' 选择乘车人',
                          style: TextStyle(color: Colors.deepOrange),
                        )
                      ],
                    ),
                    onTap: () async {
                      List<Passenger>? passengerTemp =
                          await Get.to(() => ChoosePassengerPage(
                                choose: passengers,
                              ));
                      passengerTemp?.forEach((element) {
                        if (!passengers.contains(element)) {
                          passengers.add(element);
                        }
                      });
                      setState(() {});
                    },
                  ),
                )
              ],
            ),
          ),
          Divider(thickness: 6),
          passengers.isEmpty
              ? Container()
              : Container(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            '   选座服务',
                            style: TextStyle(
                                color: Colors.deepOrange,
                                fontWeight: FontWeight.bold),
                          ),
                          Expanded(child: Container()),
                          Text('可选择${passengers.length}个座位    ',
                              style: TextStyle(color: Colors.blueAccent))
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.all(8),
                        child: Column(
                          children: passengers
                              .map((e) => Container(
                                    padding: EdgeInsets.all(8),
                                    alignment: Alignment.center,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: ['A', 'B', 'C', 'D']
                                          .map((c) => GestureDetector(
                                                child: Container(
                                                  width: 36,
                                                  height: 36,
                                                  margin: EdgeInsets.symmetric(
                                                      horizontal: 4),
                                                  alignment: Alignment.center,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: passengerChooseSeat[
                                                                e] ==
                                                            c
                                                        ? Colors.blue
                                                        : Colors.grey,
                                                  ),
                                                  child: Text(c,
                                                      style: TextStyle(
                                                          color: Colors.white)),
                                                ),
                                                onTap: () {
                                                  if (passengerChooseSeat[e] ==
                                                      c) {
                                                    passengerChooseSeat
                                                        .remove(e);
                                                  } else {
                                                    passengerChooseSeat[e] = c;
                                                  }
                                                  setState(() {});
                                                },
                                              ))
                                          .toList(),
                                    ),
                                  ))
                              .toList(),
                        ),
                      ),
                      Divider(thickness: 6),
                    ],
                  ),
                ),
          Center(
              child: TextButton(
                  style: TextButton.styleFrom(
                      primary: Colors.white, backgroundColor: Colors.blue),
                  onPressed: () {
                    Get.showOverlay(
                        asyncFunction: () async {
                          List<int> ticketIds = [];
                          for (Passenger p in passengers) {
                            int? ticketId = await TicketApi.buyTicket(
                                widget.train.nowStartStationTelecode!,
                                widget.train.nowEndStationTelecode!,
                                widget.train.trainCode!,
                                trainPriceList[choose].seatTypeCode,
                                p.passengerId!,
                                p.student!,
                                _date.toIso8601String().substring(0, 10),
                                passengerChooseSeat[p]);
                            if (ticketId == null) {
                              // BotToast.showText(text: '${p.name}购票失败');
                              return;
                            } else {
                              ticketIds.add(ticketId);
                            }
                          }
                          if (ticketIds.isNotEmpty) {
                            Order? order =
                                await OrderFormApi.addOrder(ticketIds);
                            Get.to(() => PayOrderPage(order: order!))
                                ?.then((value) => Get.back());
                          } else {
                            BotToast.showText(text: '订单生成失败,请稍后重试');
                          }
                        },
                        loadingWidget: Dialog(
                          child: Container(
                            padding: EdgeInsets.all(8),
                            alignment: Alignment.center,
                            child: Text(
                              '正在提交订单,请稍后...',
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                        ));
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Text(
                      '提交订单',
                      style: TextStyle(fontSize: 18),
                    ),
                  ))),
        ],
      ),
    );
  }

  Widget buildSeatChoose() {
    trainPriceList.sort((p1, p2) => p2.price.compareTo(p1.price));
    List<Widget> widgets = [];
    for (int i = 0; i < trainPriceList.length; i++) {
      TrainPrice trainPrice = trainPriceList[i];
      num remain = 0;
      RemainSeat remainSeat = remainSeatList.firstWhere(
          (element) => element.seatTypeName == trainPrice.seatTypeName);
      remain = remainSeat.remaining ?? 0;

      widgets.add(Expanded(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: GestureDetector(
            onTap: () {
              if (remain == 0) {
                return;
              } else {
                setState(() {
                  choose = i;
                });
              }
            },
            child: Material(
              color: choose == i ? Colors.blue : null,
              borderRadius: BorderRadius.all(Radius.circular(4)),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Text(
                      trainPrice.seatTypeName,
                      style: TextStyle(
                          color: choose == i
                              ? Colors.white
                              : remain == 0
                                  ? Colors.grey
                                  : Colors.black),
                    ),
                    Text(
                      remain == 0 ? '无' : '$remain张',
                      style: TextStyle(
                          color: choose == i
                              ? Colors.white
                              : remain == 0
                                  ? Colors.grey
                                  : Colors.black),
                    ),
                    Text(
                      '￥${trainPrice.price}',
                      style: TextStyle(
                          color: choose == i ? Colors.white : Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ));
    }
    return Row(
      children: widgets,
    );
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

  void fetchData() {}

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

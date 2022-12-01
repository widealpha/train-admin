import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:train/api/api.dart';
import 'package:train/bean/coach.dart';
import 'package:train/bean/order.dart';
import 'package:train/bean/passenger.dart';
import 'package:train/bean/seat_type.dart';
import 'package:train/bean/ticket.dart';
import 'package:train/ui/pay_order.dart';
import 'package:train/util/date_util.dart';

class NeedToPayPage extends StatefulWidget {
  const NeedToPayPage({Key? key}) : super(key: key);

  @override
  _NeedToPayPageState createState() => _NeedToPayPageState();
}

class _NeedToPayPageState extends State<NeedToPayPage> {
  List<Order> orders = [];
  bool loading = true;

  @override
  void initState() {
    fetchData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('未完成'),
      ),
      body: buildBody(),
    );
  }

  Widget buildBody() {
    if (loading) {
      return Center(child: CircularProgressIndicator());
    } else if (orders.isEmpty) {
      return Center(
          child: Text('还没有待支付订单哦', style: TextStyle(color: Colors.grey)));
    } else {
      return ListView.separated(
        itemBuilder: (c, i) {
          return Card(
            child: Column(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        '订单${i + 1} ',
                        style: TextStyle(
                            color: Colors.deepOrange,
                            fontSize: 24),
                      ),
                    ),
                    Expanded(
                      child: OrderCard(order: orders[i], f: fetchData),
                    )
                  ],
                ),
                canPay(orders[i])?
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Center(
                            child: TextButton(
                                style: TextButton.styleFrom(
                                    primary: Colors.white,
                                    backgroundColor: Colors.redAccent),
                                onPressed: () {
                                  Get.dialog(AlertDialog(
                                    title: Text('温馨提醒'),
                                    content: Text('确认退订订单吗?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Get.back();
                                        },
                                        child: Text('取消'),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          await OrderFormApi.cancelOrderForm(
                                              orders[i].orderId!);
                                          fetchData();
                                          Get.back();
                                        },
                                        child: Text('确定'),
                                      ),
                                    ],
                                  ));
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  child: Text(
                                    '退订订单',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                ))),
                      ),
                      Expanded(
                        child: Center(
                            child: TextButton(
                                style: TextButton.styleFrom(
                                    primary: Colors.white,
                                    backgroundColor: Colors.blue),
                                onPressed: () async {
                                  await Get.to(
                                      () => PayOrderPage(order: orders[i]));
                                  fetchData();
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  child: Text(
                                    '支付订单',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                ))),
                      ),
                    ],
                  ),
                ):Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Container(),
                      ),
                      Expanded(
                        child: Center(
                            child: TextButton(
                                style: TextButton.styleFrom(
                                    primary: Colors.white,
                                    backgroundColor: Colors.grey),
                                onPressed: () async {
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  child: Text(
                                    '订单已超时取消',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                ))),
                      ),
                    ],
                  ),
                )
              ],
            ),
          );
        },
        itemCount: orders.length,
        separatorBuilder: (_, __) => Divider(),
      );
    }
  }

  void fetchData() async {
    loading = true;
    setState(() {});
    List<Order> l = await OrderFormApi.allMyOrders();
    orders.clear();
    orders.addAll(l.where((o) => o.payed == 0));
    orders.sort((a,b)=>b.time!.compareTo(a.time!));
    loading = false;
    setState(() {});
  }

  bool canPay(Order order){
    DateTime time = DateTime.parse(order.time!);
    if (time.add(Duration(minutes: 30)).isBefore(DateTime.now())){
      return false;
    }
    return true;
  }
}

class OrderCard extends StatefulWidget {
  final Order order;
  final Function f;

  const OrderCard({Key? key, required this.order, required this.f})
      : super(key: key);

  @override
  _OrderCardState createState() => _OrderCardState();
}

class _OrderCardState extends State<OrderCard> {
  List<Ticket> tickets = [];
  Map<Ticket, Coach> coachMap = {};
  Map<Ticket, String> seatMap = {};
  Map<String, String> seatTypeCodeToName = {};
  Map<Ticket, Passenger> passengerMap = {};

  @override
  void initState() {
    fetchData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: buildCardList(),
    );
  }

  List<Widget> buildCardList() {
    List<Widget> widgets = [];
    tickets.forEach((t) {
      widgets.add(Card(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(4),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          t.startStation!.name,
                          style: TextStyle(fontSize: 18),
                        ),
                        Padding(padding: EdgeInsets.all(2)),
                        Text(
                          t.startTime!,
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
                          Text('   ' + t.trainCode!),
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
                        DateUtil.dateTimeInterval(t.startTime!, t.endTime!),
                      ),
                    ],
                  )),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          t.endStation!.name,
                          style: TextStyle(fontSize: 18),
                        ),
                        Padding(padding: EdgeInsets.all(2)),
                        Text(
                          t.endTime!,
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    child: Container(),
                  ),
                  Container(
                    child: Text('${passengerMap[t]?.name ?? ''}'
                        '  (${passengerMap[t]?.student ?? false ? '学生' : '成人'}票)'
                        ' ${seatTypeCodeToName[coachMap[t]?.seatTypeCode]}'
                        ' ${coachMap[t]?.coachNo}车'
                        ' ${seatMap[t]}号                      '),
                  )
                ],
              ),
            ),
          ],
        ),
      ));
    });
    return widgets;
  }

  void fetchData() async {
    tickets = await TicketApi.ticketInfoByOrder(widget.order.orderId!);
    for (Ticket ticket in tickets) {
      ticket.startStation =
          StationApi.cachedStationInfo(ticket.startStationTelecode!);
      ticket.endStation =
          StationApi.cachedStationInfo(ticket.endStationTelecode!);
      coachMap[ticket] = (await CoachApi.coachInfo(ticket.coachId!))!;
      seatMap[ticket] =
          await TicketApi.transferSeatBigInteger(bigInteger: '${ticket.seat}');
      List<Passenger> passengers = await PassengerApi.allMyPassengers();
      passengers.forEach((element) {
        if (element.passengerId == ticket.passengerId) {
          passengerMap[ticket] = element;
        }
      });
      List<SeatType> seatTypes = await SeatTypeApi.allSeatTypes();
      seatTypes.forEach((element) {
        seatTypeCodeToName[element.seatTypeCode!] = element.seatTypeName!;
      });
      setState(() {});
    }
    setState(() {});
  }
}

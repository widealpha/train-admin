import 'package:bot_toast/bot_toast.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:train/api/api.dart';
import 'package:train/bean/station.dart';
import 'package:train/ui/station_page.dart';

class PriceManagePage extends StatefulWidget {
  const PriceManagePage({Key? key}) : super(key: key);

  @override
  _PriceManagePageState createState() => _PriceManagePageState();
}

class _PriceManagePageState extends State<PriceManagePage> {
  bool loading = true;
  late String trainClass;
  late String seatType;
  Map<String, String> trainClassMap = {};
  Map<String, String> seatTypeMap = {};
  Map<String, double> sellTimeMap = {};
  Map<String, double> sellTrainClassMap = {};
  String startStation = '';
  String endStation = '';
  TextEditingController _trainClassController =
      TextEditingController(text: '1.0');
  TextEditingController _seatTypeController =
      TextEditingController(text: '1.0');
  TextEditingController _trainStationController =
      TextEditingController(text: '1.0');
  int touchedIndex = -1;
  List<Color> randomColors = [
    Colors.green,
    Colors.blue,
    Colors.red,
    Colors.orange,
    Colors.purple
  ];

  @override
  void initState() {
    fetchData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? Center(
            child: CircularProgressIndicator(),
          )
        : Row(
            children: [
              Expanded(
                  child: Column(
                children: [
                  Text('票价管理'),
                  Divider(),
                  Expanded(
                      child: ListView(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          controller: _trainClassController,
                          readOnly: false,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: '火车种类价格比例调整',
                              labelText: '火车种类价格比例调整',
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
                                      });
                                    }
                                  },
                                  child: Text(trainClassMap[trainClass]!)),
                              suffix: TextButton.icon(
                                  onPressed: () async {
                                    bool b = await TrainApi
                                        .updateTrainClassPriceRatio(
                                            trainClass,
                                            double.tryParse(
                                                _trainClassController.text));
                                    if (!b) {
                                      BotToast.showText(text: '更新失败');
                                    }
                                  },
                                  icon: Icon(Icons.update),
                                  label: Text('更新'))),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          controller: _seatTypeController,
                          readOnly: false,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: '座位价格比例调整',
                              labelText: '座位价格比例调整',
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
                                      });
                                    }
                                  },
                                  child: Text(seatTypeMap[seatType]!)),
                              suffix: TextButton.icon(
                                  onPressed: () async {
                                    bool b =
                                        await TrainApi.updateSeatTypePriceRatio(
                                            seatType,
                                            double.tryParse(
                                                _seatTypeController.text));
                                    if (!b) {
                                      BotToast.showText(text: '更新失败');
                                    }
                                  },
                                  icon: Icon(Icons.update),
                                  label: Text('更新'))),
                        ),
                      ),
                      Divider(),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          controller: _trainStationController,
                          readOnly: false,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: '站点价格比例调整',
                            labelText: '站点价格比例调整',
                            prefix: TextButton(
                                onPressed: () async {
                                  Station? s =
                                      await Get.to(() => StationPage());
                                  if (s != null) {
                                    setState(() {
                                      startStation = s.telecode;
                                    });
                                  }
                                },
                                child: Text(getStationName(startStation))),
                            suffix: TextButton(
                                onPressed: () async {
                                  Station? s =
                                      await Get.to(() => StationPage());
                                  if (s != null) {
                                    setState(() {
                                      endStation = s.telecode;
                                    });
                                  }
                                },
                                child: Text(getStationName(endStation))),
                          ),
                        ),
                      ),
                      TextButton(
                          onPressed: () async {
                            bool b = await TrainApi.updateStationPriceRatio(
                                startStation,
                                endStation,
                                double.tryParse(_trainStationController.text));
                            if (!b) {
                              BotToast.showText(text: '更新失败');
                            }
                          },
                          child: Text('提交')),
                      Divider(),
                    ],
                  ))
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
                      Text('销售统计'),
                      TextButton.icon(
                          onPressed: () {
                            fetchData();
                          },
                          icon: Icon(Icons.refresh),
                          label: Text('刷新')),
                    ],
                  ),
                  Divider(),
                  Expanded(
                      child: Row(
                    children: [
                      Expanded(
                        child: PieChart(
                          PieChartData(
                              pieTouchData: PieTouchData(touchCallback:
                                  (FlTouchEvent event, pieTouchResponse) {
                                setState(() {
                                  if (!event.isInterestedForInteractions ||
                                      pieTouchResponse == null ||
                                      pieTouchResponse.touchedSection == null) {
                                    touchedIndex = -1;
                                    return;
                                  }
                                  touchedIndex = pieTouchResponse
                                      .touchedSection!.touchedSectionIndex;
                                });
                              }),
                              borderData: FlBorderData(
                                show: false,
                              ),
                              sectionsSpace: 0,
                              centerSpaceRadius: 40,
                              sections: showingSections()),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: sellTrainClassMap.keys
                              .map(
                                (key) => Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Indicator(
                                    color: randomColors[
                                        key.hashCode % randomColors.length],
                                    text: '${trainClassMap[key]}',
                                    isSquare: true,
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ],
                  )),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child:
                        Text('火车种类售票统计', style: TextStyle(color: Colors.grey)),
                  ),
                  Divider(),
                  Expanded(
                      child: Padding(
                    padding: EdgeInsets.all(8),
                    child: LineChart(
                      mainData(),
                      swapAnimationDuration: Duration(milliseconds: 150),
                      // Optional
                      swapAnimationCurve: Curves.linear, // Optional
                    ),
                  )),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child:
                        Text('火车售票额统计', style: TextStyle(color: Colors.grey)),
                  ),
                ],
              )),
            ],
          );
  }

  void fetchData() async {
    setState(() {
      loading = true;
    });

    (await SeatTypeApi.allSeatTypes()).forEach((type) {
      seatTypeMap[type.seatTypeCode!] = type.seatTypeName!;
      seatType = type.seatTypeCode!;
    });
    (await TrainClassApi.allTrainClasses()).forEach((c) {
      trainClassMap[c.trainClassCode!] = c.trainClassName!;
      trainClass = c.trainClassCode!;
    });

    (await SellApi.getSellByTime()).forEach((key, value) {
      sellTimeMap[key] = value.toDouble();
    });
    (await SellApi.getSellByTrainClass()).forEach((key, value) {
      sellTrainClassMap[key] = value.toDouble();
    });

    setState(() {
      loading = false;
    });
  }

  String getStationName(String? telecode) {
    if (telecode == null) {
      return '---';
    }
    return StationApi.cachedStationInfo(telecode)?.name ?? '---';
  }

  List<PieChartSectionData> showingSections() {
    return List.generate(sellTrainClassMap.keys.length, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 25.0 : 16.0;
      final radius = isTouched ? 60.0 : 50.0;
      String key = sellTrainClassMap.keys.toList()[i];
      return PieChartSectionData(
        color: randomColors[key.hashCode % randomColors.length],
        value: sellTrainClassMap[key],
        title: '${sellTrainClassMap[key]?.toInt()}张',
        radius: radius,
        titleStyle: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: const Color(0xffffffff)),
      );
    });
  }

  LineChartData mainData() {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: const Color(0xff37434d),
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: const Color(0xff37434d),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: SideTitles(showTitles: false),
        topTitles: SideTitles(showTitles: false),
        bottomTitles: SideTitles(
          showTitles: true,
          reservedSize: 22,
          interval: 1,
          getTextStyles: (context, value) => const TextStyle(
              color: Color(0xff68737d),
              fontWeight: FontWeight.bold,
              fontSize: 16),
          getTitles: (value) {
            switch (value.toInt()) {
              case 2:
                return 'MAR';
              case 5:
                return 'JUN';
              case 8:
                return 'SEP';
            }
            return '';
          },
          margin: 8,
        ),
        leftTitles: SideTitles(
          showTitles: true,
          interval: 1,
          getTextStyles: (context, value) => const TextStyle(
            color: Color(0xff67727d),
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
          getTitles: (value) {
            switch (value.toInt()) {
              case 1:
                return '10k';
              case 3:
                return '30k';
              case 5:
                return '50k';
            }
            return '';
          },
          reservedSize: 32,
          margin: 12,
        ),
      ),
      borderData: FlBorderData(
          show: true,
          border: Border.all(color: const Color(0xff37434d), width: 1)),
      minX: 0,
      maxX: 11,
      minY: 0,
      maxY: 6,
      lineBarsData: [
        LineChartBarData(
          spots: [
            FlSpot(0, 3),
            FlSpot(2.6, 2),
            FlSpot(4.9, 5),
            FlSpot(6.8, 3.1),
            FlSpot(8, 4),
            FlSpot(9.5, 3),
            FlSpot(11, 4),
          ],
          isCurved: true,
          colors: randomColors,
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            colors:
                randomColors.map((color) => color.withOpacity(0.3)).toList(),
          ),
        ),
      ],
    );
  }
}

class Indicator extends StatelessWidget {
  final Color color;
  final String text;
  final bool isSquare;
  final double size;
  final Color textColor;

  const Indicator({
    Key? key,
    required this.color,
    required this.text,
    required this.isSquare,
    this.size = 16,
    this.textColor = const Color(0xff505050),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: isSquare ? BoxShape.rectangle : BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(
          width: 4,
        ),
        Text(
          text,
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
        )
      ],
    );
  }
}

import 'package:bot_toast/bot_toast.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:train/ui/main_page.dart';
import 'package:train/util/hive_util.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'admin/admin_main.dart';

void main() async {
  await Hive.initFlutter('train_db');
  await HiveUtils.init();
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final botToastBuilder = BotToastInit();

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: '火车票购买程序',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en', 'US'),
        const Locale('zh', 'CH'),
      ],
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      builder: (context, child) {
        child = botToastBuilder(context, child);
        return child;
      },
      home: AdminMainPage(),
    );
  }
}

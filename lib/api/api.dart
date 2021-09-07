import 'dart:convert';
import 'dart:typed_data';

import 'package:bot_toast/bot_toast.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response, MultipartFile, FormData;
import 'package:train/bean/change_train.dart';
import 'package:train/bean/coach.dart';
import 'package:train/bean/order.dart';
import 'package:train/bean/pager.dart';
import 'package:train/bean/passenger.dart';
import 'package:train/bean/remain_seat.dart';
import 'package:train/bean/seat_type.dart';
import 'package:train/bean/station.dart';
import 'package:train/bean/system_setting.dart';
import 'package:train/bean/ticket.dart';
import 'package:train/bean/train.dart';
import 'package:train/bean/train_class.dart';
import 'package:train/bean/train_price.dart';
import 'package:train/bean/train_station.dart';
import 'package:train/bean/user_info.dart';
import 'package:train/util/hive_util.dart';

// final String host = 'https://widealpha.top:8443/train';
final String host = 'http://localhost:8080';

class Connection {
  static Dio? _dio;

  static Dio get dio {
    _dio ??= Dio(BaseOptions(responseType: ResponseType.json));
    return _dio!;
  }

  static Options get options =>
      Options(headers: {'Authorization': 'Bearer ${HiveUtils.get('token')}'});
}

class UserApi {
  static String _login = host + '/user/login';
  static String _register = host + '/user/register';
  static String _userInfo = host + '/userInfo/myInfo';
  static String _uploadImage = host + '/userInfo/uploadImage';
  static String _updateInfo = host + '/userInfo/updateInfo';

  static bool get isLogin => HiveUtils.get('token') != null;

  static Future<String> login(username, password) async {
    try {
      Response response = await Connection.dio.post(_login,
          queryParameters: {'username': username, 'password': password});
      if (response.statusCode == 200 && response.data['code'] == 0) {
        await HiveUtils.set('token', response.data['data']);
        response =
            await Connection.dio.post(_userInfo, options: Connection.options);
        UserInfo userInfo = UserInfo.fromJson(response.data['data']);
        HiveUtils.set('user_id', userInfo.userId);
        HiveUtils.set('head_image', userInfo.headImage);
        HiveUtils.set('nickname', userInfo.nickname);
        Get.forceAppUpdate();
        StationApi.allStations();
        return '登录成功';
      } else {
        return response.data['message'];
      }
    } catch (e) {
      return '用户名或密码错误';
    }
  }

  static Future<String> register(String username, String password) async {
    Response response = await Connection.dio.post(_register,
        queryParameters: {'username': username, 'password': password});
    if (response.statusCode == 200 && response.data['code'] == 0) {
      return '注册成功';
    } else {
      return response.data['message'];
    }
  }

  static bool logout() {
    HiveUtils.remove('token');
    HiveUtils.remove('user_id');
    HiveUtils.remove('head_image');
    HiveUtils.remove('nickname');
    Get.forceAppUpdate();
    return true;
  }

  static UserInfo get userInfo {
    UserInfo userInfo = UserInfo();
    if (isLogin) {
      userInfo.userId = HiveUtils.get('user_id');
      userInfo.headImage = HiveUtils.get('head_image');
      userInfo.nickname = HiveUtils.get('nickname');
    }
    return userInfo;
  }

  static Future<UserInfo> userInfoDetail() async {
    Response response =
        await Connection.dio.post(_userInfo, options: Connection.options);
    if (response.data['code'] == 0) {
      UserInfo userInfo = UserInfo.fromJson(response.data['data']);
      HiveUtils.set('user_id', userInfo.userId);
      HiveUtils.set('head_image', userInfo.headImage);
      HiveUtils.set('nickname', userInfo.nickname);
      return userInfo;
    } else {
      BotToast.showText(text: response.data['message']);
    }
    return userInfo;
  }

  static Future<String> uploadHeadImage(Uint8List image) async {
    if (image.isEmpty) {
      return '';
    }
    Response response = await Connection.dio.post(_uploadImage,
        options: Connection.options,
        data: FormData.fromMap(
            {"image": MultipartFile.fromBytes(image, filename: 'image')}));
    if (response.data['code'] == 0) {
      return response.data['data'];
    }
    return '';
  }

  static Future<bool> updateUserInfo(UserInfo userInfo) async {
    Response response = await Connection.dio.post(
      _updateInfo,
      options: Connection.options,
      data: jsonEncode(userInfo),
    );
    if (response.data['code'] == 0) {
      return response.data['data'];
    }
    return false;
  }
}

class TrainApi {
  static String _trainInfo = host + '/train/trainInfo';
  static String _allTrains = host + '/train/allTrains';
  static String _trainsBetween = host + '/train/trainsBetween';
  static String _trainsBetweenWithChange =
      host + '/train/trainsBetweenWithChange';
  static String _trainPrice = host + '/train/trainPrice';
  static String _trainTicketRemaining = host + '/train/trainTicketRemaining';
  static String _trainStations = host + '/train/trainStations';
  static String _allStationTrainCode = host + '/train/allStationTrainCode';
  static String _stopTrain = host + '/admin/stopTrain';
  static String _startTrain = host + '/admin/startTrain';
  static String _updateStartTime = host + '/admin/updateStartTime';
  static String _updateArriveTime = host + '/admin/updateArriveTime';

  static Future<Train?> trainInfo(String stationTrainCode) async {
    Response response = await Connection.dio.post(_trainInfo,
        queryParameters: {'stationTrainCode': stationTrainCode},
        options: Connection.options);
    if (response.data['code'] == 0) {
      return Train.fromJson(response.data['data']);
    } else {
      BotToast.showText(text: response.data['message']);
    }
    return null;
  }

  static Future<Pager<Train>> allTrains(int page, int size) async {
    Response response = await Connection.dio.post(_allTrains,
        queryParameters: {'page': page, 'size': size},
        options: Connection.options);
    Pager<Train> pager = Pager(0, 0, 0, 0, []);
    if (response.data['code'] == 0) {
      List l = response.data['data']['rows'];
      pager.size = response.data['data']['size'];
      pager.page = response.data['data']['page'];
      pager.total = response.data['data']['total'];
      pager.rows = l.map((e) => Train.fromJson(e)).toList();
      if (pager.size == 0) {
        pager.totalPage = 0;
      }
      if (pager.totalSize % pager.size == 0) {
        pager.totalPage = pager.totalSize ~/ pager.size;
      }
      pager.totalPage = pager.totalSize ~/ pager.size + 1;
      return pager;
    } else {
      BotToast.showText(text: response.data['message']);
    }
    return Pager(0, 0, 0, 0, []);
  }

  static Future<List<Train>> trainsBetween(
      String startStationTelecode, String endStationTelecode) async {
    Response response = await Connection.dio.post(_trainsBetween,
        queryParameters: {
          'startStationTelecode': startStationTelecode,
          'endStationTelecode': endStationTelecode
        },
        options: Connection.options);
    if (response.data['code'] == 0) {
      List l = response.data['data'];
      return l.map((e) => Train.fromJson(e)).toList();
    } else {
      BotToast.showText(text: response.data['message']);
    }
    return [];
  }

  static Future<List<ChangeTrain>> trainsBetweenWithChange(
      String startStationTelecode,
      String endStationTelecode,
      String date) async {
    Response response = await Connection.dio.post(_trainsBetweenWithChange,
        queryParameters: {
          'startStationTelecode': startStationTelecode,
          'endStationTelecode': endStationTelecode,
          'date': date
        },
        options: Connection.options);
    if (response.data['code'] == 0) {
      List l = response.data['data'];
      return l.map((e) => ChangeTrain.fromJson(e)).toList();
    } else {
      BotToast.showText(text: response.data['message']);
    }
    return [];
  }

  static Future<List<TrainPrice>> trainPrice(String startStationTelecode,
      String endStationTelecode, String stationTrainCode) async {
    Response response = await Connection.dio.post(_trainPrice,
        queryParameters: {
          'startStationTelecode': startStationTelecode,
          'endStationTelecode': endStationTelecode,
          'stationTrainCode': stationTrainCode
        },
        options: Connection.options);
    if (response.data['code'] == 0) {
      List l = response.data['data'];
      return l.map((e) => TrainPrice.fromJson(e)).toList();
    } else {
      BotToast.showText(text: response.data['message']);
    }
    return [];
  }

  static Future<List<RemainSeat>> trainTicketRemaining(
      String startStationTelecode,
      String endStationTelecode,
      String stationTrainCode,
      String date) async {
    Response response = await Connection.dio.post(_trainTicketRemaining,
        queryParameters: {
          'startStationTelecode': startStationTelecode,
          'endStationTelecode': endStationTelecode,
          'stationTrainCode': stationTrainCode,
          'date': date
        },
        options: Connection.options);
    if (response.data['code'] == 0) {
      List l = response.data['data'];
      return l.map((e) => RemainSeat.fromJson(e)).toList();
    } else {
      BotToast.showText(text: response.data['message']);
    }
    return [];
  }

  static Future<List<TrainStation>> trainStations(
      String stationTrainCode) async {
    Response response = await Connection.dio.post(_trainStations,
        queryParameters: {'stationTrainCode': stationTrainCode},
        options: Connection.options);
    if (response.data['code'] == 0) {
      List l = response.data['data'];
      return l.map((e) => TrainStation.fromJson(e)).toList();
    } else {
      BotToast.showText(text: response.data['message']);
    }
    return [];
  }

  static Future<List<String>> allStationTrainCode() async {
    Response response = await Connection.dio
        .post(_allStationTrainCode, options: Connection.options);
    if (response.data['code'] == 0) {
      List l = response.data['data'];
      return l.map((e) => e as String).toList();
    } else {
      BotToast.showText(text: response.data['message']);
    }
    return [];
  }

  static Future<bool> startTrain(String stationTrainCode) async {
    Response response = await Connection.dio.post(_startTrain,
        options: Connection.options,
        queryParameters: {'stationTrainCode': stationTrainCode});
    if (response.data['code'] == 0) {
      return response.data['data'];
    } else {
      BotToast.showText(text: response.data['message']);
    }
    return false;
  }

  static Future<bool> stopTrain(String stationTrainCode) async {
    Response response = await Connection.dio.post(_stopTrain,
        options: Connection.options,
        queryParameters: {'stationTrainCode': stationTrainCode});
    if (response.data['code'] == 0) {
      return response.data['data'];
    } else {
      BotToast.showText(text: response.data['message']);
    }
    return false;
  }

  static Future<bool> updateStartTime(String stationTrainCode,
      String stationTelecode, num stationNo, String? startTime) async {
    Response response = await Connection.dio
        .post(_updateStartTime, options: Connection.options, queryParameters: {
      'stationTrainCode': stationTrainCode,
      'stationTelecode': stationTelecode,
      'stationNo': stationNo,
      'startTime': startTime
    });
    if (response.data['code'] == 0) {
      return response.data['data'];
    } else {
      BotToast.showText(text: response.data['message']);
    }
    return false;
  }

  static Future<bool> updateArriveTime(String stationTrainCode,
      String stationTelecode, num stationNo, String? arriveTime) async {
    Response response = await Connection.dio
        .post(_updateArriveTime, options: Connection.options, queryParameters: {
      'stationTrainCode': stationTrainCode,
      'stationTelecode': stationTelecode,
      'stationNo': stationNo,
      'arriveTime': arriveTime
    });
    if (response.data['code'] == 0) {
      return response.data['data'];
    } else {
      BotToast.showText(text: response.data['message']);
    }
    return false;
  }
}

class StationApi {
  static String _allStations = host + '/station/allStations';
  static String _stationInfo = host + '/station/info';

  static List<Station> _stationCache = [];

  static Future<List<Station>> allStations() async {
    if (_stationCache.isNotEmpty) {
      return _stationCache;
    }
    Response response =
        await Connection.dio.post(_allStations, options: Connection.options);
    if (response.data['code'] == 0) {
      List l = response.data['data'];
      _stationCache = l.map((e) => Station.fromJson(e)).toList();
      return _stationCache;
    } else {
      BotToast.showText(text: response.data['message']);
    }
    return _stationCache;
  }

  static Station? cachedStationInfo(String stationTelecode) {
    if (_stationCache.isNotEmpty) {
      for (Station value in _stationCache) {
        if (value.telecode == stationTelecode) {
          return value;
        }
      }
    }
    return null;
  }

  static Future<Station?> stationInfo(String stationTelecode) async {
    if (_stationCache.isNotEmpty) {
      for (Station value in _stationCache) {
        if (value.telecode == stationTelecode) {
          return value;
        }
      }
    }
    Response response =
        await Connection.dio.post(_stationInfo, options: Connection.options);
    if (response.data['code'] == 0) {
      return Station.fromJson(response.data['data']);
    } else {
      BotToast.showText(text: response.data['message']);
    }
    return null;
  }

  static Future<void> updateStationCache() async {
    Response response =
        await Connection.dio.post(_allStations, options: Connection.options);
    if (response.data['code'] == 0) {
      List l = response.data['data'];
      _stationCache = l.map((e) => Station.fromJson(e)).toList();
    } else {
      BotToast.showText(text: response.data['message']);
    }
  }
}

class SeatTypeApi {
  static String _allSeatTypes = host + '/seatType/seatTypes';

  static Future<List<SeatType>> allSeatTypes() async {
    Response response =
        await Connection.dio.post(_allSeatTypes, options: Connection.options);
    if (response.data['code'] == 0) {
      List l = response.data['data'];
      return l.map((e) => SeatType.fromJson(e)).toList();
    } else {
      BotToast.showText(text: response.data['message']);
    }
    return [];
  }
}

class TrainClassApi {
  static String _allTrainClasses = host + '/trainClass/trainClass';

  static Future<List<TrainClass>> allTrainClasses() async {
    Response response = await Connection.dio
        .post(_allTrainClasses, options: Connection.options);
    if (response.data['code'] == 0) {
      List l = response.data['data'];
      return l.map((e) => TrainClass.fromJson(e)).toList();
    } else {
      BotToast.showText(text: response.data['message']);
    }
    return [];
  }
}

class TicketApi {
  static String _allMyTickets = host + "/ticket/userTickets";
  static String _allSelfTickets = host + "/ticket/selfTickets";
  static String _buyTicket = host + "/ticket/buyTicket";
  static String _changeTicket = host + "/ticket/changeTicket";
  static String _cancelTicket = host + "/ticket/cancelTicket";
  static String _ticketInfo = host + "/ticket/ticketInfo";
  static String _ticketInfoByOrder = host + "/ticket/ticketInfoByOrder";
  static String _transferSeatBigInteger =
      host + "/ticket/transferSeatBigInteger";

  static Future<List<Ticket>> allMyTicket() async {
    Response response =
        await Connection.dio.post(_allMyTickets, options: Connection.options);
    if (response.data['code'] == 0) {
      List l = response.data['data'];
      return l.map((e) => Ticket.fromJson(e)).toList();
    } else {
      BotToast.showText(text: response.data['message']);
    }
    return [];
  }

  static Future<List<Ticket>> allSelfTicket() async {
    Response response =
        await Connection.dio.post(_allSelfTickets, options: Connection.options);
    if (response.data['code'] == 0) {
      List l = response.data['data'];
      return l.map((e) => Ticket.fromJson(e)).toList();
    } else {
      BotToast.showText(text: response.data['message']);
    }
    return [];
  }

  static Future<int?> buyTicket(
      String startStationTelecode,
      String endStationTelecode,
      String stationTrainCode,
      String seatTypeCode,
      num passengerId,
      bool student,
      String date,
      String? preferSeat) async {
    Response response = await Connection.dio
        .post(_buyTicket, options: Connection.options, queryParameters: {
      'startStationTelecode': startStationTelecode,
      'endStationTelecode': endStationTelecode,
      'stationTrainCode': stationTrainCode,
      'seatTypeCode': seatTypeCode,
      'passengerId': passengerId,
      'student': student,
      'date': date,
      'preferSeat': preferSeat
    });
    if (response.data['code'] == 0) {
      return response.data['data'];
    } else {
      BotToast.showText(text: response.data['message']);
      return null;
    }
  }

  static Future<bool> cancelTicket(num ticketId) async {
    Response response = await Connection.dio.post(_cancelTicket,
        options: Connection.options, queryParameters: {'ticketId': ticketId});
    if (response.data['code'] == 0) {
      return response.data['data'];
    } else {
      BotToast.showText(text: response.data['message']);
    }
    return false;
  }

  static Future<Ticket?> ticketInfo(num ticketId) async {
    Response response = await Connection.dio.post(_ticketInfo,
        options: Connection.options, queryParameters: {'ticketId': ticketId});
    if (response.data['code'] == 0) {
      return response.data['data'];
    } else {
      BotToast.showText(text: response.data['message']);
    }
    return null;
  }

  static Future<List<Ticket>> ticketInfoByOrder(num orderId) async {
    Response response = await Connection.dio.post(_ticketInfoByOrder,
        options: Connection.options, queryParameters: {'orderId': orderId});
    if (response.data['code'] == 0) {
      List l = response.data['data'];
      return l.map((e) => Ticket.fromJson(e)).toList();
    } else {
      BotToast.showText(text: response.data['message']);
    }
    return [];
  }

  static Future<String> transferSeatBigInteger(
      {String? bigInteger, String? seatName}) async {
    Response response = await Connection.dio.post(_transferSeatBigInteger,
        options: Connection.options,
        queryParameters: {'bigInteger': bigInteger, 'seatName': seatName});
    return response.data['data'] ?? '';
  }

  static Future<Order?> changeTicket(
      num ticketId, String stationTrainCode) async {
    Response response = await Connection.dio.post(_changeTicket,
        options: Connection.options,
        queryParameters: {
          'ticketId': ticketId,
          'stationTrainCode': stationTrainCode
        });
    if (response.data['code'] == 0) {
      return Order.fromJson(response.data['data']);
    } else {
      BotToast.showText(text: response.data['message']);
      return null;
    }
  }
}

class OrderFormApi {
  static String _allMyOrders = host + "/orderForm/myOrderForms";
  static String _payOrderForm = host + "/orderForm/payOrderForm";
  static String _addOrderForm = host + "/orderForm/addOrderForm";
  static String _orderFormStatus = host + "/orderForm/orderFormStatus";
  static String _cancelOrderForm = host + "/orderForm/cancelOrderForm";

  static Future<List<Order>> allMyOrders() async {
    Response response =
        await Connection.dio.post(_allMyOrders, options: Connection.options);
    if (response.data['code'] == 0) {
      List l = response.data['data'];
      return l.map((e) => Order.fromJson(e)).toList();
    } else {
      BotToast.showText(text: response.data['message']);
    }
    return [];
  }

  static Future<Order?> addOrder(List<int> ticketId) async {
    Response response = await Connection.dio.post(_addOrderForm,
        options: Connection.options, data: jsonEncode(ticketId));
    if (response.data['code'] == 0) {
      return Order.fromJson(response.data['data']);
    } else {
      BotToast.showText(text: response.data['message']);
    }
    return null;
  }

  static Future<String?> payOrderForm(num orderId) async {
    Response response = await Connection.dio.post(_payOrderForm,
        options: Connection.options, queryParameters: {'orderId': orderId});
    if (response.data['code'] == 0) {
      return response.data['data'];
    } else {
      BotToast.showText(text: response.data['message']);
    }
    return null;
  }

  static Future<int> orderFormStatus(num orderId) async {
    Response response = await Connection.dio.post(_orderFormStatus,
        options: Connection.options, queryParameters: {'orderId': orderId});
    if (response.data['code'] == 0) {
      return response.data['data'];
    } else {
      BotToast.showText(text: response.data['message']);
    }
    return -1;
  }

  static Future<bool> cancelOrderForm(num orderId) async {
    Response response = await Connection.dio.post(_cancelOrderForm,
        options: Connection.options, queryParameters: {'orderId': orderId});
    if (response.data['code'] == 0) {
      return response.data['data'];
    } else {
      BotToast.showText(text: response.data['message']);
    }
    return false;
  }
}

class SystemApi {
  static String _systemSetting = host + '/system/systemSetting';
  static String _updateSystemSetting = host + '/system/updateSystemSetting';

  static Future<SystemSetting?> getSystemSetting() async {
    try {
      Response response = await Connection.dio
          .post(_systemSetting, options: Connection.options);
      if (response.data['code'] == 0) {
        return SystemSetting.fromJson(response.data['data']);
      } else {
        BotToast.showText(text: response.data['message']);
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  static Future<bool> updateSystemSetting(SystemSetting setting) async {
    try {
      Response response = await Connection.dio.post(_updateSystemSetting,
          options: Connection.options, data: setting.toJson());
      if (response.data['code'] == 0) {
        return response.data['data'] ?? false;
      } else {
        BotToast.showText(text: response.data['message']);
      }
    } catch (e) {
      return false;
    }
    return false;
  }
}

class PassengerApi {
  static String _allMyPassenger = host + '/passenger/myPassengers';
  static String _addPassenger = host + '/passenger/addPassenger';
  static String _removePassenger = host + '/passenger/removePassenger';

  static Future<List<Passenger>> allMyPassengers() async {
    Response response =
        await Connection.dio.post(_allMyPassenger, options: Connection.options);
    if (response.data['code'] == 0) {
      List l = response.data['data'];
      return l.map((e) => Passenger.fromJson(e)).toList();
    } else {
      BotToast.showText(text: response.data['message']);
    }
    return [];
  }

  static Future<Passenger?> addPassenger(Passenger passenger) async {
    Response response = await Connection.dio.post(_addPassenger,
        options: Connection.options, queryParameters: passenger.toJson());
    if (response.data['code'] == 0) {
      return Passenger.fromJson(response.data['data']);
    } else {
      BotToast.showText(text: response.data['message']);
    }
    return null;
  }

  static Future<bool> removePassenger(int passengerId) async {
    Response response = await Connection.dio
        .post(_removePassenger, options: Connection.options);
    if (response.data['code'] == 0) {
      return true;
    } else {
      BotToast.showText(text: response.data['message']);
    }
    return false;
  }
}

class CoachApi {
  static String _coachInfo = host + '/coach/coachInfo';
  static String _trainCoachList = host + '/coach/trainCoaches';
  static String _updateCoach = host + '/admin/updateCoach';
  static String _addCoach = host + '/admin/addCoach';
  static String _deleteCoach = host + '/admin/deleteCoach';

  static Future<Coach?> coachInfo(num coachId) async {
    Response response = await Connection.dio.post(_coachInfo,
        options: Connection.options, queryParameters: {'coachId': coachId});
    if (response.data['code'] == 0) {
      return Coach.fromJson(response.data['data']);
    } else {
      BotToast.showText(text: response.data['message'] ?? '未找到车厢');
    }
    return null;
  }

  static Future<List<Coach>> trainCoachList(String stationTrainCode) async {
    Response response = await Connection.dio.post(_trainCoachList,
        options: Connection.options,
        queryParameters: {'stationTrainCode': stationTrainCode});
    if (response.data['code'] == 0) {
      List l = response.data['data'];
      return l.map((e) => Coach.fromJson(e)).toList();
    } else {
      BotToast.showText(text: response.data['message']);
    }
    return [];
  }

  static Future<bool> updateCoach(
      num coachId, num seatCount, String seatTypeCode) async {
    Response response = await Connection.dio.post(_updateCoach,
        options: Connection.options,
        queryParameters: {
          'coachId': coachId,
          'seatCount': seatCount,
          'seatTypeCode': seatTypeCode
        });
    if (response.data['code'] == 0) {
      return response.data['code'] == 0;
    } else {
      BotToast.showText(text: response.data['message'] ?? '未找到车厢');
    }
    return false;
  }

  static Future<bool> addCoach(num coachNo, num seatCount, String seatTypeCode,
      String stationTrainCode) async {
    Response response = await Connection.dio
        .post(_addCoach, options: Connection.options, queryParameters: {
      'coachNo': coachNo,
      'seatCount': seatCount,
      'seatTypeCode': seatTypeCode,
      'stationTrainCode': stationTrainCode
    });
    if (response.data['code'] == 0) {
      return response.data['code'] == 0;
    } else {
      BotToast.showText(text: response.data['message'] ?? '未找到车厢');
    }
    return false;
  }

  static Future<bool> deleteCoach(num coachId) async {
    Response response = await Connection.dio
        .post(_deleteCoach, options: Connection.options, queryParameters: {
      'coachId': coachId,
    });
    if (response.data['code'] == 0) {
      return response.data['code'] == 0;
    } else {
      BotToast.showText(text: response.data['message'] ?? '未找到车厢');
    }
    return false;
  }
}

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'global.dart';
import './pages/login.dart';
import './model/task.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class Common {
  static FlutterLocalNotificationsPlugin _localNotifications;
  static NotificationDetails _platformChannelSpecifics;
  static int _notificationIndex;

  // md5 加密
  static String generateMd5(String data) {
    var content = new Utf8Encoder().convert(data);
    var digest = md5.convert(content);
    return hex.encode(digest.bytes);
  }

  static saveToken(String token, String refreshToken) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('token', token);
      prefs.setString('refreshToken', refreshToken);
      $token = token;
      $refreshToken = refreshToken;
      return true;
    } catch (err) {
      print(err);
      return false;
    }
  }

  static syncToken() async {
    if ($refreshToken == null) {
      final prefs = await SharedPreferences.getInstance();
      $token = prefs.getString('token') ?? '';
      $refreshToken = prefs.getString('refreshToken') ?? '';
    }
  }

  static removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('token');
    prefs.remove('refreshToken');
    $token = null;
    $refreshToken = null;
  }

  static base64ToJson(str) {
    const _SEGMENT_LENGTH = 4;
    String input = str;
    final sb = new StringBuffer(input);
    final diff = input.length % _SEGMENT_LENGTH;
    if (diff != 0) {
      var padLength = _SEGMENT_LENGTH - diff;
      while (padLength-- > 0) {
        sb.write('=');
      }
      input = sb.toString();
    }
    input = input
        .replaceAll(new RegExp(r'\-'), '+')
        .replaceAll(new RegExp(r'_'), '/');
    return jsonDecode(utf8.decode(base64Url.decode(input)));
  }

  static logout([reason]) {
    $navigatorKey.currentState.pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LoginPage(reason)),
        (Route<dynamic> route) => false);
    removeToken();
    removeTaskRemind();
  }

  static handleApiError(DioError err) {
    if (err.type == DioErrorType.CANCEL) {
      return null;
    }
    if (err.response != null &&
        err.response.data != null &&
        err.response.data['errmsg'] != null) {
      return err.response.data['errmsg'];
    }
    if (err.message != null && $ERRMSG.containsKey(err.message)) {
      return $ERRMSG[err.message];
    }
    return $ERRMSG['api'];
  }

  static handleError(err, {var context}) {
    String msg = $ERRMSG['unknow'];
    if (err is DioError) {
      msg = handleApiError(err);
    } else {
      print(err);
    }
    if (context != null && msg != null && msg.length > 0) {
      Common.showSnackBar(context, msg, isError: true);
    }
  }

  static showSnackBar(var context, String text, {bool isError = false}) {
    var _context;
    var _scaffold;
    if (context is BuildContext) {
      _context = context;
      _scaffold = Scaffold.of(context);
    } else if (context is GlobalKey<ScaffoldState>) {
      _scaffold = context.currentState;
      _context = _scaffold.context;
    }
    _scaffold.showSnackBar(SnackBar(
      content: Text(text),
      backgroundColor: isError
          ? Theme.of(_context).errorColor
          : Theme.of(_context).primaryColor,
    ));
  }

  // 补零
  static fillZero(var num, [length = 2]) {
    num = num.toString();
    while (num.length < length) {
      num = '0' + num;
    }
    return num;
  }

  static initNotificationsPlugin() {
    if (_localNotifications == null) {
      _localNotifications = new FlutterLocalNotificationsPlugin();
      var initializationSettingsAndroid =
          new AndroidInitializationSettings('app_icon');
      var initializationSettingsIOS = new IOSInitializationSettings();
      var initializationSettings = new InitializationSettings(
          initializationSettingsAndroid, initializationSettingsIOS);
      _localNotifications.initialize(initializationSettings);
      var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
          'check_today', '今日打卡', '今日打卡',
          importance: Importance.Max, priority: Priority.High);
      var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
      _platformChannelSpecifics = new NotificationDetails(
          androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    }
  }

  static initNotificationIndex() async {
    if (_notificationIndex != null) return;
    final prefs = await SharedPreferences.getInstance();
    String mapString = prefs.getString('remindMap') ?? '{}';
    if (mapString == '{}') {
      _notificationIndex = 0;
      return;
    }
    Map map = json.decode(mapString);
    int max = 0;
    map.forEach((key, val) {
      var temp = val[val.length - 1];
      max = temp > max ? temp : max;
    });
    _notificationIndex = max;
  }

  // 设置提醒
  static setTaskRemind(Task task) async {
    if (task.remindDays.length == 0) return;
    initNotificationsPlugin();
    await initNotificationIndex();
    if (task.remindDays.length >= 7) {
      updateRemindMap(task.id, [_notificationIndex]);
      await _localNotifications.showDailyAtTime(
          _notificationIndex++,
          task.title,
          task.title,
          new Time(task.remindTime.hour, task.remindTime.minute, 0),
          _platformChannelSpecifics);
    } else {
      List<int> mapVal = [];
      task.remindDays.forEach((day) async {
        mapVal.add(_notificationIndex);
        await _localNotifications.showWeeklyAtDayAndTime(
            _notificationIndex++,
            task.title,
            task.title,
            day.refDay,
            new Time(task.remindTime.hour, task.remindTime.minute, 0),
            _platformChannelSpecifics);
      });
      updateRemindMap(task.id, mapVal);
    }
  }

  // 删除提醒
  static removeTaskRemind({index}) {
    initNotificationsPlugin();
    if (index == null) {
      _localNotifications.cancelAll();
    } else {
      _localNotifications.cancel(index);
    }
    removeRemindMap();
  }

  static updateRemindMap(String key, List<int> value) async {
    final prefs = await SharedPreferences.getInstance();
    String mapString = prefs.getString('remindMap') ?? '{}';
    Map map = json.decode(mapString);
    if (map.containsKey(key)) {
      map[key].forEach(removeTaskRemind);
      if (value == null || value.length == 0) {
        map.remove(key);
      } else {
        map[key] = value;
      }
    } else {
      map[key] = value;
    }
    prefs.setString('remindMap', json.encode(map));
  }

  static removeRemindMap() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('remindMap');
  }
}

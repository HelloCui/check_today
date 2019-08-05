library check_today.globals;

import 'package:flutter_local_notifications/flutter_local_notifications.dart' as notification;
import './class/day.dart';

double $screenWidth;
var $borderSide;
bool $notNull(Object o) => o != null;
var $token;
var $refreshToken;
var $scaffoldKey;
var $navigatorKey;
const $ERRMSG = {
  'token': '鉴权失败，请重新登录',
  'api': '接口异常，请稍后重试',
  'unknow': '程序异常，请上报开发者',
};
List<Day> $weekDay = [
  Day(1, '周一', notification.Day.Monday),
  Day(2, '周二', notification.Day.Tuesday),
  Day(3, '周三', notification.Day.Wednesday),
  Day(4, '周四', notification.Day.Thursday),
  Day(5, '周五', notification.Day.Friday),
  Day(6, '周六', notification.Day.Saturday),
  Day(7, '周日', notification.Day.Sunday),
];
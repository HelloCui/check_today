import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'global.dart';
import './pages/login.dart';

class Common{
  // md5 加密
  static String generateMd5(String data) {
    var content = new Utf8Encoder().convert(data);
    var digest = md5.convert(content);
    return hex.encode(digest.bytes);
  }

  static Future saveToken(String token, String refreshToken) async{
    try {
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('token', token);
      prefs.setString('refreshToken', refreshToken);
      $token = token;
      $refreshToken = refreshToken;
      return true;
    } catch(err) {
      print(err);
      return false;
    }
  }

  static syncToken() async{
    if($refreshToken == null) {
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
    input = input.replaceAll(new RegExp(r'\-'), '+').replaceAll(new RegExp(r'_'), '/');
    return jsonDecode(utf8.decode(base64Url.decode(input)));
  }

  static logout([reason]) {
    $navigatorKey.currentState.pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LoginPage(reason)), (Route<dynamic> route) => false);
//    $navigatorKey.currentState.pushNamedAndRemoveUntil('/login',
//            (Route<dynamic> route) => false);
    removeToken();
  }

  static handleApiError(DioError err) {
    if(err.type == DioErrorType.CANCEL) {
      return null;
    }
    if(err.response != null && err.response.data != null && err.response.data['errmsg'] != null) {
      return err.response.data['errmsg'];
    }
    if(err.message != null && $ERRMSG.containsKey(err.message)) {
      return $ERRMSG[err.message];
    }
    return $ERRMSG['api'];
  }

  static handleError(err, {var context}) {
    String msg = $ERRMSG['unknow'];
    if(err is DioError) {
      msg = handleApiError(err);
    } else {
      print(err);
    }
    if(context != null && msg != null && msg.length > 0) {
      Common.showSnackBar(context, msg,
          isError: true);
    }
  }

  static showSnackBar(var context, String text, {bool isError = false}) {
    var _context;
    var _scaffold;
    if(context is BuildContext) {
      _context = context;
      _scaffold = Scaffold.of(context);
    } else if(context is GlobalKey<ScaffoldState>) {
      _scaffold = context.currentState;
      _context = _scaffold.context;
    }
    _scaffold.showSnackBar(SnackBar(content: Text(text),
      backgroundColor: isError ? Theme.of(_context).errorColor : Theme.of(_context).primaryColor,));
  }
}
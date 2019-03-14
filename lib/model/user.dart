import 'dart:async';
import 'package:json_annotation/json_annotation.dart';
import 'package:dio/dio.dart';
import 'dio.dart';
import '../common.dart';
import '../global.dart';
part 'user.g.dart';

@JsonSerializable()
class User {
  String id;
  String name;
  String password;
  String refreshToken;

  User({this.id, this.name, this.password, this.refreshToken});

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);

  static Future canRegister(String name) async {
    final res = await dio.get('/canRegister/$name');
    if (res.data['status'] == true) {
      return res.data['canRegister'];
    }
    throw DioError(response: res);
  }

  Future register() async {
    final res = await dio.post('/register', data: this.toJson());
    if(res.data['status'] == true) {
      final token = res.data['token'];
      final refreshToken = res.data['refreshToken'];
      await Common.saveToken(token, refreshToken);
    }
    return res.data;
  }

  Future login() async {
    final res = await dio.post('/login', data: this.toJson());
    if(res.data['status'] == true) {
      final token = res.data['token'];
      final refreshToken = res.data['refreshToken'];
      await Common.saveToken(token, refreshToken);
    }
    return res.data;
  }

  static Future getToken() async {
    try {
      final res = await tokenDio.get('/token', queryParameters: {'refreshToken': $refreshToken, 'token': $token});
      if (res.data['status'] == true) {
        final token = res.data['token'];
        final refreshToken = res.data['refreshToken'];
        final result = await Common.saveToken(token, refreshToken);
        return result;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}
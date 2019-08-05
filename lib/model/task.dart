import 'dart:async';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:dio/dio.dart';
import 'dio.dart';
import '../common.dart';
import '../class/day.dart';
import '../global.dart';
part 'task.g.dart';

@JsonSerializable()
@_TimeConverter.instance
@_DayConverter.instance
class Task {
  String id;
  String title;
  int iconCode;
  bool isRemind;
  List<Day> remindDays;
  TimeOfDay remindTime;

  Task({this.id, this.iconCode, this.title, this.isRemind, this.remindDays});

  factory Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);
  Map<String, dynamic> toJson() => _$TaskToJson(this);

  Future save() async {
    var res;
    if (this.id == null) {
      res = await dio.post('/checktoday/task', data: this.toJson());
    } else {
      res = await dio.put('/checktoday/task/${this.id}', data: this.toJson());
    }
    if (res.data['status'] == true) {
      if(this.id == null) this.id = res.data['id'];
      return true;
    }
    throw DioError(response: res);
  }

  Future remove() async {
    final res = await dio.delete('/checktoday/task/${this.id}');
    if (res.data['status'] == true) {
      return true;
    }
    throw DioError(response: res);
  }

  static Future findOne(String id) async {
    final response = await dio.get('/checktoday/task/$id');
    return Task.fromJson(response.data);
  }

  // 获取列表数据
  static Future findReminds() async {
    final response = await dio.get('/checktoday/remindtask');
    return parseList(response.data);
  }

  // 将列表数据从json转换成对象集合
  static List parseList(data) {
    return data.map<Task>((json) => Task.fromJson(json)).toList();
  }
}

@JsonSerializable()
class Today {
  String id;
  String taskId;
  String title;
  int iconCode;
  bool isChecked;

  Today({this.id, this.taskId, this.title, this.iconCode, this.isChecked});

  factory Today.fromJson(Map<String, dynamic> json) => _$TodayFromJson(json);
  Map<String, dynamic> toJson() => _$TodayToJson(this);

  // 获取列表数据
  static Future fetchList() async {
    final response = await dio.get('/checktoday/today');
    return parseList(response.data);
  }

  Future check() async {
    final res = await dio.put('/checktoday/check/${this.id}', data: this.toJson());
    if (res.data['status'] == true) {
      return true;
    }
    throw DioError(response: res);
  }

  Future uncheck() async {
    final res = await dio.put('/checktoday/uncheck/${this.id}', data: this.toJson());
    if (res.data['status'] == true) {
      return true;
    }
    throw DioError(response: res);
  }

  // 将列表数据从json转换成对象集合
  static List parseList(data) {
    return data.map<Today>((json) => Today.fromJson(json)).toList();
  }
}

@JsonSerializable()
class History {
  String id;
  String taskId;
  String title;
  int iconCode;
  bool isChecked;

  History({this.id, this.taskId, this.title, this.iconCode, this.isChecked});
}

class _TimeConverter implements JsonConverter<TimeOfDay, String> {
  static const instance = const _TimeConverter();
  const _TimeConverter();

  @override
  TimeOfDay fromJson(String json) {
    if(json == null || json.length == 0) {
      return null;
    } else {
      List arr = json.split(':');
      return new TimeOfDay(hour: int.parse(arr[0]), minute: int.parse(arr[1]));
    }
  }

  @override
  String toJson(TimeOfDay object)  => object == null ? '' : '${Common.fillZero(object.hour)}:${Common.fillZero(object.minute)}';
}

class _DayConverter implements JsonConverter<Day, int> {
  static const instance = const _DayConverter();
  const _DayConverter();

  @override
  Day fromJson(int json) {
    if(json == null) return null;
    return $weekDay.firstWhere((item) => item.code == json);
  }

  @override
  int toJson(Day object) => object?.code;
}
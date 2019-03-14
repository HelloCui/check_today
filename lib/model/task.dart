import 'dart:async';
import 'package:json_annotation/json_annotation.dart';
import 'package:dio/dio.dart';
import 'dio.dart';
part 'task.g.dart';

@JsonSerializable()
class Task {
  String id;
  String title;
  int iconCode;

  Task({this.id, this.iconCode, this.title});

  factory Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);
  Map<String, dynamic> toJson() => _$TaskToJson(this);

  Future save() async {
    var res;
    if (this.id == null) {
      res = await dio.post('/checktoday/task', data: this.toJson());
    } else {
      res = await dio.put('/checktoday/task/${this.id}', data: this.toJson());
    }
    if (res.statusCode == 200) {
      return true;
    }
    throw DioError(response: res);
  }

  Future remove() async {
    final res = await dio.delete('/checktoday/task/${this.id}');
    if (res.statusCode == 200) {
      return true;
    }
    throw DioError(response: res);
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
    if (res.statusCode == 200) {
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

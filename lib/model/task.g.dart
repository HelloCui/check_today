// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Task _$TaskFromJson(Map<String, dynamic> json) {
  return Task(
      id: json['id'] as String,
      iconCode: json['iconCode'] as int,
      title: json['title'] as String);
}

Map<String, dynamic> _$TaskToJson(Task instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('id', instance.id);
  writeNotNull('title', instance.title);
  writeNotNull('iconCode', instance.iconCode);
  return val;
}

Today _$TodayFromJson(Map<String, dynamic> json) {
  return Today(
      id: json['id'] as String,
      taskId: json['taskId'] as String,
      title: json['title'] as String,
      iconCode: json['iconCode'] as int,
      isChecked: json['isChecked'] as bool);
}

Map<String, dynamic> _$TodayToJson(Today instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('id', instance.id);
  writeNotNull('taskId', instance.taskId);
  writeNotNull('title', instance.title);
  writeNotNull('iconCode', instance.iconCode);
  writeNotNull('isChecked', instance.isChecked);
  return val;
}

History _$HistoryFromJson(Map<String, dynamic> json) {
  return History(
      id: json['id'] as String,
      taskId: json['taskId'] as String,
      title: json['title'] as String,
      iconCode: json['iconCode'] as int,
      isChecked: json['isChecked'] as bool);
}

Map<String, dynamic> _$HistoryToJson(History instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('id', instance.id);
  writeNotNull('taskId', instance.taskId);
  writeNotNull('title', instance.title);
  writeNotNull('iconCode', instance.iconCode);
  writeNotNull('isChecked', instance.isChecked);
  return val;
}

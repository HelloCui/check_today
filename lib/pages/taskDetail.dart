import 'dart:async';
import 'package:flutter/material.dart';
import '../global.dart';
import '../model/task.dart';
import '../common.dart';
import '../widgets/weekSheet.dart';
import '../class/day.dart';

class TaskDetail extends StatefulWidget {
  final item;
  TaskDetail(this.item);
  @override
  _TaskDetailState createState() => _TaskDetailState();
}

class _TaskDetailState extends State<TaskDetail> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  double _padding = 15;
  double _iconPerLine = 5;
  double _spacing = 15;
  BorderSide _border = $borderSide;
  double _iconWidth;
  bool _isAdd = true;
  Task _task = new Task(isRemind: false);
  TextEditingController _textCtrl;
  // 记录提醒时间是否被修改，如果是，在提交完成设置系统提醒
  bool _remindDirty = false;

  @override
  void initState() {
    super.initState();
    $scaffoldKey = _scaffoldKey;
    _iconWidth = ($screenWidth - _padding * 2) / _iconPerLine;
    if (widget.item != null) {
      Task.findOne(widget.item.taskId).then((res) {
        _task = res;
        _task.isRemind = _task.isRemind ?? false;
        _initTime();
        _textCtrl = new TextEditingController(text: _task.title);
        _isAdd = false;
        setState(() {});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text(_isAdd ? '创建任务' : '修改任务'),
        ),
        body: Container(
          padding: EdgeInsets.fromLTRB(_padding, 20, _padding, 20),
          child: Column(
            children: <Widget>[
              TextField(
                decoration: InputDecoration(
                  hintText: '标题',
                ),
                controller: _textCtrl,
                onChanged: (newValue) => _task.title = newValue,
              ),
              SizedBox(height: _spacing),
              Wrap(
                children: _getAllIcons(),
              ),
              SizedBox(height: _spacing),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('指定时间提醒'),
                  Switch(
                      value: _task.isRemind,
                      onChanged: (value) {
                        //重新构建页面
                        setState(() {
                          _task.isRemind = value;
                          _initTime();
                        });
                        _remindDirty = true;
                      })
                ],
              ),
              SizedBox(
                height: _spacing,
              ),
              !_task.isRemind
                  ? Container()
                  : Column(children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text('提醒时间'),
                          GestureDetector(
                            child: Text(
                                '${Common.fillZero(_task.remindTime.hour)}:${Common.fillZero(_task.remindTime.minute)}'),
                            onTap: () {
                              _pickTime();
                            },
                          )
                        ],
                      ),
                      SizedBox(
                        height: _spacing,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text('重复'),
                          GestureDetector(
                              child: Text(
                                selectedDaysStr(),
                                textAlign: TextAlign.right,
                              ),
                              onTap: () {
                                Future close = showModalBottomSheet<void>(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return WeekSheet(
                                          _task.remindDays, _selectCallback);
                                    });
                                close.then((result) => {setState(() {})});
                              }),
                        ],
                      ),
                    ])
            ],
          ),
        ),
        floatingActionButton: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            _isAdd
                ? null
                : FloatingActionButton(
                    heroTag: null,
                    backgroundColor: Colors.red[400],
                    child: Text('删除'),
                    onPressed: _delete,
                  ),
            SizedBox(width: 15.0),
            FloatingActionButton(
              heroTag: null,
              child: Text('提交'),
              onPressed: _submit,
            )
          ].where($notNull).toList(),
        ));
  }

  List<Widget> _getAllIcons() {
    List iconCodes = [0xe68d, 0xe60e, 0xe883, 0xe662, 0xe661, 0xe624, 0xe63e];
    return List<Widget>.generate(iconCodes.length, (index) {
      return Container(
          width: _iconWidth,
          height: _iconWidth,
          decoration: BoxDecoration(
              color: Colors.white,
              border: _task.iconCode == iconCodes[index]
                  ? Border.all(width: 2.0, color: Colors.black)
                  : Border(
                      top: index < _iconPerLine ? _border : BorderSide.none,
                      left:
                          index % _iconPerLine == 0 ? _border : BorderSide.none,
                      right: _border,
                      bottom: _border,
                    )),
          child: IconButton(
              icon: Icon(IconData(iconCodes[index], fontFamily: 'iconfont')),
              onPressed: () {
                setState(() {
                  _task.iconCode = iconCodes[index];
                });
              }));
    });
  }

  _submit() async {
    String errMsg = '';
    if (_task.title == '' || _task.title == null) {
      errMsg += '标题、';
    }
    if (_task.iconCode == null) {
      errMsg += '图标、';
    }
    if (errMsg.length > 0) {
      errMsg = errMsg.substring(0, errMsg.length - 1);
      _scaffoldKey.currentState
          .showSnackBar(SnackBar(content: Text('请完善$errMsg信息。')));
      return;
    }
    try {
      await _task.save();
      if(_remindDirty) {
        await Common.setTaskRemind(_task);
      }
      Navigator.pop(context, 'refresh');
    } catch (e) {
      Common.handleError(e, context: _scaffoldKey);
    }
  }

  _delete() async {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('警告'),
          content: Text('删除后将无法恢复，是否继续？'),
          actions: <Widget>[
            FlatButton(
              child: Text('取消'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            FlatButton(
              child: Text(
                '删除',
                style: TextStyle(color: Colors.red[400]),
              ),
              onPressed: () async {
                try {
                  await _task.remove();
                  Navigator.pop(context);
                  Navigator.pop(context, 'refresh');
                } catch (e) {
                  Common.handleError(e, context: _scaffoldKey);
                }
              },
            ),
          ],
        );
      },
    );
  }

  _pickTime() async {
    TimeOfDay time =
        await showTimePicker(context: context, initialTime: _task.remindTime);
    if (time != null) {
      setState(() {
        _task.remindTime = time;
      });
      _remindDirty = true;
    }
  }

  void _selectCallback(List<Day> selectedItem) {
    _task.remindDays = selectedItem;
    _remindDirty = true;
  }

  String selectedDaysStr() {
    if (_task.remindDays == null) return '请选择';
    switch (_task.remindDays.length) {
      case 0:
        return '请选择';
      case 7:
        return '每天';
      default:
        return (_task.remindDays..sort((a, b) => a.code - b.code))
            .map((item) => item.name)
            .toList()
            .join('，');
    }
  }

  void _initTime() {
    if (!_task.isRemind) return;
    _task.remindTime =
        _task.remindTime ?? TimeOfDay(hour: TimeOfDay.now().hour, minute: 0);
    _task.remindDays = _task.remindDays ?? ([]..addAll($weekDay));
  }
}

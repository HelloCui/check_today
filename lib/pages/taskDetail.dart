import 'package:flutter/material.dart';
import '../global.dart';
import '../model/task.dart';

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
  Task _task;
  TextEditingController _textCtrl;

  @override
  void initState() {
    super.initState();
    $scaffoldKey = _scaffoldKey;
    _iconWidth = ($screenWidth - _padding * 2) / _iconPerLine;
    if (widget.item != null) {
      _task = new Task(
        id: widget.item.taskId,
        title: widget.item.title,
        iconCode: widget.item.iconCode
      );
      _textCtrl = new TextEditingController(text: _task.title);
      _isAdd = false;
    } else {
      _task = new Task();
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
                onChanged: ( newValue) => _task.title = newValue,
              ),
              SizedBox(height: _spacing),
              Wrap(
                children: _getAllIcons(),
              )
            ],
          ),
        ),
        floatingActionButton: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            _isAdd ? null : FloatingActionButton(
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
      final result = await _task.save();
      if(result == true) {
        Navigator.pop(context, 'refresh');
      } else {
        throw('Task save error!');
      }
    } catch (e) {
      print(e);
      _scaffoldKey.currentState
          .showSnackBar(SnackBar(content: Text('创建失败，请稍后重试。')));
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
              onPressed: () async{
                try {
                  final bool res = await _task.remove();
                  if(res == true) {
                    Navigator.pop(context);
                    Navigator.pop(context, 'refresh');
                  } else {
                    throw('Task remove error!');
                  }
                } catch(e) {
                  print(e);
                  _scaffoldKey.currentState
                      .showSnackBar(SnackBar(content: Text('删除失败，请稍后重试。')));
                }
              },
            ),
          ],
        );
      },
    );
  }
}

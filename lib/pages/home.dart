import 'package:flutter/material.dart';
import '../model/task.dart';
import '../global.dart';
import 'taskDetail.dart';
import '../widgets/todayItem.dart';
import '../common.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List _checkList = [];
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    $scaffoldKey = _scaffoldKey;
    _getData();
  }

  @override
  Widget build(BuildContext context) {
    _setGlobalValue(context);

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('今日打卡'),
        automaticallyImplyLeading: false,
        actions: <Widget>[
          FlatButton(
            child: Text(
              '登出',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () {
              Common.logout();
            },
          )
        ],
      ),
      body: Wrap(children: _createCheckItem()),
      floatingActionButton:
          FloatingActionButton(child: Icon(Icons.add), onPressed: _goAddPage),
    );
  }

  List<Widget> _createCheckItem() {
    return new List<Widget>.generate(_checkList.length, (int index) {
      var data = _checkList[index];
      return TodayItem(data, index, _goAddPage);
    });
  }

  _setGlobalValue(context) {
    $screenWidth = MediaQuery.of(context).size.width;
    $borderSide = BorderSide(color: Theme.of(context).dividerColor);
  }

  _getData() async {
    try {
      final todayList = await Today.fetchList();
      if (todayList != null) {
        setState(() {
          _checkList = todayList;
        });
      }
    } catch(e) {
      Common.handleError(e, context: _scaffoldKey);
    }
  }

  _goAddPage({item}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TaskDetail(item)),
    );
    if (result == 'refresh') {
      _getData();
    }
  }
}

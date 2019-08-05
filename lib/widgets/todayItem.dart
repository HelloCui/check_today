import 'package:flutter/material.dart';
import '../model/task.dart';
import '../global.dart';
import '../common.dart';

class TodayItem extends StatefulWidget {
  final data;
  final index;
  final longPressEvent;
  TodayItem(this.data, this.index, this.longPressEvent);

  @override
  _TodayItemState createState() => _TodayItemState();
}

class _TodayItemState extends State<TodayItem> {
  @override
  Widget build(BuildContext context) {
    final _iconsPerLine = 4;
    final _itemWidth = $screenWidth / _iconsPerLine;
    final data = widget.data;
    final index = widget.index;
    return GestureDetector(
        onTap: () {
          try {
            _check(data);
          } catch(e) {
            Common.handleError(e, context: context);
          }
        },
        onLongPress: () {
          widget.longPressEvent(item: data);
        },
        child: Container(
          decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                right: (index + 1) % _iconsPerLine == 0
                    ? BorderSide.none
                    : $borderSide,
                bottom: $borderSide,
              )),
          width: _itemWidth,
          height: _itemWidth - 10,
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Positioned(
                top: _itemWidth / 2 - 24,
                child: Icon(
                  IconData(data.iconCode, fontFamily: 'iconfont'),
                  color: Theme.of(context).iconTheme.color,
                ),
              ),
              Positioned(
                top: _itemWidth / 2,
                child: Text(
                  data.title,
                  style: TextStyle(
                      color: Theme.of(context).textTheme.button.color),
                ),
              ),
              data.isChecked == true
                  ? Positioned(
                      top: 0,
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        color: Color.fromARGB(450, 255, 255, 255),
                        child: Icon(
                          Icons.check,
                          size: 45,
                          color: Colors.green,
                        ),
                      ),
                    )
                  : null
            ].where($notNull).toList(),
          ),
        ));
  }

  _check(Today today) async {
    try{
      bool result = false;
      if (today.isChecked != true) {
        result = await today.check();
        if (result) {
          setState(() {
            today.isChecked = true;
          });
        }
      } else {
        result = await today.uncheck();
        if (result) {
          setState(() {
            today.isChecked = false;
          });
        }
      }
    } catch(e){
      Common.handleError(e, context: context);
    }

  }
}

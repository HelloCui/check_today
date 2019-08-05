import 'package:flutter/material.dart';
import '../class/day.dart';
import '../global.dart';

class WeekSheet extends StatefulWidget {
  final List<Day> selectedDays;
  final Function selectCallback;
  WeekSheet(this.selectedDays, this.selectCallback);

  @override
  _WeekSheetState createState() => _WeekSheetState();
}

class _WeekSheetState extends State<WeekSheet> {
  List<Day> _dayList = []..addAll($weekDay);
  List<Day> _selectedDays = [];

  @override
  void initState() {
    if(widget.selectedDays == null || widget.selectedDays.length == 0) {
      _selectedDays = [];
    } else if(widget.selectedDays.length == _dayList.length) {
      _selectedDays = []..addAll(_dayList);
    } else {
      widget.selectedDays.forEach((item){
        Day _day = _dayList.firstWhere((item2) => item2.code == item.code, orElse: () => null);
        if(_day != null) {
          _selectedDays.add(_day);
        }
      });
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView.builder(
          itemCount: _dayList.length + 1,
          shrinkWrap: true,
          itemBuilder: (BuildContext context, int index) {
            Day item = index == 0 ? new Day(0, '每天', null) : _dayList[index - 1];
            return GestureDetector(
              onTap: () {
                if(item.code == 0) {
                  _selectedDays = []..addAll(_dayList);
                } else {
                  if(_selectedDays.contains(item)) {
                    _selectedDays.remove(item);
                  } else {
                    _selectedDays.add(item);
                  }
                }
                setState((){});
                widget.selectCallback(_selectedDays);
              },
              child: Container(
                decoration: BoxDecoration(
                  border: Border(bottom: $borderSide),
                  color: (index == 0 && _selectedDays.length == 7) || _selectedDays.contains(item) ? Colors.black : Colors.white,
                ),
                padding: EdgeInsets.all(15.0),
                child: Center(child: Text(
                    item.name,
                  style: TextStyle(
                    color: (index == 0 && _selectedDays.length == 7) || _selectedDays.contains(item) ? Colors.white : Colors.black
                  ),
                )),
              ),
            );
          }),
    );
  }
}

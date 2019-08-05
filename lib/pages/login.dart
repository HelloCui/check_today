import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:async';
import '../model/user.dart';
import '../model/task.dart';
import '../common.dart';
import '../global.dart';
import 'package:flutter/scheduler.dart' as Scheduler;

class LoginPage extends StatefulWidget {
  final reason;

  LoginPage([this.reason]);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  AnimationController _amController;
  Animation<double> _frontAm;
  Animation<double> _backAm;
  bool _isBack = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    $scaffoldKey = _scaffoldKey;
    super.initState();
    if(widget.reason != null) {
      Scheduler.SchedulerBinding.instance.addPostFrameCallback((context){
        Common.showSnackBar(_scaffoldKey, widget.reason, isError: true);
      });
    }
    _amController = new AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _frontAm = new Tween(
      begin: 0.0,
      end: math.pi / 2,
    ).animate(new CurvedAnimation(
      parent: _amController,
      curve: new Interval(0.0, 0.5, curve: Curves.easeIn),
    ));
    _backAm = new Tween(
      begin: -math.pi / 2,
      end: 0.0,
    ).animate(new CurvedAnimation(
      parent: _amController,
      curve: new Interval(0.5, 1.0, curve: Curves.easeOut),
    ))
      ..addStatusListener((status) {
        if (status == AnimationStatus.forward) {
          setState(() {
            _isBack = true;
          });
        } else if (status == AnimationStatus.dismissed) {
          setState(() {
            _isBack = false;
          });
        }
      });
  }

  @override
  void dispose() {
    _amController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        key: _scaffoldKey,
        appBar: null,
        body: SingleChildScrollView(
          padding: EdgeInsets.only(
              top: MediaQuery.of(context).size.height * 0.3,
              left: 30,
              right: 30),
          child: new Stack(
            children: <Widget>[
              new AnimatedBuilder(
                child: LoginCard(_amController),
                animation: _frontAm,
                builder: (BuildContext context, Widget child) {
                  final Matrix4 transform = new Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateY(_frontAm.value);
                  return new Transform(
                    transform: transform,
                    alignment: Alignment.center,
                    child: child,
                  );
                },
              ),
              IgnorePointer(
                ignoring: !_isBack,
                child: new AnimatedBuilder(
                  child: RegisterCard(_amController),
                  animation: _backAm,
                  builder: (BuildContext context, Widget child) {
                    final Matrix4 transform = new Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateY(_backAm.value);
                    return new Transform(
                      transform: transform,
                      alignment: Alignment.center,
                      child: child,
                    );
                  },
                ),
              )
            ],
          ),
        ));
  }
}

class LoginCard extends StatefulWidget {
  final amController;
  LoginCard(this.amController);

  @override
  _LoginCardState createState() => _LoginCardState();
}

class _LoginCardState extends State<LoginCard> {
  TextEditingController _nameCtrl = TextEditingController();
  TextEditingController _passwordCtrl = TextEditingController();
  bool _btnEnabled = false;
  String _nameErrText;
  String _passwordErrText;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  _checkBtnEnabled() {
    bool temp = _nameCtrl.text != '' && _passwordCtrl.text != '';
    if (_btnEnabled != temp) {
      setState(() {
        _btnEnabled = temp;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        TextField(
          decoration: InputDecoration(labelText: '帐号', errorText: _nameErrText),
          controller: _nameCtrl,
          onChanged: (newVal) {
            if (_nameErrText != null) {
              setState(() {
                _nameErrText = null;
              });
            }
            _checkBtnEnabled();
          },
        ),
        TextField(
          obscureText: true,
          decoration:
              InputDecoration(labelText: '密码', errorText: _passwordErrText),
          controller: _passwordCtrl,
          onChanged: (newVal) {
            if (_passwordErrText != null) {
              setState(() {
                _passwordErrText = null;
              });
            }
            _checkBtnEnabled();
          },
        ),
        SizedBox(height: 30),
        SizedBox(
            width: double.infinity,
            height: 50,
            child: RaisedButton(
              child: Text('登陆',
                  style: TextStyle(fontSize: 16, color: Colors.white)),
              color: Colors.black,
              onPressed: !_btnEnabled
                  ? null
                  : () async {
                      try {
                        User user = new User(
                            name: _nameCtrl.text,
                            password: Common.generateMd5(_passwordCtrl.text));
                        Map result = await user.login();
                        if (result['status'] == true) {
                          setNotification();
                          Navigator.pushReplacementNamed(context, '/home');
                          return;
                        }
                        if (result['errcode'] == 'NO_USER') {
                          setState(() {
                            _nameErrText = result['errmsg'];
                          });
                        } else if (result['errcode'] == 'WRONG_PASSWORD') {
                          setState(() {
                            _passwordErrText = result['errmsg'];
                          });
                        } else {
                          throw new Exception('登陆失败');
                        }
                      } catch (err) {
                        Common.handleError(err, context: context);
                      }
                    },
            )),
        FlatButton(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          child: Text(
            '没有帐号？现在注册',
            style: TextStyle(
              color: Theme.of(context).textTheme.caption.color,
              decoration: TextDecoration.underline,
            ),
          ),
          onPressed: () {
            setState(() {
              if (widget.amController.isCompleted ||
                  widget.amController.velocity > 0)
                widget.amController.reverse();
              else
                widget.amController.forward();
            });
          },
        )
      ],
    );
  }
}

class RegisterCard extends StatefulWidget {
  final amController;
  RegisterCard(this.amController);

  @override
  _RegisterCardState createState() => _RegisterCardState();
}

class _RegisterCardState extends State<RegisterCard> {
  TextEditingController _nameCtrl = TextEditingController();
  TextEditingController _passwordCtrl = TextEditingController();
  TextEditingController _rePasswordCtrl = TextEditingController();
  Duration _durationTime = Duration(seconds: 1);
  Timer _timer;
  String _nameErrText;
  String _rePasswordErrText;
  bool _btnEnabled = false;

  dispose() {
    _nameCtrl.dispose();
    _passwordCtrl.dispose();
    _rePasswordCtrl.dispose();
    _timer?.cancel();
    super.dispose();
  }

  _checkBtnEnabled() {
    bool temp = _nameCtrl.text != '' &&
        _passwordCtrl.text != '' &&
        _rePasswordCtrl.text != '' &&
        _nameErrText == null &&
        _rePasswordErrText == null;
    if (_btnEnabled != temp) {
      setState(() {
        _btnEnabled = temp;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        TextField(
          decoration:
              InputDecoration(labelText: '输入帐号', errorText: _nameErrText),
          controller: _nameCtrl,
          onChanged: (newVal) {
            if (_nameErrText != null) {
              setState(() {
                _nameErrText = null;
              });
            }
            _timer?.cancel();
            _timer = new Timer(_durationTime, () async {
              if (newVal.length == 0) return;
              bool canRegister = await User.canRegister(newVal);
              if (!canRegister) {
                setState(() {
                  _nameErrText = '该帐号已被注册';
                });
              }
              _checkBtnEnabled();
            });
          },
        ),
        TextField(
          obscureText: true,
          decoration: InputDecoration(
            labelText: '输入密码',
          ),
          controller: _passwordCtrl,
          onChanged: (newVal) {
            if (_rePasswordCtrl.text.length > 0) {
              if (newVal != _rePasswordCtrl.text) {
                setState(() {
                  _rePasswordErrText = '密码不一致';
                });
              } else if (_rePasswordErrText != null) {
                setState(() {
                  _rePasswordErrText = null;
                });
              }
            }
            _checkBtnEnabled();
          },
        ),
        TextField(
          obscureText: true,
          decoration: InputDecoration(
              labelText: '再次输入密码', errorText: _rePasswordErrText),
          controller: _rePasswordCtrl,
          onChanged: (newVal) {
            if (newVal != _passwordCtrl.text) {
              setState(() {
                _rePasswordErrText = '密码不一致';
              });
            } else if (_rePasswordErrText != null) {
              setState(() {
                _rePasswordErrText = null;
              });
            }
            _checkBtnEnabled();
          },
        ),
        SizedBox(height: 30),
        SizedBox(
            width: double.infinity,
            height: 50,
            child: RaisedButton(
              child: Text('注册',
                  style: TextStyle(fontSize: 16, color: Colors.white)),
              color: Colors.black,
              onPressed: !_btnEnabled
                  ? null
                  : () async {
                      try {
                        User user = new User(
                            name: _nameCtrl.text,
                            password: Common.generateMd5(_passwordCtrl.text));
                        Map result = await user.register();
                        if (result['status'] == true) {
                          Navigator.pushReplacementNamed(context, '/home');
                          return;
                        } else {
                          String errMsg = result['errmsg'] == null
                              ? '注册失败'
                              : result['errmsg'];
                          throw new Exception(errMsg);
                        }
                      } catch (err) {
                        Common.handleError(err, context: context);
                      }
                    },
            )),
        FlatButton(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          child: Text(
            '已有帐号，现在登陆',
            style: TextStyle(
              color: Theme.of(context).textTheme.caption.color,
              decoration: TextDecoration.underline,
            ),
          ),
          onPressed: () {
            setState(() {
              if (widget.amController.isCompleted ||
                  widget.amController.velocity > 0)
                widget.amController.reverse();
              else
                widget.amController.forward();
            });
          },
        )
      ],
    );
  }
}

// 登陆时设置消息提醒
void setNotification() async {
  List<Task> tasks = await Task.findReminds();
  if(tasks.length <= 0) return;
  tasks.forEach(Common.setTaskRemind);
}
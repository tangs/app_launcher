import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App launcher',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'App launcher'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _loadCfgEnd = false;
  // 当前所有包名
  final String _pkgsKey = 'packages';
  final String _urlsKey = 'urls';
  final String _syncUrlKey = 'syncUrl';
  final String _syncPathKey = 'syncPath';

  String _curPkg = '';
  String _curUrl = '';
  String _syncUrl = '';
  String _syncPath = '';

  // 当前新增包名
  String _curAddPackage = '';
  String _curAddUrl = '';

  List<String> _pkgs;
  List<String> _urls;

  _MyHomePageState() {
    _loadCfg();
  }

  void _loadCfg() async {
    final prefs = await SharedPreferences.getInstance();
    _pkgs = prefs.getStringList(_pkgsKey);
    _urls = prefs.getStringList(_urlsKey);

    _syncUrl = prefs.getString(_syncUrlKey);
    _syncPath = prefs.getString(_syncPathKey);

    if (_pkgs == null) _pkgs = List();
    if (_urls == null) _urls = List();
    // http://92.168.1.240:8080/cfg/1.json
    if (_syncUrl == null) _syncUrl = '192.168.1.240:8080';
    if (_syncPath == null) _syncPath = '/cfg/1.json';

    // await Future.delayed(Duration(seconds: 5));

    setState(() {
      if (_pkgs.length > 0) _curPkg = _pkgs[0];
      if (_urls.length > 0) _curUrl = _urls[0];
      _loadCfgEnd = true;
    });
  }

  void _toast(String txt) {
    Toast.show(
      txt, 
      context, 
      duration: Toast.LENGTH_LONG, 
      gravity:  Toast.BOTTOM
    );
    print(txt);
  }

  void _save(String key, List<String> value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList(key, value);
  }

  void _savePackages() async {
    _save(_pkgsKey, _pkgs);
  }

  void _saveUrls() async {
    _save(_urlsKey, _urls);
  }
  
  void _updateStrValue(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(key, value);
  }

  bool _addValue(List<String> values, String value, bool showMsg) {
    if (value == null || value.length == 0) {
      if (showMsg) _toast('添加内容为空.');
      return false;
    }
    if (values == null) {
      if (showMsg) _toast('数据加载中.');
      return false;
    }
    if (values.indexOf(value) != -1) {
      if (showMsg) _toast('重复的数据');
      return false;
    }
    values.add(value);
    if (showMsg) _toast('数据添加成功');
    return true;
  }

  bool _removeValue(List<String> values, int idx) {
    if (values == null) {
      _toast('数据加载中.');
      return false;
    }
    if (values.length <= idx) {
      _toast('错误的索引:' + idx.toString());
      return false;
    }
    values.removeAt(idx);
    return true;
  }

  bool _addPackage(String pkg, bool showMsg) {
    final ret = _addValue(_pkgs, pkg, showMsg);
    if (ret) {
      if (_pkgs.length == 1) {
        setState(() {
          _curPkg = pkg;
        });
      }
      _savePackages();
    }
    return ret;
  }

  bool _addUrl(url, bool showMsg) {
    final ret = _addValue(_urls, url, showMsg);
    if (ret) {
      if (_urls.length == 1) {
        setState(() {
          _curUrl = url;
        });
      }
      _saveUrls();
    }
    return ret;
  }

  void _showCupertinoPicker(BuildContext cxt, List<String> values,
      String value, Function onSelected, Function onRemove) {
    final widgets = List<Widget>();
    if (values == null || values.length == 0) {
      _toast('没有相应数据.');
      return;
    }
    int idx = 0;
    for (int i = 0; i < values.length; ++i) {
      String text = values[i];
      if (text == value) {
        idx = i;
      }
      widgets.add(
        Row(
          children: <Widget>[
            Expanded(
              child: Center(
                child: Text(text),
              ),
            ),
          ],
        ),
      );
    }

    showModalBottomSheet(context: cxt, builder: (cxt) {
      return Container(
        height: 200,
        child: CupertinoPicker(
          itemExtent: 60,
          onSelectedItemChanged: onSelected, 
          children: widgets,
          scrollController: FixedExtentScrollController(
            initialItem: idx,
          ),
        ),
      );
    });
  }

  void _showCupertinoPickerPackage(BuildContext cxt) {
    _showCupertinoPicker(cxt, _pkgs, _curPkg,
    (idx) {
      setState(() {
        _curPkg = _pkgs[idx];
      });
    },
    (idx) {
      _removeValue(_pkgs, idx);
      _showCupertinoPickerPackage(cxt);
    }
    );
  }

  void _showCupertinoPickerUrl(BuildContext cxt) {
    _showCupertinoPicker(cxt, _urls, _curUrl,
    (idx) {
      setState(() {
        _curUrl = _urls[idx];
      });
    },
    (idx) {
      _removeValue(_urls, idx);
      _showCupertinoPickerUrl(cxt);
    });
  }

  void _launchApp() {
    const platform = const MethodChannel('com.tangs.com/launch');
    try {
      final args = Map();
      args['pkg'] = _curPkg;
      args['url'] = _curUrl;
      platform.invokeMethod('launch', args);
    } on PlatformException catch (e) {
      debugPrint('Failed: ${e.message}.');
    }
  }

  void _showDeleteDialog() {
    showDialog<FlatButton>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('提示'),
          content: Text('确认清除以下数据?'),
          actions: <Widget>[
            FlatButton(
              child: Text('包名'),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _pkgs.clear();
                  _curPkg = '';
                });
              },
            ),
            FlatButton(
              child: Text('地址'),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _urls.clear();
                  _curUrl = '';
                });
              },
            ),
            FlatButton(
              child: Text('取消'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      }
    );
  }

  void _loading() {
    showDialog<FlatButton>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.fromLTRB(32, 64, 32, 64),
          content: CupertinoActivityIndicator(
            radius: 30,
            animating: true,
          ),
        );
      }
    );
    // _sync(Uri.http('192.168.3.95:8080', "/data/info.json"));
  }

  void _sync(String authority, String unencodedPath) async {
    try {
      _updateStrValue(_syncUrlKey, authority);
      _updateStrValue(_syncPathKey, unencodedPath);
      var uri = Uri.http(authority, unencodedPath);
      var httpClient = HttpClient();
      httpClient.connectionTimeout = Duration(seconds: 10);
      var request = await httpClient.getUrl(uri);
      // var request = await httpClient
      var response = await request.close();
      var responseBody = await response.transform(Utf8Decoder()).join();
      Map data = JsonDecoder().convert(responseBody);
      if (data.containsKey('pkg')) {
        for (String pkg in data['pkg']) {
          _addPackage(pkg, false);
        }
      }
      if (data.containsKey('url')) {
        for (String url in data['url']) {
          _addUrl(url, false);
        }
      }
      _toast("同步完成");
    } catch (err) {
      _toast("同步错误: " + err.toString());
    } finally {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    }
  }

  void _showSyncDialog() {
    showDialog<FlatButton>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('同步数据?'),
          contentPadding: EdgeInsets.all(16),
          content: Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  keyboardType: TextInputType.url,
                  controller: TextEditingController(
                    text: _syncUrl,
                  ),
                  decoration: InputDecoration(
                    icon: Icon(Icons.http),
                    labelText: 'authority',
                  ),
                  onChanged: (txt) {
                    _syncUrl = txt;
                  },
                ),
                TextField(
                  keyboardType: TextInputType.url,
                  controller: TextEditingController(
                    text: _syncPath,
                  ),
                  decoration: InputDecoration(
                    icon: Icon(Icons.http),
                    labelText: 'unencodedPath',
                  ),
                  onChanged: (txt) {
                    _syncPath = txt;
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('确定'),
              onPressed: () {
                Navigator.of(context).pop();
                _loading();
                _sync(_syncUrl, _syncPath);
              },
            ),
            FlatButton(
              child: Text('取消'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      }
    );
  }

  Widget _buildNormal(BuildContext context) {
    final style = TextStyle(
      color: Colors.black87,
      fontSize: 20
    );
    final style1 = TextStyle(
      color: Colors.blue,
      fontSize: 20
    );
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
          Text('包名', style: style,),
          FlatButton(
            child: Text(_curPkg, style: style1,),
            onPressed: () {
              _showCupertinoPickerPackage(context);
            },
          ),
          TextField(
            decoration: InputDecoration(
              icon: Icon(Icons.android),
              labelText: '新增包名',
            ),
            controller: TextEditingController(
              text: _curAddPackage
            ),
            onChanged: (txt) {
              _curAddPackage = txt;
            },
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(10, 10, 10, 0)
          ),
          CupertinoButton(
            child: Text('新增包名', style: style,),
            onPressed: () {
              if (_addPackage(_curAddPackage, true)) {
                setState(() {
                  _curAddPackage = '';
                });
              }
            },
            disabledColor: Colors.grey,
            color: Colors.blue,
            pressedOpacity: 0.9,
          ),
          Padding(padding: EdgeInsets.all(10),),
          Text('服务器地址', style: style,),
          FlatButton(
            child: Text(_curUrl, style: style1,),
            onPressed: () {
              _showCupertinoPickerUrl(context);
            },
          ),
          TextField(
            keyboardType: TextInputType.url,
            decoration: InputDecoration(
              icon: Icon(Icons.http),
              labelText: '新增服务器地址',
            ),
            controller: TextEditingController(
              text: _curAddUrl
            ),
            onChanged: (txt) {
              _curAddUrl = txt;
            },
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 0)
          ),
          CupertinoButton(
            child: Text('新增服务器', style: style, ),
            onPressed: () {
              if (_addUrl(_curAddUrl, true)) {
                setState(() {
                  _curAddUrl = '';
                });
              }
            },
            disabledColor: Colors.grey,
            color: Colors.blue,
            pressedOpacity: 0.9,
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 0)
          ),
          CupertinoButton(
            child: Text('Launch APP', style: style,),
            onPressed: _launchApp,
            disabledColor: Colors.grey,
            color: Colors.blue,
            pressedOpacity: 0.9,
          ),
        ],
      ),
    ),
  );
  }

  Widget _buildLoading(BuildContext context, String tips) {
    return Container(
      padding: EdgeInsets.fromLTRB(32, 64, 32, 64),
      child: CupertinoActivityIndicator(
        radius: 30,
        animating: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        // 管理数据
        actions: <Widget>[
          // IconButton(
          //   icon: Icon(Icons.android),
          //   onPressed: () {
          //     _toast('管理功能暂未开放');
          //   },
          // ),
          // IconButton(
          //   icon: Icon(Icons.http),
          //   onPressed: () {
          //     _toast('管理功能暂未开放');
          //   },
          // ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              _showDeleteDialog();
            },
          ),
          IconButton(
            icon: Icon(Icons.sync),
            onPressed: () {
              _showSyncDialog();
            },
          ),
        ],
      ),
      body: Center(
          child: _loadCfgEnd ? _buildNormal(context) : 
            _buildLoading(context, "loading"),
      ),
    );
  }
}

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
  // int _counter = 0;
  // 当前所有包名
  final String _packagesKey = "packages";
  final String _urlsKey = "urls";

  String _curPackage = "";
  String _curUrl = "";

  // 当前新增包名
  String _curAddPackage = "";
  String _curAddUrl = "";

  List<String> _packages;
  List<String> _urls;

  void _loadPackages() async {
    if (_packages != null) return;
    final prefs = await SharedPreferences.getInstance();
    
    setState(() {
      _packages = prefs.getStringList(_packagesKey);
      if (_packages == null) _packages = List();
      if (_packages.length > 0) {
        _curPackage = _packages[0];
      }
    });
  }

   void _loadUrls() async {
    if (_urls != null) return;
    final prefs = await SharedPreferences.getInstance();
    
    setState(() {
      _urls = prefs.getStringList(_urlsKey);
      if (_urls == null) _urls = List();
      if (_urls.length > 0) {
        _curUrl = _urls[0];
      }
    });
  }

  void _toast(String txt) {
    Toast.show(
      txt, 
      context, 
      duration: Toast.LENGTH_LONG, 
      gravity:  Toast.BOTTOM);
  }

  void _save(String key, List<String> value) async {
    if (_packages != null) {
      final prefs = await SharedPreferences.getInstance();
      prefs.setStringList(key, value);
    } 
  }

  void _savePackages() async {
    _save(_packagesKey, _packages);
  }

  void _saveUrls() async {
    _save(_urlsKey, _urls);
  }

  bool _addValue(List<String> values, String value) {
    if (value == null || value.length == 0) {
      _toast("添加内容为空.");
      return false;
    }
    if (values == null) {
      _toast("数据加载中.");
      return false;
    }
    if (values.indexOf(value) != -1) {
      _toast("重复的数据");
      return false;
    }
    values.add(value);
    _toast("数据添加成功");
    return true;
  }

  bool _removeValue(List<String> values, int idx) {
    if (values == null) {
      _toast("数据加载中.");
      return false;
    }
    if (values.length <= idx) {
      _toast("错误的索引:" + idx.toString());
      return false;
    }
    values.removeAt(idx);
    return true;
  }

  bool _addPackage() {
    final ret = _addValue(_packages, _curAddPackage);
    if (ret) {
      if (_packages != null && _packages.length == 1) {
        setState(() {
          _curPackage = _curAddPackage;
        });
      }
      _savePackages();
      setState(() {
        _curAddPackage = "";
      });
    }
    return ret;
  }

  bool _addUrl() {
    final ret = _addValue(_urls, _curAddUrl);
    if (ret) {
      if (_urls != null && _urls.length == 1) {
        setState(() {
          _curUrl = _curAddUrl;
        });
      }
      _saveUrls();
      setState(() {
        _curAddUrl = "";
      });
    }
    return ret;
  }

  void _showCupertinoPicker(BuildContext cxt, List<String> values,
      String value, Function onSelected, Function onRemove) {
    final widgets = List<Widget>();
    if (values == null || values.length == 0) {
      return;
    }
    // for (String value in values) {
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
    _showCupertinoPicker(cxt, _packages, _curPackage,
    (idx) {
      setState(() {
        _curPackage = _packages[idx];
      });
    },
    (idx) {
      _removeValue(_packages, idx);
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
      args["pkg"] = _curPackage;
      args["url"] = _curUrl;
      platform.invokeMethod("launch", args);
    } on PlatformException catch (e) {
      debugPrint("Failed: '${e.message}'.");
    }
  }

  @override
  Widget build(BuildContext context) {
    _loadPackages();
    _loadUrls();
    final style = TextStyle(
      color: Colors.black87,
      fontSize: 20
    );
    final style1 = TextStyle(
      color: Colors.blue,
      fontSize: 20
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        // 管理数据
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.android),
            onPressed: () {
              _toast("管理功能暂未开放");
            },
          ),
          IconButton(
            icon: Icon(Icons.http),
            onPressed: () {
              _toast("管理功能暂未开放");
            },
          ),
        ],
      ),
      body: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                Text("包名", style: style,),
                FlatButton(
                  child: Text(_curPackage, style: style1,),
                  onPressed: () {
                    _showCupertinoPickerPackage(context);
                  },
                ),
                TextField(
                  decoration: InputDecoration(
                    icon: Icon(Icons.android),
                    labelText: "新增包名",
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
                  child: Text("新增包名", style: style,),
                  onPressed: _addPackage,
                  disabledColor: Colors.grey,
                  color: Colors.blue,
                  pressedOpacity: 0.9,
                ),
                Padding(padding: EdgeInsets.all(10),),
                Text("服务器地址", style: style,),
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
                    labelText: "新增服务器地址",
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
                  child: Text("新增服务器", style: style, ),
                  onPressed: _addUrl,
                  disabledColor: Colors.grey,
                  color: Colors.blue,
                  pressedOpacity: 0.9,
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 0)
                ),
                CupertinoButton(
                  child: Text("Launch APP", style: style,),
                  onPressed: _launchApp,
                  disabledColor: Colors.grey,
                  color: Colors.blue,
                  pressedOpacity: 0.9,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:shared_preferences/shared_preferences.dart';

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
      // TODO 包名为空
      return false;
    }
    if (values == null) {
      // TODO
      return false;
    }
    if (values.indexOf(value) != -1) {
      // TODO 重复的包名
      return false;
    }
    values.add(value);
    return true;
  }

  bool _addPackage() {
    return _addValue(_packages, _curAddPackage);
  }

  bool _addUrl() {
    return _addValue(_urls, _curAddUrl);
  }

  void _showCupertinoPicker(BuildContext cxt, List<String> values, Function onSelected) {
    final widgets = List<Widget>();
    if (values == null || values.length == 0) {
      // TODO 没有包名
      return;
    }
    for (String value in values) {
      // widgets.add(Text(value));
      widgets.add(Center(
        child: Text(value),
      ));
    }

    showCupertinoModalPopup(context: cxt, builder: (cxt){
      return Container(
        height: 200,
        child: CupertinoPicker(itemExtent: 60,
          onSelectedItemChanged: onSelected, 
          children: widgets
        ),
      );
    });
  }

  void _showCupertinoPickerPackage(BuildContext cxt) {
    _showCupertinoPicker(cxt, _packages, (idx) {
      setState(() {
        _curPackage = _packages[idx];
      });
    });
  }

  void _showCupertinoPickerUrl(BuildContext cxt) {
    _showCupertinoPicker(cxt, _urls, (idx) {
      setState(() {
        _curUrl = _urls[idx];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    _loadPackages();
    _loadUrls();
    final style = TextStyle(
      color: Colors.black,
      fontSize: 24
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 0)
            ),
            Text(
              "包名",
              style: style,
            ),
            FlatButton(
              child: Text(
                _curPackage,
                style: style,
              ),
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
              padding: EdgeInsets.fromLTRB(16, 16, 16, 0)
            ),
            CupertinoButton(
              child: Text(
                "新增包名",
                style: style,
              ),
              onPressed: () {
                if (_addPackage()) {
                  _savePackages();
                  setState(() {
                    _curAddPackage = "";
                  });
                }
              },
              disabledColor: Colors.grey,
              color: Colors.blue,
              pressedOpacity: 0.9,
            ),
            Padding(padding: EdgeInsets.all(32),),
            Text(
              "服务器地址",
              style: style,
            ),
            FlatButton(
              child: Text(
                _curUrl,
                style: style,
              ),
              onPressed: () {
                _showCupertinoPickerUrl(context);
              },
            ),
            TextField(
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
              child: Text(
                "新增服务器",
                style: style,
              ),
              onPressed: () {
                if (_addUrl()) {
                  _saveUrls();
                  setState(() {
                    _curAddUrl = "";
                  });
                }
              },
              disabledColor: Colors.grey,
              color: Colors.blue,
              pressedOpacity: 0.9,
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

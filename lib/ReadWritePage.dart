import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_ble_lib/flutter_ble_lib.dart';


class ReadWritePage extends StatefulWidget {
  Characteristic charID;

  ReadWritePage(this.charID);

  @override
  _ReadWritePageState createState() => _ReadWritePageState();
}

class _ReadWritePageState extends State<ReadWritePage> {
  TextEditingController _controller;
  List<Widget> children;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    children = <Widget>[
      Row(
        children: <Widget>[TextField(controller: _controller,),RaisedButton(onPressed: (){
          widget.charID.write(Uint8List.fromList(_controller.text.codeUnits), true);
        },child: Text('Write'),)],
      ),
    ];
    startReading();
  }

  startReading(){
    widget.charID.monitor().listen((data){
      setState(() {
        children.add(Text(String.fromCharCodes(data)));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Read Write'),),
      body: ListView(
        children: children,
      ),
    );
  }
}

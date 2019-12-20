import 'package:flutter/material.dart';
import 'package:flutter_ble_lib/flutter_ble_lib.dart';

class DevicePage extends StatefulWidget {
  Map<Service,List<Characteristic>> serveAndChars;

  DevicePage(this.serveAndChars);

  @override
  _DevicePageState createState() => _DevicePageState();
}

class _DevicePageState extends State<DevicePage> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Device'),
      ),
      body: ListView.builder(itemBuilder: (context,index){
        return ExpansionTile(title: Text('Service UUID'),subtitle: Text(widget.serveAndChars.keys.toList()[index].uuid),
        trailing: Icon(Icons.keyboard_arrow_down),
        children: widget.serveAndChars.values.toList()[index].map((char){
          return ListTile(title: Text('Characteristic UUID'),subtitle: Text(char.uuid),);
        }).toList(),);
      },itemCount: widget.serveAndChars.length,),
    );
  }
}

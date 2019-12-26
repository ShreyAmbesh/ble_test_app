import 'dart:typed_data';

import 'package:ble_test_app/DevicePage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ble_lib/flutter_ble_lib.dart';

void main() {
  runApp(Main());
}

class Main extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyApp(),
    );
  }
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  BleManager bleManager;
  Map<String, ScanResult> scanResults;
  bool scanning;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    scanning = false;
    bleManager = BleManager();
    bleManager.createClient();
    observeBluetoothState();
    scanResults = Map();
  }

  observeBluetoothState() async {
    BluetoothState currentState = await bleManager.bluetoothState();
    bleManager.observeBluetoothState().listen((btState) {
      print(btState);
      //do your BT logic, open different screen, etc.
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    bleManager.destroyClient();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('BLE Test'),
        centerTitle: true,
      ),
      body: ListView.builder(
          itemCount: scanResults.length,
          itemBuilder: (context, index) {
            Peripheral device = scanResults.values.toList()[index].peripheral;
            return ListTile(
              title: Text(device.name ?? 'unknown'),
              subtitle: Text(device.identifier),
              trailing: IconButton(
                  icon: Icon(Icons.bluetooth),
                  onPressed: () async {
                    if (!await device.isConnected()) {
                      await device.connect().catchError((err) {
                        print(err.toString());
                      }).then((val) {
                        print('something');
                      });
                      await device.discoverAllServicesAndCharacteristics();
                      List<Service> services = await device.services();
                      Map<Service, List<Characteristic>> servAndChars = Map();
                      services.forEach((service) async {
                        List<Characteristic> chars =
                            (await service.characteristics());
                        chars.forEach((characterstic) async {
                          print('Service UUID ${service.uuid}');
                          print('Characterstic UUID ${characterstic.uuid}');
                          print('Redable - ${characterstic.isReadable}');
                          print('Indicatable - ${characterstic.isIndicatable}');
                          print('Notifiable - ${characterstic.isNotifiable}');
                          print(
                              'Writable Without Response - ${characterstic.isWritableWithoutResponse}');
                          print(
                              'Writable With Response - ${characterstic.isWritableWithResponse}');

                        });
                        servAndChars[service] = chars;
                      });
                      Navigator.of(context)
                          .push(CupertinoPageRoute(builder: (context) {
                        return DevicePage(servAndChars);
                      }));
                    } else {
                      device.disconnectOrCancelConnection();
                    }
                  }),
            );
          }),
      floatingActionButton: FloatingActionButton(
        backgroundColor: scanning ? Colors.red : Colors.blue,
        child: Icon(scanning ? Icons.stop : Icons.search),
        onPressed: () async {
          if (scanning) {
            bleManager.stopPeripheralScan();
            setState(() {
              scanning = false;
            });
          } else {
            setState(() {
              scanning = true;
              scanResults.clear();
            });
            bleManager.startPeripheralScan().listen((scanResult) {
              //Scan one peripheral and stop scanning
              print(
                  "Scanned Peripheral ${scanResult.peripheral.name}, RSSI ${scanResult.rssi}");
              if (scanResult.isConnectable ?? true)
                setState(() {
                  scanResults[scanResult.peripheral.identifier] = scanResult;
                });
              //bleManager.stopPeripheralScan();
            });
          }
        },
      ),
    );
  }

  double _convertToTemperature(Uint8List rawTemperatureBytes) {
    if (rawTemperatureBytes.length < 4) return 0.0;
    const double SCALE_LSB = 0.03125;
    int rawTemp = rawTemperatureBytes[3] << 8 | rawTemperatureBytes[2];
    return ((rawTemp) >> 2) * SCALE_LSB;
  }
}

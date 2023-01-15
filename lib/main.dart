import 'package:remote_switch/find_bluetooth_devices.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var status = await Permission.bluetooth.status;
  if (!status.isGranted) {
    await Permission.bluetooth.request();
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home: const MyHomePage(title: '我就懶得去關燈'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;

  const MyHomePage({Key? key, required this.title}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  BluetoothDevice? _device;

  FlutterBluePlus? flutterBlue;
  @override
  void initState() {
    super.initState();
    flutterBlue = FlutterBluePlus.instance;
    // Timer.periodic(const Duration(seconds: 15), (timer) async {
    //   if (_device != null) {
    //     await _device?.connect();
    //   }
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () async {
            // open drawer
            _device = await Navigator.push(context, MaterialPageRoute(builder: (context) => const DiscoveryPage()));
            if (_device != null) {
              _device?.state.listen((event) {
                switch (event) {
                  case BluetoothDeviceState.connected:
                    break;
                  case BluetoothDeviceState.connecting:
                    break;
                  case BluetoothDeviceState.disconnected:
                    _device?.connect();
                    break;
                  case BluetoothDeviceState.disconnecting:
                    break;
                }
              });
            }
          },
          icon: const Icon(Icons.bluetooth),
          tooltip: 'bluetooth',
        ),
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(50.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE57373),
                  foregroundColor: const Color.fromARGB(255, 255, 255, 255),
                  shape: const BeveledRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                  ),
                ),
                onPressed: () {
                  // _sendMessage('n');
                  flutterBlue?.connectedDevices.then((value) async {
                    if (value.isNotEmpty) {
                      _device = value.first;
                      List<BluetoothService>? services = await _device?.discoverServices();
                      services?.forEach((element) {
                        for (var element in element.characteristics) {
                          element.write([0x6e]);
                        }
                      });
                      // _sendMessage('n');
                    } else {}
                  });
                },
                child: const Text('開燈', style: TextStyle(fontSize: 100)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(50.0),
              child: ElevatedButton(
                onPressed: () {
                  // This code is used to connect to the device and send a message to it.

                  // _sendMessage('n');
                  flutterBlue?.connectedDevices.then((value) async {
                    if (value.isNotEmpty) {
                      _device = value.first;
                      List<BluetoothService>? services = await _device?.discoverServices();
                      services?.forEach((element) {
                        for (var element in element.characteristics) {
                          element.write([0x66]);
                        }
                      });
                      // _sendMessage('n');
                    } else {}
                  });
                },
                child: const Text('關燈', style: TextStyle(fontSize: 100)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

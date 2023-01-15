import 'dart:async';

import 'package:remote_switch/bluetooth_device_list_entry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class DiscoveryPage extends StatefulWidget {
  /// If true, discovery starts on page start, otherwise user must press action button.
  final bool start;

  const DiscoveryPage({Key? key, this.start = true}) : super(key: key);

  @override
  State<DiscoveryPage> createState() => _DiscoveryPage();
}

class _DiscoveryPage extends State<DiscoveryPage> {
  List<ScanResult> results = [];
  StreamSubscription? _streamSubscription;
  bool isDiscovering = false;
  late FlutterBluePlus flutterBlue;

  @override
  void initState() {
    super.initState();
    flutterBlue = FlutterBluePlus.instance;
    _startDiscovery();
  }

  void _restartDiscovery() {
    setState(() {
      results.clear();
      isDiscovering = true;
    });

    _startDiscovery();
  }

  void _startDiscovery() {
    // Start scanning
    flutterBlue.startScan(timeout: const Duration(seconds: 4));

    // Listen to scan results
    _streamSubscription = flutterBlue.scanResults.listen((resultsTemp) {
      // do something with scan results
      setState(() {
        for (var r in resultsTemp) {
          if (r.device.name == '') continue;
          final existingIndex = results.indexWhere((element) => element.device.id == r.device.id);
          if (existingIndex >= 0) {
            results[existingIndex] = r;
          } else {
            results.add(r);
          }
        }
      });
    });

    _streamSubscription!.onDone(() {
      setState(() {
        isDiscovering = false;
      });
      // Stop scanning
    });
    flutterBlue.stopScan();
  }

  // @TODO . One day there should be `_pairDevice` on long tap on something... ;)

  @override
  void dispose() {
    super.dispose();
    // Avoid memory leak (`setState` after dispose) and cancel discovery
    _streamSubscription?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: isDiscovering ? const Text('Discovering devices') : const Text('Discovered devices'),
        actions: <Widget>[
          isDiscovering
              ? FittedBox(
                  child: Container(
                    margin: const EdgeInsets.all(16.0),
                    child: const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.replay),
                  onPressed: _restartDiscovery,
                )
        ],
      ),
      body: ListView.builder(
        itemCount: results.length,
        itemBuilder: (BuildContext context, index) {
          ScanResult result = results[index];
          final device = result.device;
          return BluetoothDeviceListEntry(
            device: device,
            rssi: result.rssi,
            onTap: () {
              Navigator.of(context).pop(result.device);
            },
          );
        },
      ),
    );
  }
}

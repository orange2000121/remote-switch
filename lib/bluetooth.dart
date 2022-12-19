import 'package:flutter/material.dart';

class MyBluetooth extends StatefulWidget {
  const MyBluetooth({Key? key}) : super(key: key);

  @override
  State<MyBluetooth> createState() => _MyBluetoothState();
}

class _MyBluetoothState extends State<MyBluetooth> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('藍芽'),
      ),
      body: const Center(
        child: Text('藍芽'),
      ),
    );
  }
}

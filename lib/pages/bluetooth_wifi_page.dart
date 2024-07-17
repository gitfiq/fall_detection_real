// ignore_for_file: avoid_print

import 'dart:async';
import 'package:fall_detection_real/pages/wifi_credential_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class BluetoothWifiPage extends StatefulWidget {
  const BluetoothWifiPage({super.key});

  @override
  State<BluetoothWifiPage> createState() => _BluetoothWifiPageState();
}

class _BluetoothWifiPageState extends State<BluetoothWifiPage>
    with WidgetsBindingObserver {
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;
  BluetoothDevice? connectedDevice;
  BluetoothConnection? connection;

  late StreamSubscription<BluetoothState> _stateSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _getBTState();
    _stateChangeListener();
    _checkConnectedDevice();
    _stateSubscription =
        FlutterBluetoothSerial.instance.onStateChanged().listen((state) {
      setState(() {
        _bluetoothState = state;
      });
      _checkConnectedDevice(); // Check connected device on state change
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stateSubscription.cancel();
    _disconnectFromDevice(); // Ensure disconnection when disposing
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // Reload or refresh the page when app returns to foreground
      _getBTState();
      _checkConnectedDevice();
    }
  }

  void _disconnectFromDevice() {
    if (connection != null) {
      connection!.dispose();
      connection = null;
      setState(() {
        connectedDevice = null;
      });
      print('Disconnected from ${connectedDevice!.name}');
    }
  }

  void _getBTState() {
    FlutterBluetoothSerial.instance.state.then((state) {
      setState(() {
        _bluetoothState = state;
      });
    });
  }

  void _stateChangeListener() {
    FlutterBluetoothSerial.instance
        .onStateChanged()
        .listen((BluetoothState state) {
      print("Bluetooth state changed: $state");
      setState(() {
        _bluetoothState = state;
      });
      _checkConnectedDevice(); // Check connected device on state change
    });
  }

  void _checkConnectedDevice() async {
    // Get the list of bonded devices
    List<BluetoothDevice> bondedDevices =
        await FlutterBluetoothSerial.instance.getBondedDevices();

    // Define the specific name of the device you are looking for
    const String specificDeviceName = "ESP32_Fall_Detection";

    // Iterate through the list to find the device with the specific name
    for (BluetoothDevice device in bondedDevices) {
      if (device.name == specificDeviceName) {
        setState(() {
          connectedDevice = device;
        });
        return;
      }
    }

    // If no device with the specific name is found, set connectedDevice to null
    setState(() {
      connectedDevice = null;
    });

    print('No device found with the name $specificDeviceName');
  }

  void _connectToDevice(BluetoothDevice device) async {
    try {
      connection = await BluetoothConnection.toAddress(device.address);
      setState(() {
        connectedDevice = device;
      });
      // Handle connection success
      print('Connected to ${device.name}');
      Navigator.push(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(
          builder: (context) => WifiCredentialPage(
            connection: connection!,
          ),
        ),
      );
    } catch (e) {
      // Handle connection failure
      print('Failed to connect to ${device.name}: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Bluetooth Settings'),
        backgroundColor: Colors.white,
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  SwitchListTile(
                    title: const Text(
                      "Bluetooth Status",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    value: _bluetoothState.isEnabled,
                    onChanged: (bool value) async {
                      if (value) {
                        await FlutterBluetoothSerial.instance.requestEnable();
                      } else {
                        await FlutterBluetoothSerial.instance.requestDisable();
                      }
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 20),
                  ListTile(
                    title: const Text(
                      "Bluetooth Status",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    subtitle: Text(
                      _bluetoothState.toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    trailing: ElevatedButton(
                      child: const Text(
                        "Settings",
                        style: TextStyle(color: Colors.black),
                      ),
                      onPressed: () {
                        FlutterBluetoothSerial.instance.openSettings();
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              title: const Text(
                "Connected Device",
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              onTap: () {},
            ),
            connectedDevice != null
                ? ListTile(
                    title: Text(connectedDevice!.name!),
                    onTap: () {
                      _connectToDevice(connectedDevice!);
                    },
                  )
                : ListTile(
                    title: const Text("No Connected Device"),
                    onTap: () {},
                  ),
          ],
        ),
      ),
    );
  }
}

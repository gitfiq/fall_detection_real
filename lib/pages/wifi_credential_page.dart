import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class WifiCredentialPage extends StatefulWidget {
  final BluetoothConnection connection;

  const WifiCredentialPage({super.key, required this.connection});

  @override
  State<WifiCredentialPage> createState() => _WifiCredentialPageState();
}

class _WifiCredentialPageState extends State<WifiCredentialPage> {
  final TextEditingController _ssidController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  StreamSubscription<Uint8List>? _connectionSubscription;

  @override
  void initState() {
    super.initState();
    _listenForConnectionChanges();
  }

  @override
  void dispose() {
    _ssidController.dispose();
    _passwordController.dispose();
    widget.connection.dispose();
    _connectionSubscription?.cancel();
    widget.connection.close();
    super.dispose();
  }

  void _listenForConnectionChanges() {
    _connectionSubscription = widget.connection.input?.listen((data) {
      // Handle incoming data if needed
    }, onDone: () {
      // Connection lost
      if (!widget.connection.isConnected) {
        Navigator.pop(context);
      }
    });
  }

  void _sendWifiCredentials() async {
    final ssid = _ssidController.text;
    final password = _passwordController.text;

    // Format the data to be sent. Assuming ESP32 expects "SSID:your_ssid;PASS:your_password;"
    final data = 'SSID:$ssid;PASS:$password;\n';

    try {
      widget.connection.output.add(Uint8List.fromList(data.codeUnits));
      await widget.connection.output.allSent;
      print('Sent SSID: $ssid, Password: $password ');
    } catch (e) {
      print('Error sending data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.15,
              ),
              Center(
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.55,
                  width: MediaQuery.of(context).size.width * 0.85,
                  margin: const EdgeInsets.symmetric(horizontal: 8.0),
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        "Enter device Wifi SSID and Password",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.02,
                      ),
                      const SizedBox(height: 35),
                      TextField(
                        controller: _ssidController,
                        decoration: const InputDecoration(
                          labelText: 'SSID',
                          labelStyle: TextStyle(color: Colors.white),
                          border: OutlineInputBorder(),
                        ),
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 30),
                      TextField(
                        controller: _passwordController,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          labelStyle: TextStyle(color: Colors.white),
                          border: OutlineInputBorder(),
                        ),
                        style: const TextStyle(color: Colors.white),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.05,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: _sendWifiCredentials,
                        label: const Text("Send"),
                        icon: const Icon(Icons.save_alt_rounded),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.black,
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.10,
            left:
                MediaQuery.of(context).size.width / 3.5, // Centering the button
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.grey[800],
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              icon: const Icon(Icons.arrow_back),
              label: const Text(
                "Back to Menu",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:fall_detection_real/services/firestore_operations.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/user_id.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  bool _isFocused = false;

  final _textController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  late final AnimationController _controller = AnimationController(
    duration: const Duration(milliseconds: 100),
    vsync: this,
  );

  // Animation for border radius
  late final Animation<double> _borderRadiusAnimation =
      Tween<double>(begin: 20.0, end: 5.0) // Adjust radius as needed
          .animate(_controller);

  @override
  void dispose() {
    _controller.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        resizeToAvoidBottomInset:
            false, // Prevent resizing when keyboard appears
        body: Container(
          width: MediaQuery.of(context).size.width, // Set width to screen width
          height:
              MediaQuery.of(context).size.height, // Set height to screen height
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/Login.jpg"),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 20.0),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.30,
                        width: MediaQuery.of(context).size.width * 0.80,
                        child: Image.asset('assets/images/Logo.jpg'),
                      ),
                      const SizedBox(height: 30.0),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: MediaQuery.of(context).size.width * 0.80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(
                              Radius.circular(_borderRadiusAnimation.value)),
                          border: Border.all(
                            color: _isFocused ? Colors.blueAccent : Colors.grey,
                            width: 2.5,
                          ),
                        ),
                        child: InkWell(
                          onTap: () {},
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: TextFormField(
                              controller: _textController,
                              decoration: InputDecoration(
                                hintText: _isFocused ? '' : 'Enter Device ID',
                                border: InputBorder.none,
                              ),
                              style: const TextStyle(color: Colors.black),
                              enabled: true,
                              cursorColor: Colors.black,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a device ID';
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.80,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              String deviceId = _textController.text;
                              // Create an instance of UserInput and pass the device ID
                              // ignore: unused_local_variable
                              UserId userInput = UserId(deviceId);
                              try {
                                // Retrieve the document from Firestore
                                DocumentSnapshot documentSnapshot =
                                    await FirebaseFirestore.instance
                                        .collection("users")
                                        .doc(
                                            deviceId) // Use the deviceId as the document ID
                                        .get();

                                // Check if the document exists
                                if (documentSnapshot.exists) {
                                  //initialize the notification
                                  await FirestoreOperations()
                                      .initNotifications(deviceId);
                                  // ignore: use_build_context_synchronously
                                  Navigator.pushNamed(context, '/homepage',
                                      arguments: userInput);
                                } else {
                                  showDialog(
                                    // ignore: use_build_context_synchronously
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        backgroundColor: Colors.grey[800],
                                        title: const Text(
                                          "Device ID Not Found",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        content: Text(
                                          "The device ID '$deviceId' does not exist.",
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 15,
                                          ),
                                        ),
                                        actions: <Widget>[
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text(
                                              "OK",
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                }
                              } catch (e) {
                                // Handle any errors
                                // ignore: avoid_print
                                print("Error retrieving document: $e");
                              }
                            } else {
                              // Form is not valid, show snackbar to enter a device ID
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Please enter a device ID."),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[800],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text(
                            "Start Monitoring",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Check keyboard visibility on initial build
    _isFocused = MediaQuery.of(context).viewInsets.bottom > 0;
    if (_isFocused) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }
}

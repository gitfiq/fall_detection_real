import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fall_detection_real/components/loading.dart';
import 'package:fall_detection_real/data/user_id.dart';
import 'package:fall_detection_real/pages/fall_history_page.dart';
import 'package:fall_detection_real/pages/location_page.dart';
import 'package:fall_detection_real/pages/statistic_page.dart';
import 'package:fall_detection_real/services/firestore_operations.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

//This page mainly serves to show to the user the current status of the device's wearer. (OK, Fall Detected and Emergency)
class CurrentStatusPage extends StatefulWidget {
  final String deviceId;

  const CurrentStatusPage({super.key, required this.deviceId});

  @override
  State<CurrentStatusPage> createState() => _CurrentStatusPageState();
}

class _CurrentStatusPageState extends State<CurrentStatusPage> {
  final FirestoreOperations _firestoreService = FirestoreOperations();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: _firestoreService.getUserStream(widget.deviceId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Loading(),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text("Error: ${snapshot.error}"),
              );
            } else {
              final data = snapshot.data?.data(); // Extract document data
              if (data != null) {
                // Extract fields from the document data
                var fallStatus = data['fall_status'];
                var time = (data['time'] as Timestamp).toDate();
                var formattedTime =
                    DateFormat('HH:mm, dd/MM/yyyy').format(time);
                var latitude = data['latitude'];
                var longitude = data['longitude'];
                var emergencyStatus = data['emergency'];

                // Determine the image, status, and background color based on emergency and fall status
                String image;
                Color color;
                String status;

                if (emergencyStatus) {
                  image = 'assets/images/Help.jpg';
                  color = Colors.red;
                  status = "Needs Help/ Assistance";
                } else {
                  if (fallStatus) {
                    image = 'assets/images/Fall.jpg';
                    color = Colors.red;
                    status = "Fall Detected";
                  } else {
                    image = 'assets/images/Standing.jpg';
                    color = Colors.green;
                    status = "Ok";
                  }
                }

                // Display the extracted fields in the UI
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          color: color,
                          borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(40),
                              bottomRight: Radius.circular(40))),
                      child: Column(
                        children: [
                          const SizedBox(height: 50.0),
                          const Center(
                              child: Text("Status",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 30))),
                          const SizedBox(height: 20.0),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.20,
                            width: MediaQuery.of(context).size.width * 0.80,
                            child: Image.asset(image),
                          ),
                          const SizedBox(height: 30.0),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30.0),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 20, horizontal: 40),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Detection: $status",
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 20,
                              )),
                          const SizedBox(height: 30.0),
                          Text("Time: $formattedTime",
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 20,
                              )),
                          const SizedBox(height: 30.0),
                          Text.rich(
                            TextSpan(
                              children: [
                                const TextSpan(
                                  text: "Location: ",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 20,
                                  ),
                                ),
                                TextSpan(
                                  text:
                                      "$latitude, $longitude", // Assuming latitude & longitude are valid doubles
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 20,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => LocationPage(
                                                deviceId: widget.deviceId)),
                                      );
                                    },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                );
              } else {
                return const Center(
                    child: Column(
                  children: [
                    Text(
                      "No Data Available",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                    ),
                    Text(
                      "Check Internet Connection",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                    ),
                  ],
                ));
              }
            }
          }),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.grey[600],
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white,
        iconSize: 30,
        selectedFontSize: 14, // Set the font size of the selected item label
        unselectedFontSize:
            14, // Set the font size of the unselected item labels
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.analytics_outlined), label: "Statistics"),
          BottomNavigationBarItem(
              icon: Icon(Icons.history), label: "Fall History"),
        ],
        currentIndex: 0,
        onTap: (index) {
          // Handle navigation when a bottom navigation item is tapped
          switch (index) {
            case 0:
              // Navigate to the home page
              Navigator.pushReplacementNamed(context, '/homepage',
                  arguments: UserId(widget.deviceId));
              break;
            case 1:
              // Navigate to the Statistic page
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        StatisticPage(deviceId: widget.deviceId)),
              );
              break;
            case 2:
              // Navigate to the Fall History page
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        FallHistoryPage(deviceId: widget.deviceId)),
              );
              break;
          }
        },
      ),
    );
  }
}

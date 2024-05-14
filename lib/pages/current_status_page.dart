import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fall_detection_real/components/loading.dart';
import 'package:fall_detection_real/data/user_id.dart';
import 'package:fall_detection_real/pages/fall_history_page.dart';
import 'package:fall_detection_real/pages/statistic_page.dart';
import 'package:fall_detection_real/services/firestore_operations.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
          stream: _firestoreService.getCurrentStatusStream(widget.deviceId),
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
                var formattedTime = DateFormat('dd/MM/yyyy HH:mm').format(time);
                var location = data['location'];

                //Pick the image based on the fall status
                String image = fallStatus
                    ? 'assets/images/Fall.jpg'
                    : 'assets/images/Standing.jpg';

                //Pick the color based on the fall status
                Color color = fallStatus ? Colors.red : Colors.green;

                //Pick the color based on the fall status
                String status = fallStatus ? "Fall Detected" : "Ok";

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
                          Text("Location: $location",
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 20,
                              )),
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

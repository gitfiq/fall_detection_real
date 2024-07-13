// ignore_for_file: avoid_unnecessary_containers
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fall_detection_real/components/loading.dart';
import 'package:fall_detection_real/data/user_id.dart';
import 'package:fall_detection_real/pages/current_status_page.dart';
import 'package:fall_detection_real/pages/statistic_page.dart';
import 'package:fall_detection_real/services/firestore_operations.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

//All past falls are recored in this page (Fall History). In the case of false positive. The user is able to delete the fall record.
class FallHistoryPage extends StatefulWidget {
  final String deviceId;

  const FallHistoryPage({super.key, required this.deviceId});

  @override
  State<FallHistoryPage> createState() => _FallHistoryPageState();
}

class _FallHistoryPageState extends State<FallHistoryPage> {
  final FirestoreOperations _firestoreService = FirestoreOperations();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const SizedBox(height: 50),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.1, // Top quarter
            child: const Center(
              child: Text(
                'Fall History',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    _firestoreService.getFallDocumentsStream(widget.deviceId),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text("Error: ${snapshot.error}"),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Loading(),
                    );
                  }

                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var data = snapshot.data!.docs[index];
                      var time = (data['time'] as Timestamp).toDate();
                      var formattedTime =
                          DateFormat('HH:mm, dd/MM/yyyy').format(time);
                      var latitude = data['latitude'];
                      var longitude = data['longitude'];
                      return Dismissible(
                        key: Key(data.id), // Unique key for each item
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20.0),
                          color: Colors.red,
                          child: const Icon(
                            Icons.delete,
                            color: Colors.white,
                          ),
                        ),
                        confirmDismiss: (direction) async {
                          // Show a confirmation dialog when the item is swiped
                          return await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text("Confirm"),
                                  content: const Text(
                                      "Are you sure you want to delete this item?"),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(false),
                                      child: const Text("CANCEL"),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(true),
                                      child: const Text("DELETE"),
                                    )
                                  ],
                                );
                              });
                        },
                        onDismissed: (direction) {
                          _firestoreService
                              .deleteFallDocument(widget.deviceId, data.id)
                              .then((_) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Item deleted")),
                            );
                          }).catchError((error) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("Failed to delete item")),
                            );
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 16),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                color: const Color.fromARGB(249, 236, 167, 47),
                                borderRadius: BorderRadius.circular(20)),
                            child: ListTile(
                              title: Text(
                                'Time: $formattedTime',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18,
                                ),
                              ),
                              subtitle: Text(
                                'Location: $latitude, $longitude',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  color: Colors.white70,
                                  child: const Icon(
                                    Icons.warning_outlined,
                                    size: 30,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
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
              icon: Icon(Icons.search_outlined), label: "Current Status"),
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
              // Navigate to the Current Status page
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        CurrentStatusPage(deviceId: widget.deviceId)),
              );
              break;
          }
        },
      ),
    );
  }
}

/*
Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 16),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              color: const Color.fromARGB(249, 236, 167, 47),
                              borderRadius: BorderRadius.circular(20)),
                          child: ListTile(
                            title: Text(
                              'Time: $formattedTime',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                              ),
                            ),
                            subtitle: Text(
                              'Location: $location',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                color: Colors.white70,
                                child: const Icon(
                                  Icons.warning_outlined,
                                  size: 30,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );*/

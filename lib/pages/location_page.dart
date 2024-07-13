import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fall_detection_real/services/firestore_operations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

//The page where the device's wearer is able too view the current location of the user.
//The Red marker shown is the device's wearer current location.
//The Blue marker is the location where the device detects a fall (From the fall history)
class LocationPage extends StatefulWidget {
  final String deviceId;

  const LocationPage({super.key, required this.deviceId});

  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  List<Map<String, dynamic>> pastLocations = [];
  LatLng? currentLocation;
  MapController? mapController;
  Timer? timer;
  bool? gpsStatus;

  final FirestoreOperations firestoreOperations = FirestoreOperations();

  @override
  void initState() {
    super.initState();
    mapController = MapController();
    fetchLocations();
    timer = Timer.periodic(const Duration(minutes: 1),
        (Timer t) => fetchLocations()); // Fetch locations every 1 minutes
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> fetchLocations() async {
    // Fetch current location and GPS Status
    StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
        currentLocationSubscription;
    currentLocationSubscription = firestoreOperations
        .getUserStream(widget.deviceId)
        .listen((DocumentSnapshot<Map<String, dynamic>> snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data()!;
        double? currentLat = data['latitude'];
        double? currentLng = data['longitude'];
        gpsStatus = data['gps_status'];
        if (currentLat != null && currentLng != null) {
          if (currentLat == 0.0 && currentLng == 0.0) {
            setState(() {
              currentLocation =
                  null; // Set current location to null to display the text
            });
          } else {
            setState(() {
              currentLocation = LatLng(currentLat, currentLng);
            });
            mapController?.move(currentLocation!, 17.0);
          }
        }
      }
      currentLocationSubscription
          ?.cancel(); // Cancel subscription after data is fetched
    });

    // Fetch past locations from 'fallid' collection
    StreamSubscription<QuerySnapshot<Object?>>? pastLocationsSubscription;
    pastLocationsSubscription = firestoreOperations
        .getFallDocumentsStream(widget.deviceId)
        .listen((QuerySnapshot<Object?> querySnapshot) {
      List<Map<String, dynamic>> newPastLocations = [];
      for (var doc in querySnapshot.docs) {
        var document = doc as QueryDocumentSnapshot<Map<String, dynamic>>;
        double? pastLat = document.data()['latitude'];
        double? pastLng = document.data()['longitude'];
        Timestamp? time = document.data()['time'];
        if (pastLat != null && pastLng != null && time != null) {
          newPastLocations.add({
            'location': LatLng(pastLat, pastLng),
            'time': time.toDate(),
          });
        }
      }
      setState(() {
        pastLocations = newPastLocations;
      });
      pastLocationsSubscription
          ?.cancel(); // Cancel subscription after data is fetched
    });
  }

  String formatDateTime(DateTime datetime) {
    final DateFormat timeFormat = DateFormat('HH:mm');
    final DateFormat dateFormat = DateFormat("dd/MM/yyyy");
    return 'Time: ${timeFormat.format(datetime)} \nDate: ${dateFormat.format(datetime)}';
  }

  Widget _noGpsSignalWidget() {
    return Container(
      color: Colors.white,
      child: Center(
        child: AlertDialog(
          backgroundColor: Colors.grey[500],
          title: const Text(
            'GPS Signal Not Found',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'Please go outside to connect to the GPS signal.',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildGpsStatusIndicator() {
    return Positioned(
      bottom: MediaQuery.of(context).size.height * 0.87,
      left: MediaQuery.of(context).size.width / 2.5,
      child: Container(
        width: 100,
        height: 50,
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
          color: gpsStatus == true ? Colors.green : Colors.red,
        ),
        child: Center(
          child: FittedBox(
            child: Text(
              gpsStatus == true ? 'GPS Active' : 'GPS Not Active',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          currentLocation != null
              ? FlutterMap(
                  mapController: mapController,
                  options: MapOptions(
                    initialCenter: currentLocation ?? const LatLng(0, 0),
                    initialZoom: 17.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.app',
                    ),
                    MarkerLayer(
                      markers: [
                        if (currentLocation != null)
                          Marker(
                            width: 80.0,
                            height: 80.0,
                            point: currentLocation!,
                            child: const Icon(
                              Icons.location_history_outlined,
                              color: Colors.red,
                              size: 45,
                            ),
                          ),
                        if (pastLocations.isNotEmpty)
                          ...pastLocations.map(
                            (locationData) {
                              LatLng location = locationData['location'];
                              DateTime time = locationData['time'];
                              return Marker(
                                width: 80.0,
                                height: 80.0,
                                point: location,
                                child: GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title:
                                              const Text('Fall Location Time'),
                                          content: Text(formatDateTime(time)),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text('OK'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  child: const Icon(
                                    Icons.location_on,
                                    color: Colors.blue,
                                    size: 40,
                                  ),
                                ),
                              );
                            },
                          )
                      ],
                    ),
                  ],
                )
              : _noGpsSignalWidget(),
          _buildGpsStatusIndicator(),
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.10,
            left:
                MediaQuery.of(context).size.width / 3.5, // Centering the button
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black,
                backgroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              icon: const Icon(Icons.arrow_back),
              label: const Text("Back to Menu"),
            ),
          ),
        ],
      ),
    );
  }
}

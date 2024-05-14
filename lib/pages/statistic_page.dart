import 'package:fall_detection_real/data/user_id.dart';
import 'package:fall_detection_real/pages/current_status_page.dart';
import 'package:fall_detection_real/pages/fall_history_page.dart';
import 'package:fall_detection_real/services/firestore_operations.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class StatisticPage extends StatefulWidget {
  final String deviceId;

  const StatisticPage({super.key, required this.deviceId});

  @override
  State<StatisticPage> createState() => _StatisticPageState();
}

class _StatisticPageState extends State<StatisticPage> {
  Color beigeColor = const Color(0xFFF5F5DC);
  final FirestoreOperations _firestoreService = FirestoreOperations();
  final List<SensorDataPoint> sensorDataPoints =
      []; // List to store data points
  bool _isStreamActive = false; // Flag to track stream status

  void _listenToSensorData() {
    _firestoreService.getSensorDataStream(widget.deviceId).listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data()!;
        final newPoint = SensorDataPoint(
          accelerometer: data['accelerometer'],
          gyrometer: data['gyrometer'],
          time: data['time'].toDate(),
        );

        // Update the list (add new, remove old if needed)
        setState(() {
          sensorDataPoints.add(newPoint);
          if (sensorDataPoints.length > 10) {
            sensorDataPoints.removeAt(0); // Remove oldest point
          }
        });
      }
    });
    _isStreamActive = true;
  }

  //Gets the gyrometer values against the time
  List<FlSpot> _getgyrometerChartData(List<SensorDataPoint> dataPoints) {
    return dataPoints
        .map((point) => FlSpot(
            (point.time.hour * 3600 +
                point.time.minute * 60 +
                point.time.second) as double,
            point.gyrometer))
        .toList();
  }

  //Gets the accelerometer values against the time
  List<FlSpot> _getaccelerometerChartData(List<SensorDataPoint> dataPoints) {
    return dataPoints
        .map((point) => FlSpot(
            (point.time.hour * 3600 +
                point.time.minute * 60 +
                point.time.second) as double,
            point.accelerometer))
        .toList();
  }

  Widget _buildLineChartOrMessage() {
    if (sensorDataPoints.length < 10) {
      // Render the message widget in a rounded container
      return Container(
        width: MediaQuery.of(context).size.width * 0.8,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: beigeColor,
        ),
        child: const Padding(
          padding: EdgeInsets.all(15.0),
          child: Center(
            child: Text(
              'Insufficient Data',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      );
    } else {
      if (!_isStreamActive) {
        _listenToSensorData(); // Start listening only once
      }
      final gyrometerChartData = _getgyrometerChartData(sensorDataPoints);
      final accelerometerChartData =
          _getaccelerometerChartData(sensorDataPoints);

      return SizedBox(
        height: MediaQuery.of(context).size.height * 0.65,
        width: MediaQuery.of(context).size.width * 0.9,
        child: Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20), color: beigeColor),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: LineChart(
                    LineChartData(
                      lineBarsData: [
                        LineChartBarData(
                          spots: gyrometerChartData,
                          isCurved: true,
                          barWidth: 15,
                          color: Colors.blue,
                        )
                      ],
                      titlesData: const FlTitlesData(
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          leftTitles: AxisTitles(
                            axisNameWidget: Text("Gyrometer Values (degree/s)"),
                            sideTitles: SideTitles(showTitles: true),
                          ),
                          bottomTitles: AxisTitles(
                            axisNameWidget: Text("Time"),
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 30,
                            ),
                          )),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 50),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20), color: beigeColor),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: LineChart(
                    LineChartData(
                      lineBarsData: [
                        LineChartBarData(
                          spots: accelerometerChartData,
                          isCurved: true,
                          barWidth: 15,
                          color: Colors.blue,
                        ),
                      ],
                      titlesData: const FlTitlesData(
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          leftTitles: AxisTitles(
                            axisNameWidget:
                                Text("Accelerometer Values (m/s^2)"),
                            sideTitles: SideTitles(showTitles: true),
                          ),
                          bottomTitles: AxisTitles(
                            axisNameWidget: Text("Time"),
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 30,
                            ),
                          )),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

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
                'Statistic page',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),
          _buildLineChartOrMessage(),
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
              icon: Icon(Icons.history), label: "Fall History"),
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
              // Navigate to the Fall History page
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        FallHistoryPage(deviceId: widget.deviceId)),
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

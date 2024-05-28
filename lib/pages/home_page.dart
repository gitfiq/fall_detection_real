// ignore_for_file: unused_import

import 'package:fall_detection_real/components/menu_tile.dart';
import 'package:fall_detection_real/data/user_id.dart';
import 'package:fall_detection_real/pages/about_page.dart';
import 'package:fall_detection_real/pages/current_status_page.dart';
import 'package:fall_detection_real/pages/fall_history_page.dart';
import 'package:fall_detection_real/pages/login_page.dart';
import 'package:fall_detection_real/pages/statistic_page.dart';
import 'package:fall_detection_real/pages/username_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  final UserId? userId;

  const HomePage({super.key, required this.userId});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? deviceId; // Declare deviceId variable

  @override
  void initState() {
    super.initState();
    // Retrieve deviceId from the userId object
    deviceId = widget.userId?.deviceId;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 30.0),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.15, // Top quarter
            child: Center(
              child: Text(
                'Device ID: $deviceId',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(30.0),
              decoration: BoxDecoration(
                color: Colors.grey[500],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(50.0),
                  topRight: Radius.circular(50.0),
                ),
              ),
              child: Center(
                child: Column(
                  children: [
                    const SizedBox(height: 5.0),
                    Expanded(
                      child: ListView(
                        children: [
                          MenuTile(
                            icon: Icons.search,
                            title: "Current Status",
                            subtitile: "Check the status of the user",
                            destination: CurrentStatusPage(
                              deviceId: '$deviceId',
                            ),
                          ),
                          MenuTile(
                            icon: Icons.history,
                            title: "Fall History",
                            subtitile: "Past falls detected",
                            destination: FallHistoryPage(
                              deviceId: '$deviceId',
                            ),
                          ),
                          MenuTile(
                            icon: Icons.analytics_outlined,
                            title: "Activity Level",
                            subtitile: "Check active status of user",
                            destination: StatisticPage(deviceId: '$deviceId'),
                          ),
                          MenuTile(
                            icon: Icons.person_2_outlined,
                            title: "Set Name",
                            subtitile: "Set nicknames for the device",
                            destination: UsernamePage(
                              userId: widget.userId,
                            ),
                          ),
                          MenuTile(
                            icon: Icons.info_outline_rounded,
                            title: "About",
                            subtitile: "Instructions are here",
                            destination: AboutPage(
                              userId: widget.userId,
                            ),
                          ),
                          MenuTile(
                            icon: Icons.arrow_circle_left_rounded,
                            title: "Back",
                            subtitile: "Back to Login Page",
                            destination: const LoginPage(),
                            onTap: () async {
                              await FirebaseAuth.instance.signOut();
                              Navigator.pushAndRemoveUntil(
                                // ignore: use_build_context_synchronously
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const LoginPage()),
                                (route) => false,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

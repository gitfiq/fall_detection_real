import 'package:fall_detection_real/components/about_tile.dart';
import 'package:fall_detection_real/data/user_id.dart';
import 'package:flutter/material.dart';

class AboutPage extends StatefulWidget {
  final UserId? userId;

  const AboutPage({super.key, required this.userId});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
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
        children: [
          const SizedBox(height: 30.0),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.15, // Top quarter
            child: const Center(
              child: Text(
                'About',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20.0),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            height: MediaQuery.of(context).size.height * 0.60,
            width: MediaQuery.of(context).size.width * 0.95,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: const [
                AboutTile(
                    title: "About Us",
                    body:
                        "Afiq, Jovan and Javier. The creator of the Silver Shiled. Silver Shiled is created for families in Singapore to monitor their elderlies when they are away from home. \n\nNOTE: Allow this application to run in the background. Do not terminate the application as notification of a fall detected will not be shown if application is terminated"),
                AboutTile(
                    title: "Current Status",
                    body:
                        "You can check the current status of the user in the 'Current Status Page'. This is where it will show if the device has detected a fall. \n\nInformation that are available in the 'Current Status Page' are: \n. Time when page is opened, \n. LOCATION of the device and \n. STATUS of the device (Fall Detected / OK)"),
                AboutTile(
                    title: "Fall History",
                    body:
                        "All previous fall detected are stored in the 'Fall History Page'. This page is mainly use for viewing past falls and can be used for medical analysis with doctors. You are also able to delete certain fall history if you see that the fall detected was a false alarm. \n\nInformation that are available in the 'Fall History Page' are: \n. TIME of the fall and \n. LOCATION where the fall occured"),
                AboutTile(
                    title: "Activity Level",
                    body:
                        "You can check the movements of the user in the 'Active Level Page'. In this page there would be two graphs showng the rotation and movement of the user. Do use this page to check on the user if a fall is detected. \n\n NOTE: If a fall is detected and no movements are shown, a fall has most likely occured. If movements are shown, a fall may not have occured. However still do contact them to check on their status and call an ambulance if necessary. \n\n\n MORE INFORMATION \n\n The 'Activity Level Page' acceleration graphs visually represent your body movements. The Acceleration X graph shows your forward and backward movements, like walking or running, while the Acceleration Y graph displays your up and down movements, such as standing up or sitting down. Normally, when you are walking, the lines on these graphs will have small waves, indicating regular body sway. However, a fall will cause a sudden spike or dip in these graphs due to the quick and significant change in acceleration followed by no/minimal graph changes.  \n\nA spike represents a sudden forward or backward movement, like tripping or stumbling, while a dip signifies a sudden downward movement, like falling to the ground. This visual tool helps you to understand and validate fall detection alerts by recognizing movement patterns in a simple and clear manner."),
                AboutTile(
                    title: "Set Name",
                    body:
                        "You can assign a name to the device in the 'Set Name Page'. In this page you can assign the a name to the device which will be used for notification purposes. This is to allow better clarification of who's device has detected a fall. \n\n NOTE: If no names have been set, the device ID will be used as an identifier for the fall detected notification."),
                AboutTile(
                    title: "Setings",
                    body:
                        "You can adjust the sensitivity level of the device in the 'Settings Page'. There will be a slider that you can adjust ranging from low, medium to high sensitivity. This sensitivity is used in the detection of falls. \n\n For example, high sensitivity will detect falls more easily but may detect more false falls. While the low sensitivity will detect more drastic falls and will detect lesser false falls."),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 50,
            width: MediaQuery.of(context).size.width * 0.80,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/homepage',
                    arguments: widget.userId);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[800],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
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

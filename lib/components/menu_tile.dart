import 'package:flutter/material.dart';

class MenuTile extends StatelessWidget {
  // ignore: prefer_typing_uninitialized_variables
  final icon;
  final String title;
  final String subtitile;
  final Widget destination; // Destination page widget
  final VoidCallback? onTap; // Add this line

  const MenuTile(
      {super.key,
      required this.icon,
      required this.title,
      required this.subtitile,
      required this.destination,
      this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: GestureDetector(
        onTap: onTap ??
            () {
              // Navigate to a new page when the container is tapped
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => destination),
              );
            },
        child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    color: Colors.grey[400],
                    child: Icon(
                      icon,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                ),
                title: Text(
                  title,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w500),
                ),
                subtitle: Text(
                  subtitile,
                  style: const TextStyle(
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            )),
      ),
    );
  }
}

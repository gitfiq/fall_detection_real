import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

//A custom class to show a loading
class Loading extends StatefulWidget {
  const Loading({super.key});

  @override
  State<Loading> createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Lottie.network(
            'https://lottie.host/16a62e8d-b781-43de-b763-17eeaf0b4025/9umCq15Wh8.json'),
      ),
    );
  }
}

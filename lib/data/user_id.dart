class UserId {
  String? deviceId;

  UserId(this.deviceId);
}

class SensorDataPoint {
  final double accelerometer;
  final double gyrometer;
  final DateTime time;

  SensorDataPoint({
    required this.accelerometer,
    required this.gyrometer,
    required this.time,
  });
}

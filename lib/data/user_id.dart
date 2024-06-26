class UserId {
  String? deviceId;

  UserId(this.deviceId);
}

class SensorDataPoint {
  final double accelerometer;
  final DateTime time;

  SensorDataPoint({
    required this.accelerometer,
    required this.time,
  });
}

//Stores the userid
class UserId {
  String? deviceId;

  UserId(this.deviceId);
}

//Stores the data point for the Statistic Page (acceleration graph)
class SensorDataPoint {
  final double accelerometer;
  final DateTime time;

  SensorDataPoint({
    required this.accelerometer,
    required this.time,
  });
}

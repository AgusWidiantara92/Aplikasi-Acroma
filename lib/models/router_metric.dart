class RouterMetric {
  final double cpuUsage; // in %
  final double ramUsage; // in %
  final double totalRam; // in MB
  final double freeRam; // in MB
  final double downloadSpeed; // in Kbps
  final double uploadSpeed; // in Kbps
  final String uptime;
  final DateTime timestamp;
  final double totalData; // in GB
  final int signalQuality; // in %
  final double temperature; // in °C

  RouterMetric({
    required this.cpuUsage,
    required this.ramUsage,
    required this.totalRam,
    required this.freeRam,
    required this.downloadSpeed,
    required this.uploadSpeed,
    required this.uptime,
    required this.timestamp,
    required this.totalData,
    required this.signalQuality,
    required this.temperature,
  });

  Map<String, dynamic> toMap() {
    return {
      'cpuUsage': cpuUsage,
      'ramUsage': ramUsage,
      'totalRam': totalRam,
      'freeRam': freeRam,
      'downloadSpeed': downloadSpeed,
      'uploadSpeed': uploadSpeed,
      'uptime': uptime,
      'timestamp': timestamp.toIso8601String(),
      'totalData': totalData,
      'signalQuality': signalQuality,
      'temperature': temperature,
    };
  }

  factory RouterMetric.fromMap(Map<dynamic, dynamic> map) {
    return RouterMetric(
      cpuUsage: (map['cpuUsage'] as num?)?.toDouble() ?? 0.0,
      ramUsage: (map['ramUsage'] as num?)?.toDouble() ?? 0.0,
      totalRam: (map['totalRam'] as num?)?.toDouble() ?? 0.0,
      freeRam: (map['freeRam'] as num?)?.toDouble() ?? 0.0,
      downloadSpeed: (map['downloadSpeed'] as num?)?.toDouble() ?? 0.0,
      uploadSpeed: (map['uploadSpeed'] as num?)?.toDouble() ?? 0.0,
      uptime: map['uptime'] ?? '00:00:00',
      timestamp: map['timestamp'] != null
          ? DateTime.parse(map['timestamp'])
          : DateTime.now(),
      totalData: (map['totalData'] as num?)?.toDouble() ?? 12.5,
      signalQuality: (map['signalQuality'] as num?)?.toInt() ?? 90,
      temperature: (map['temperature'] as num?)?.toDouble() ?? 42.0,
    );
  }
}

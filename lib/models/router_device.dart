class RouterDevice {
  final String macAddress;
  final String ipAddress;
  final String hostname;
  final bool isOnline;
  final bool isBlocked;
  final double downloadUsage; // KB/s
  final double uploadUsage; // KB/s

  RouterDevice({
    required this.macAddress,
    required this.ipAddress,
    required this.hostname,
    this.isOnline = true,
    this.isBlocked = false,
    this.downloadUsage = 0.0,
    this.uploadUsage = 0.0,
  });

  Map<String, dynamic> toMap() {
    return {
      'macAddress': macAddress,
      'ipAddress': ipAddress,
      'hostname': hostname,
      'isOnline': isOnline,
      'isBlocked': isBlocked,
      'downloadUsage': downloadUsage,
      'uploadUsage': uploadUsage,
    };
  }

  factory RouterDevice.fromMap(Map<dynamic, dynamic> map) {
    return RouterDevice(
      macAddress: map['macAddress'] ?? '',
      ipAddress: map['ipAddress'] ?? '',
      hostname: map['hostname'] ?? 'Unknown Device',
      isOnline: map['isOnline'] ?? true,
      isBlocked: map['isBlocked'] ?? false,
      downloadUsage: (map['downloadUsage'] as num?)?.toDouble() ?? 0.0,
      uploadUsage: (map['uploadUsage'] as num?)?.toDouble() ?? 0.0,
    );
  }

  RouterDevice copyWith({
    String? macAddress,
    String? ipAddress,
    String? hostname,
    bool? isOnline,
    bool? isBlocked,
    double? downloadUsage,
    double? uploadUsage,
  }) {
    return RouterDevice(
      macAddress: macAddress ?? this.macAddress,
      ipAddress: ipAddress ?? this.ipAddress,
      hostname: hostname ?? this.hostname,
      isOnline: isOnline ?? this.isOnline,
      isBlocked: isBlocked ?? this.isBlocked,
      downloadUsage: downloadUsage ?? this.downloadUsage,
      uploadUsage: uploadUsage ?? this.uploadUsage,
    );
  }
}

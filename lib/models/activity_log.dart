class ActivityLog {
  final String id;
  final DateTime timestamp;
  final String topic; // system, info, warning, dhcp, error
  final String message;
  final String severity; // info, warning, error

  ActivityLog({
    required this.id,
    required this.timestamp,
    required this.topic,
    required this.message,
    required this.severity,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'topic': topic,
      'message': message,
      'severity': severity,
    };
  }

  factory ActivityLog.fromMap(Map<dynamic, dynamic> map) {
    return ActivityLog(
      id: map['id'] ?? '',
      timestamp: map['timestamp'] != null
          ? DateTime.parse(map['timestamp'])
          : DateTime.now(),
      topic: map['topic'] ?? 'system',
      message: map['message'] ?? '',
      severity: map['severity'] ?? 'info',
    );
  }
}

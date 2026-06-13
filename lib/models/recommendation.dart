class Recommendation {
  final String id;
  final String title;
  final String description;
  final String severity; // info, warning, critical
  final String category; // security, performance, cost
  final bool isResolved;
  final DateTime timestamp;
  final String? targetDeviceMac; // If the advice applies to a device

  Recommendation({
    required this.id,
    required this.title,
    required this.description,
    required this.severity,
    required this.category,
    this.isResolved = false,
    required this.timestamp,
    this.targetDeviceMac,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'severity': severity,
      'category': category,
      'isResolved': isResolved,
      'timestamp': timestamp.toIso8601String(),
      'targetDeviceMac': targetDeviceMac,
    };
  }

  factory Recommendation.fromMap(Map<dynamic, dynamic> map) {
    return Recommendation(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      severity: map['severity'] ?? 'info',
      category: map['category'] ?? 'performance',
      isResolved: map['isResolved'] ?? false,
      timestamp: map['timestamp'] != null
          ? DateTime.parse(map['timestamp'])
          : DateTime.now(),
      targetDeviceMac: map['targetDeviceMac'],
    );
  }

  Recommendation copyWith({
    String? id,
    String? title,
    String? description,
    String? severity,
    String? category,
    bool? isResolved,
    DateTime? timestamp,
    String? targetDeviceMac,
  }) {
    return Recommendation(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      severity: severity ?? this.severity,
      category: category ?? this.category,
      isResolved: isResolved ?? this.isResolved,
      timestamp: timestamp ?? this.timestamp,
      targetDeviceMac: targetDeviceMac ?? this.targetDeviceMac,
    );
  }
}

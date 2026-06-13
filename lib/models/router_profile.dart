class RouterProfile {
  final String id;
  final String nickname;
  final String host;
  final int port;
  final String username;
  final String password;
  final bool isOnline;

  RouterProfile({
    required this.id,
    required this.nickname,
    required this.host,
    required this.port,
    required this.username,
    required this.password,
    this.isOnline = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nickname': nickname,
      'host': host,
      'port': port,
      'username': username,
      'password': password,
      'isOnline': isOnline,
    };
  }

  factory RouterProfile.fromMap(Map<dynamic, dynamic> map) {
    return RouterProfile(
      id: map['id'] ?? '',
      nickname: map['nickname'] ?? '',
      host: map['host'] ?? '',
      port: map['port'] ?? 8728,
      username: map['username'] ?? '',
      password: map['password'] ?? '',
      isOnline: map['isOnline'] ?? false,
    );
  }

  RouterProfile copyWith({
    String? id,
    String? nickname,
    String? host,
    int? port,
    String? username,
    String? password,
    bool? isOnline,
  }) {
    return RouterProfile(
      id: id ?? this.id,
      nickname: nickname ?? this.nickname,
      host: host ?? this.host,
      port: port ?? this.port,
      username: username ?? this.username,
      password: password ?? this.password,
      isOnline: isOnline ?? this.isOnline,
    );
  }
}

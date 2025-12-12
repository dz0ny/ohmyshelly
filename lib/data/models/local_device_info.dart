/// Connection source indicating how we're communicating with the device
enum ConnectionSource {
  /// Connected via Shelly Cloud API
  cloud,

  /// Connected via local network HTTP
  local,

  /// Not yet determined
  unknown,
}

/// State of local connection for a device
enum LocalConnectionState {
  /// Never attempted local connection
  unknown,

  /// mDNS discovery in progress
  discovering,

  /// Attempting to connect locally
  connecting,

  /// Local connection established and working
  connected,

  /// Local connection failed, using cloud fallback
  unreachable,
}

/// Information about a device's local network connection
class LocalDeviceInfo {
  final String deviceId;
  final String? localIp;
  final int localPort;
  final LocalConnectionState state;
  final DateTime? lastLocalSuccess;
  final DateTime? lastLocalFailure;
  final bool requiresAuth;
  final String? authRealm;

  /// Retry local connection after this duration of failure
  static const Duration retryBackoff = Duration(minutes: 5);

  const LocalDeviceInfo({
    required this.deviceId,
    this.localIp,
    this.localPort = 80,
    this.state = LocalConnectionState.unknown,
    this.lastLocalSuccess,
    this.lastLocalFailure,
    this.requiresAuth = false,
    this.authRealm,
  });

  /// Whether we can attempt a local connection
  bool get canTryLocal =>
      localIp != null && state != LocalConnectionState.connecting;

  /// Whether we should retry local connection after a failure
  bool get shouldRetryLocal {
    if (lastLocalFailure == null) return true;
    return DateTime.now().difference(lastLocalFailure!) > retryBackoff;
  }

  /// Whether local connection is currently active
  bool get isLocalConnected => state == LocalConnectionState.connected;

  LocalDeviceInfo copyWith({
    String? deviceId,
    String? localIp,
    int? localPort,
    LocalConnectionState? state,
    DateTime? lastLocalSuccess,
    DateTime? lastLocalFailure,
    bool? requiresAuth,
    String? authRealm,
  }) {
    return LocalDeviceInfo(
      deviceId: deviceId ?? this.deviceId,
      localIp: localIp ?? this.localIp,
      localPort: localPort ?? this.localPort,
      state: state ?? this.state,
      lastLocalSuccess: lastLocalSuccess ?? this.lastLocalSuccess,
      lastLocalFailure: lastLocalFailure ?? this.lastLocalFailure,
      requiresAuth: requiresAuth ?? this.requiresAuth,
      authRealm: authRealm ?? this.authRealm,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'deviceId': deviceId,
      'localIp': localIp,
      'localPort': localPort,
      'state': state.name,
      'lastLocalSuccess': lastLocalSuccess?.toIso8601String(),
      'lastLocalFailure': lastLocalFailure?.toIso8601String(),
      'requiresAuth': requiresAuth,
      'authRealm': authRealm,
    };
  }

  factory LocalDeviceInfo.fromJson(Map<String, dynamic> json) {
    return LocalDeviceInfo(
      deviceId: json['deviceId'] as String,
      localIp: json['localIp'] as String?,
      localPort: json['localPort'] as int? ?? 80,
      state: LocalConnectionState.values.firstWhere(
        (e) => e.name == json['state'],
        orElse: () => LocalConnectionState.unknown,
      ),
      lastLocalSuccess: json['lastLocalSuccess'] != null
          ? DateTime.tryParse(json['lastLocalSuccess'] as String)
          : null,
      lastLocalFailure: json['lastLocalFailure'] != null
          ? DateTime.tryParse(json['lastLocalFailure'] as String)
          : null,
      requiresAuth: json['requiresAuth'] as bool? ?? false,
      authRealm: json['authRealm'] as String?,
    );
  }

  @override
  String toString() {
    return 'LocalDeviceInfo(deviceId: $deviceId, localIp: $localIp, state: $state)';
  }
}

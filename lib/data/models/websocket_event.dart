// WebSocket event models for Shelly Cloud real-time events.
//
// These events are received via WebSocket connection and contain
// device status updates and online/offline notifications.

/// Base class for all WebSocket events.
sealed class WebSocketEvent {
  final String deviceId;
  final String deviceCode;
  final String deviceGen;

  const WebSocketEvent({
    required this.deviceId,
    required this.deviceCode,
    required this.deviceGen,
  });
}

/// Event received when a device status changes.
///
/// Contains the full status object with all device data.
/// The status format matches HTTP API responses.
class StatusChangeEvent extends WebSocketEvent {
  final Map<String, dynamic> status;
  final Map<String, dynamic>? metadata;

  const StatusChangeEvent({
    required super.deviceId,
    required super.deviceCode,
    required super.deviceGen,
    required this.status,
    this.metadata,
  });
}

/// Event received when a device goes online or offline.
class OnlineChangeEvent extends WebSocketEvent {
  final bool isOnline;

  const OnlineChangeEvent({
    required super.deviceId,
    required super.deviceCode,
    required super.deviceGen,
    required this.isOnline,
  });
}

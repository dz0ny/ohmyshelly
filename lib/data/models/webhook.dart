/// Represents a webhook (action) on a Shelly device.
///
/// Webhooks are stored on the device and trigger HTTP requests when specific events occur.
class Webhook {
  final int id;
  final int cid;
  final bool enabled;
  final String event;
  final String name;
  final String? sslCa;
  final List<String> urls;
  final String? condition;
  final int repeatPeriod;

  const Webhook({
    required this.id,
    required this.cid,
    required this.enabled,
    required this.event,
    required this.name,
    this.sslCa,
    required this.urls,
    this.condition,
    required this.repeatPeriod,
  });

  /// Parse from Shelly webhook.list response.
  factory Webhook.fromJson(Map<String, dynamic> json) {
    final urlsList = json['urls'] as List<dynamic>? ?? [];
    return Webhook(
      id: json['id'] as int,
      cid: json['cid'] as int? ?? 0,
      enabled: json['enable'] as bool? ?? false,
      event: json['event'] as String? ?? '',
      name: json['name'] as String? ?? '',
      sslCa: json['ssl_ca'] as String?,
      urls: urlsList.map((u) => u.toString()).toList(),
      condition: json['condition'] as String?,
      repeatPeriod: json['repeat_period'] as int? ?? 0,
    );
  }

  /// Convert to API format for create/update.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cid': cid,
      'enable': enabled,
      'event': event,
      'name': name,
      if (sslCa != null) 'ssl_ca': sslCa,
      'urls': urls,
      if (condition != null) 'condition': condition,
      'repeat_period': repeatPeriod,
    };
  }

  Webhook copyWith({
    int? id,
    int? cid,
    bool? enabled,
    String? event,
    String? name,
    String? sslCa,
    List<String>? urls,
    String? condition,
    int? repeatPeriod,
  }) {
    return Webhook(
      id: id ?? this.id,
      cid: cid ?? this.cid,
      enabled: enabled ?? this.enabled,
      event: event ?? this.event,
      name: name ?? this.name,
      sslCa: sslCa ?? this.sslCa,
      urls: urls ?? this.urls,
      condition: condition ?? this.condition,
      repeatPeriod: repeatPeriod ?? this.repeatPeriod,
    );
  }

  /// Get a human-readable description of the event.
  String get eventDescription {
    return WebhookEvent.getDescription(event);
  }
}

/// Common Shelly webhook events.
class WebhookEvent {
  static const String inputButtonPush = 'input.button_push';
  static const String inputButtonLongpush = 'input.button_longpush';
  static const String inputButtonDoublepush = 'input.button_doublepush';
  static const String inputToggleOn = 'input.toggle_on';
  static const String inputToggleOff = 'input.toggle_off';
  static const String switchOn = 'switch.on';
  static const String switchOff = 'switch.off';
  static const String temperature = 'temperature';
  static const String humidity = 'humidity';
  static const String voltage = 'voltage';

  /// All available events for selection.
  static const List<String> allEvents = [
    inputButtonPush,
    inputButtonLongpush,
    inputButtonDoublepush,
    inputToggleOn,
    inputToggleOff,
    switchOn,
    switchOff,
    temperature,
    humidity,
    voltage,
  ];

  /// Get human-readable description for an event.
  static String getDescription(String event) {
    switch (event) {
      case inputButtonPush:
        return 'Button Push';
      case inputButtonLongpush:
        return 'Button Long Push';
      case inputButtonDoublepush:
        return 'Button Double Push';
      case inputToggleOn:
        return 'Input Toggle On';
      case inputToggleOff:
        return 'Input Toggle Off';
      case switchOn:
        return 'Switch Turned On';
      case switchOff:
        return 'Switch Turned Off';
      case temperature:
        return 'Temperature Change';
      case humidity:
        return 'Humidity Change';
      case voltage:
        return 'Voltage Change';
      default:
        return event;
    }
  }
}

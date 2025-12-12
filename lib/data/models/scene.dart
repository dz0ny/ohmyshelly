class Scene {
  final int id;
  final String name;
  final String? image;
  final String roomName;
  final int roomId;
  final bool enabled;
  final bool runOnIngest;
  final int position;
  final List<String> controlDeviceIds;
  final List<String> actionDeviceIds;

  Scene({
    required this.id,
    required this.name,
    this.image,
    required this.roomName,
    required this.roomId,
    required this.enabled,
    required this.runOnIngest,
    required this.position,
    required this.controlDeviceIds,
    required this.actionDeviceIds,
  });

  /// Parse from scene_scripts map entry
  /// The id comes from the map key, json is the value
  factory Scene.fromJson(int id, Map<String, dynamic> json) {
    final meta = json['_meta'] as Map<String, dynamic>? ?? {};

    return Scene(
      id: id,
      name: meta['name'] as String? ?? 'Scene $id',
      image: meta['image'] as String?,
      roomName: meta['roomn'] as String? ?? 'General',
      roomId: meta['room'] as int? ?? -1,
      enabled: json['_enabled'] as bool? ?? false,
      runOnIngest: json['_run_on_ingest'] as bool? ?? false,
      position: meta['position'] as int? ?? 0,
      controlDeviceIds: _parseStringList(meta['cdi']),
      actionDeviceIds: _parseStringList(meta['adi']),
    );
  }

  static List<String> _parseStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    return [];
  }

  Scene copyWith({
    int? id,
    String? name,
    String? image,
    String? roomName,
    int? roomId,
    bool? enabled,
    bool? runOnIngest,
    int? position,
    List<String>? controlDeviceIds,
    List<String>? actionDeviceIds,
  }) {
    return Scene(
      id: id ?? this.id,
      name: name ?? this.name,
      image: image ?? this.image,
      roomName: roomName ?? this.roomName,
      roomId: roomId ?? this.roomId,
      enabled: enabled ?? this.enabled,
      runOnIngest: runOnIngest ?? this.runOnIngest,
      position: position ?? this.position,
      controlDeviceIds: controlDeviceIds ?? this.controlDeviceIds,
      actionDeviceIds: actionDeviceIds ?? this.actionDeviceIds,
    );
  }

  @override
  String toString() {
    return 'Scene(id: $id, name: $name, enabled: $enabled, room: $roomName)';
  }
}

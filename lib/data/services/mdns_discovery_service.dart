import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:nsd/nsd.dart' as nsd;

/// Represents a Shelly device discovered via mDNS
class DiscoveredDevice {
  final String name;
  final String host;
  final int port;
  final List<String> ipAddresses;
  final String? deviceId;

  DiscoveredDevice({
    required this.name,
    required this.host,
    required this.port,
    required this.ipAddresses,
    this.deviceId,
  });

  /// Get the primary IP address (prefer IPv4)
  String? get primaryIp {
    if (ipAddresses.isEmpty) return null;
    // Prefer IPv4 addresses (don't contain ':')
    final ipv4 = ipAddresses.where((ip) => !ip.contains(':')).toList();
    return ipv4.isNotEmpty ? ipv4.first : ipAddresses.first;
  }

  @override
  String toString() => 'DiscoveredDevice($name @ $primaryIp:$port)';
}

/// Service for discovering Shelly devices on the local network via mDNS
class MdnsDiscoveryService {
  /// Shelly Gen2/Gen3 devices advertise this service type
  static const String shellyServiceType = '_shelly._tcp';

  nsd.Discovery? _discovery;
  final _devicesController = StreamController<DiscoveredDevice>.broadcast();
  final Map<String, DiscoveredDevice> _discoveredDevices = {};
  bool _isDiscovering = false;

  /// Stream of discovered devices (emits when a new device is found)
  Stream<DiscoveredDevice> get discoveredDevices => _devicesController.stream;

  /// Map of all discovered devices by device ID
  Map<String, DiscoveredDevice> get allDiscoveredDevices =>
      Map.unmodifiable(_discoveredDevices);

  /// Whether discovery is currently running
  bool get isDiscovering => _isDiscovering;

  /// Start mDNS discovery for Shelly devices
  Future<void> startDiscovery() async {
    if (_isDiscovering) {
      if (kDebugMode) {
        debugPrint('[mDNS] Discovery already running');
      }
      return;
    }

    _isDiscovering = true;

    try {
      _discovery = await nsd.startDiscovery(
        shellyServiceType,
        ipLookupType: nsd.IpLookupType.any,
      );

      _discovery!.addServiceListener((service, status) {
        if (status == nsd.ServiceStatus.found) {
          _handleServiceFound(service);
        } else if (status == nsd.ServiceStatus.lost) {
          _handleServiceLost(service);
        }
      });

      if (kDebugMode) {
        debugPrint('[mDNS] Started discovery for $shellyServiceType');
      }
    } catch (e) {
      _isDiscovering = false;
      if (kDebugMode) {
        debugPrint('[mDNS] Discovery failed to start: $e');
      }
      rethrow;
    }
  }

  void _handleServiceFound(nsd.Service service) {
    final name = service.name;
    if (name == null) return;

    // Extract device ID from name (e.g., "shellyplugsg3-E4B063FB8A14" -> "e4b063fb8a14")
    final deviceId = _extractDeviceId(name);

    // Get IP addresses (convert InternetAddress to String)
    final addresses = service.addresses?.map((a) => a.address).toList() ?? [];
    if (addresses.isEmpty) {
      if (kDebugMode) {
        debugPrint('[mDNS] Found $name but no IP addresses');
      }
      return;
    }

    final discovered = DiscoveredDevice(
      name: name,
      host: service.host ?? '',
      port: service.port ?? 80,
      ipAddresses: addresses,
      deviceId: deviceId,
    );

    if (deviceId != null) {
      _discoveredDevices[deviceId] = discovered;
      _devicesController.add(discovered);

      if (kDebugMode) {
        debugPrint('[mDNS] Found: $name -> ${discovered.primaryIp}:${discovered.port}');
      }
    }
  }

  void _handleServiceLost(nsd.Service service) {
    final name = service.name;
    if (name == null) return;

    final deviceId = _extractDeviceId(name);
    if (deviceId != null) {
      _discoveredDevices.remove(deviceId);
      if (kDebugMode) {
        debugPrint('[mDNS] Lost: $name');
      }
    }
  }

  /// Extract device ID from mDNS name
  /// Format: "shellyXXX-DEVICEID" -> "deviceid" (lowercase)
  String? _extractDeviceId(String name) {
    // Shelly devices use format like "shellyplugsg3-E4B063FB8A14"
    final dashIndex = name.lastIndexOf('-');
    if (dashIndex > 0 && dashIndex < name.length - 1) {
      return name.substring(dashIndex + 1).toLowerCase();
    }
    return null;
  }

  /// Get discovered device by device ID (case-insensitive)
  DiscoveredDevice? getDeviceById(String deviceId) {
    return _discoveredDevices[deviceId.toLowerCase()];
  }

  /// Get IP address for a device by ID
  String? getIpForDevice(String deviceId) {
    return getDeviceById(deviceId)?.primaryIp;
  }

  /// Stop mDNS discovery
  Future<void> stopDiscovery() async {
    if (_discovery != null) {
      try {
        await nsd.stopDiscovery(_discovery!);
      } catch (e) {
        if (kDebugMode) {
          debugPrint('[mDNS] Error stopping discovery: $e');
        }
      }
      _discovery = null;
    }
    _isDiscovering = false;
  }

  /// Dispose resources
  void dispose() {
    stopDiscovery();
    _devicesController.close();
    _discoveredDevices.clear();
  }
}

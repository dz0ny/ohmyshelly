import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:ohmyshelly/l10n/app_localizations.dart';
import '../../providers/device_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/common/device_grid_view.dart';
import '../../widgets/common/empty_state.dart';
import '../../core/constants/app_icons.dart';

/// Screen that shows all devices in a specific room.
class RoomScreen extends StatelessWidget {
  final String roomName;

  const RoomScreen({super.key, required this.roomName});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(roomName),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Consumer2<DeviceProvider, SettingsProvider>(
        builder: (context, deviceProvider, settingsProvider, _) {
          // Filter devices by room name
          final excludedDevices = settingsProvider.dashboardExcludedDevices;
          final roomDevices = deviceProvider.devices
              .where((d) =>
                  !d.isGateway &&
                  !excludedDevices.contains(d.id) &&
                  _matchesRoom(d.roomName, roomName, l10n))
              .toList();

          if (roomDevices.isEmpty) {
            return EmptyState(
              icon: AppIcons.dashboard,
              title: l10n.noDevices,
              message: l10n.noDevicesDesc,
            );
          }

          return RefreshIndicator(
            onRefresh: () => deviceProvider.refresh(),
            child: DeviceGridView(
              devices: roomDevices,
              deviceProvider: deviceProvider,
            ),
          );
        },
      ),
    );
  }

  /// Check if device room matches the target room name
  bool _matchesRoom(String? deviceRoom, String targetRoom, AppLocalizations l10n) {
    final otherRoom = l10n.otherRoom;
    // If target is "Other", match devices without a room
    if (targetRoom == otherRoom) {
      return deviceRoom == null || deviceRoom.isEmpty;
    }
    return deviceRoom == targetRoom;
  }
}

import 'package:flutter/material.dart';
import 'package:ohmyshelly/l10n/app_localizations.dart';

/// Banner type for connectivity status
enum ConnectivityBannerType {
  /// Phone is completely offline (no internet)
  offline,

  /// Phone is on cellular (no local device access)
  cellular,

  /// Phone is on WiFi but different network than devices
  differentWifi,
}

/// A banner that shows connectivity status to the user
///
/// Shows different messages based on whether the phone is:
/// - Completely offline (no internet)
/// - On cellular (can use cloud but not local device access)
/// - On different WiFi network (devices are on another network)
class ConnectivityBanner extends StatelessWidget {
  final ConnectivityBannerType type;
  final VoidCallback? onDismiss;

  /// Network name where devices are located (for differentWifi type)
  final String? deviceNetworkName;

  const ConnectivityBanner({
    super.key,
    required this.type,
    this.onDismiss,
    this.deviceNetworkName,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    final (backgroundColor, textColor, icon, title, description) =
        _getDisplayInfo(context, l10n, colorScheme);

    return Material(
      color: backgroundColor,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(
                icon,
                color: textColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: TextStyle(
                        color: textColor.withValues(alpha: 0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (onDismiss != null)
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: textColor,
                    size: 20,
                  ),
                  onPressed: onDismiss,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Get display information based on banner type
  (Color, Color, IconData, String, String) _getDisplayInfo(
    BuildContext context,
    AppLocalizations l10n,
    ColorScheme colorScheme,
  ) {
    switch (type) {
      case ConnectivityBannerType.offline:
        return (
          colorScheme.errorContainer,
          colorScheme.onErrorContainer,
          Icons.cloud_off,
          l10n.phoneOffline,
          l10n.phoneOfflineDesc,
        );
      case ConnectivityBannerType.cellular:
        return (
          colorScheme.secondaryContainer,
          colorScheme.onSecondaryContainer,
          Icons.signal_cellular_alt,
          l10n.phoneOnCellular,
          l10n.phoneOnCellularDesc,
        );
      case ConnectivityBannerType.differentWifi:
        return (
          colorScheme.tertiaryContainer,
          colorScheme.onTertiaryContainer,
          Icons.wifi_find,
          l10n.phoneDifferentWifi,
          l10n.phoneDifferentWifiDesc(deviceNetworkName ?? '?'),
        );
    }
  }
}

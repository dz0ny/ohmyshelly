import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ohmyshelly/l10n/app_localizations.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/local_device_info.dart';

/// A compact footer for device cards showing connection details and last updated time.
class DeviceCardFooter extends StatelessWidget {
  final String? ipAddress;
  final String? ssid;
  final String? uptime;
  final int? rssi;
  final DateTime? lastUpdated;
  final String? firmwareVersion;
  final ConnectionSource? connectionSource;

  const DeviceCardFooter({
    super.key,
    this.ipAddress,
    this.ssid,
    this.uptime,
    this.rssi,
    this.lastUpdated,
    this.firmwareVersion,
    this.connectionSource,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final items = <Widget>[];

    // Connection source indicator (Local or Cloud)
    if (connectionSource != null && connectionSource != ConnectionSource.unknown) {
      items.add(_buildConnectionIndicator(context));
    }

    // IP Address (tappable to open device web interface)
    if (ipAddress != null && ipAddress!.isNotEmpty) {
      items.add(_buildTappableIp(context, ipAddress!));
    }

    // Signal strength (always show if available)
    if (rssi != null) {
      items.add(_buildSignalItem(l10n, rssi!));
    }

    // Uptime
    if (uptime != null && uptime!.isNotEmpty) {
      items.add(_buildInfoItem(
        context: context,
        icon: Icons.schedule,
        text: uptime!,
      ));
    }

    // Firmware version
    if (firmwareVersion != null && firmwareVersion!.isNotEmpty) {
      items.add(_buildInfoItem(
        context: context,
        icon: Icons.memory,
        text: 'v$firmwareVersion',
      ));
    }

    // Last updated
    if (lastUpdated != null) {
      items.add(_buildInfoItem(
        context: context,
        icon: Icons.update,
        text: Formatters.timeAgo(lastUpdated!, l10n),
      ));
    }

    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: _buildRowWithSeparators(context, items, colorScheme),
          ),
        ),
      ],
    );
  }

  Widget _buildConnectionIndicator(BuildContext context) {
    final isLocal = connectionSource == ConnectionSource.local;
    final color = isLocal ? AppColors.success : AppColors.info;
    final icon = isLocal ? Icons.wifi : Icons.cloud_outlined;
    final text = isLocal ? 'Local' : 'Cloud';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 11,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildTappableIp(BuildContext context, String ip) {
    return GestureDetector(
      onTap: () => _openDeviceWebInterface(ip),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.language,
            size: 12,
            color: AppColors.info,
          ),
          const SizedBox(width: 4),
          Text(
            ip,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.info,
              decoration: TextDecoration.underline,
              decorationColor: AppColors.info,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({required BuildContext context, required IconData icon, required String text}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 12,
          color: colorScheme.outline,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 11,
            color: colorScheme.outline,
          ),
        ),
      ],
    );
  }

  Widget _buildSignalItem(AppLocalizations l10n, int rssi) {
    final color = _getSignalColor(rssi);
    final label = _getSignalLabel(l10n, rssi);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.signal_wifi_4_bar,
          size: 12,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: color,
          ),
        ),
      ],
    );
  }

  String _getSignalLabel(AppLocalizations l10n, int rssi) {
    if (rssi > -50) return l10n.signalExcellent;
    if (rssi > -60) return l10n.signalGood;
    if (rssi > -70) return l10n.signalFair;
    return l10n.signalWeak;
  }

  Color _getSignalColor(int rssi) {
    if (rssi > -50) return AppColors.success;  // Excellent
    if (rssi > -60) return AppColors.success;  // Good
    if (rssi > -70) return AppColors.warning;  // Fair
    return AppColors.error;                     // Weak
  }

  List<Widget> _buildRowWithSeparators(BuildContext context, List<Widget> items, ColorScheme colorScheme) {
    final result = <Widget>[];
    for (int i = 0; i < items.length; i++) {
      result.add(items[i]);
      if (i < items.length - 1) {
        result.add(Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            '•',
            style: TextStyle(
              fontSize: 11,
              color: colorScheme.outline,
            ),
          ),
        ));
      }
    }
    return result;
  }

  Future<void> _openDeviceWebInterface(String ip) async {
    final uri = Uri.parse('http://$ip');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

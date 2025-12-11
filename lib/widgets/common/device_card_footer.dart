import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ohmyshelly/l10n/app_localizations.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';

/// A compact footer for device cards showing connection details and last updated time.
class DeviceCardFooter extends StatelessWidget {
  final String? ipAddress;
  final String? ssid;
  final String? uptime;
  final int? rssi;
  final DateTime? lastUpdated;

  const DeviceCardFooter({
    super.key,
    this.ipAddress,
    this.ssid,
    this.uptime,
    this.rssi,
    this.lastUpdated,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final items = <Widget>[];

    // IP Address (tappable to open device web interface)
    if (ipAddress != null && ipAddress!.isNotEmpty) {
      items.add(_buildTappableIp(context, ipAddress!));
    }

    // WiFi SSID
    if (ssid != null && ssid!.isNotEmpty) {
      items.add(_buildInfoItem(
        icon: Icons.wifi,
        text: ssid!,
      ));
    }

    // Signal strength (if no SSID shown)
    if (rssi != null && (ssid == null || ssid!.isEmpty)) {
      items.add(_buildSignalItem(l10n, rssi!));
    }

    // Uptime
    if (uptime != null && uptime!.isNotEmpty) {
      items.add(_buildInfoItem(
        icon: Icons.schedule,
        text: uptime!,
      ));
    }

    // Last updated
    if (lastUpdated != null) {
      items.add(_buildInfoItem(
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
            children: _buildRowWithSeparators(items),
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

  Widget _buildInfoItem({required IconData icon, required String text}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 12,
          color: AppColors.textHint,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textHint,
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

  List<Widget> _buildRowWithSeparators(List<Widget> items) {
    final result = <Widget>[];
    for (int i = 0; i < items.length; i++) {
      result.add(items[i]);
      if (i < items.length - 1) {
        result.add(const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            '•',
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textHint,
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

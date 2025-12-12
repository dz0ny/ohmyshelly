import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../l10n/app_localizations.dart';

/// Detail view for unsupported/unknown devices - shows raw JSON data
class UnknownDeviceDetail extends StatelessWidget {
  final String deviceCode;
  final Map<String, dynamic>? rawJson;

  const UnknownDeviceDetail({
    super.key,
    required this.deviceCode,
    this.rawJson,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Unsupported device notice
        Card(
          color: colorScheme.errorContainer,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: colorScheme.onErrorContainer,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.unsupportedDevice,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onErrorContainer,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.unsupportedDeviceDesc(deviceCode),
                        style: TextStyle(
                          fontSize: 13,
                          color: colorScheme.onErrorContainer.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // JSON Data card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.deviceData,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    if (rawJson != null)
                      TextButton.icon(
                        onPressed: () => _copyToClipboard(context),
                        icon: const Icon(Icons.copy, size: 18),
                        label: Text(l10n.copyJson),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                if (rawJson != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SelectableText(
                      _formatJson(rawJson!),
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ] else ...[
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        l10n.noDataAvailable,
                        style: TextStyle(color: colorScheme.onSurfaceVariant),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatJson(Map<String, dynamic> json) {
    final encoder = const JsonEncoder.withIndent('  ');
    return encoder.convert(json);
  }

  void _copyToClipboard(BuildContext context) {
    if (rawJson == null) return;

    final jsonString = _formatJson(rawJson!);
    Clipboard.setData(ClipboardData(text: jsonString));

    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.copiedToClipboard),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:ohmyshelly/l10n/app_localizations.dart';
import '../../data/services/update_service.dart';

/// Banner displayed when an app update is available
class UpdateBanner extends StatelessWidget {
  final UpdateService updateService;
  final VoidCallback? onDismiss;

  const UpdateBanner({
    super.key,
    required this.updateService,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ListenableBuilder(
      listenable: updateService,
      builder: (context, _) {
        final status = updateService.status;

        // Don't show banner for these states
        if (status == UpdateStatus.idle || status == UpdateStatus.checking) {
          return const SizedBox.shrink();
        }

        return Positioned(
          bottom: MediaQuery.of(context).padding.bottom + 80, // Above bottom nav
          left: 16,
          right: 16,
          child: Material(
            elevation: 6,
            borderRadius: BorderRadius.circular(12),
            color: _getBackgroundColor(status),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: _buildContent(context, status, l10n),
            ),
          ),
        );
      },
    );
  }

  Color _getBackgroundColor(UpdateStatus status) {
    switch (status) {
      case UpdateStatus.available:
        return Colors.blue.shade700;
      case UpdateStatus.downloading:
        return Colors.blue.shade600;
      case UpdateStatus.readyToInstall:
        return Colors.green.shade700;
      case UpdateStatus.error:
        return Colors.red.shade700;
      default:
        return Colors.blue.shade700;
    }
  }

  Widget _buildContent(
      BuildContext context, UpdateStatus status, AppLocalizations l10n) {
    switch (status) {
      case UpdateStatus.available:
        return _buildAvailableContent(l10n);
      case UpdateStatus.downloading:
        return _buildDownloadingContent(l10n);
      case UpdateStatus.readyToInstall:
        return _buildReadyContent(l10n);
      case UpdateStatus.error:
        return _buildErrorContent(l10n);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildAvailableContent(AppLocalizations l10n) {
    final release = updateService.latestRelease;
    return Row(
      children: [
        const Icon(Icons.system_update, color: Colors.white),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.updateAvailable,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              if (release != null)
                Text(
                  l10n.updateVersion(release.version),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
            ],
          ),
        ),
        TextButton(
          onPressed: () => updateService.downloadAndInstall(),
          style: TextButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.blue.shade700,
          ),
          child: Text(l10n.updateDownload),
        ),
        const SizedBox(width: 4),
        IconButton(
          icon: const Icon(Icons.close, color: Colors.white70, size: 20),
          onPressed: () {
            updateService.dismiss();
            onDismiss?.call();
          },
          tooltip: l10n.updateClose,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        ),
      ],
    );
  }

  Widget _buildDownloadingContent(AppLocalizations l10n) {
    final progress = updateService.downloadProgress;
    final percent = (progress * 100).toStringAsFixed(0);
    return Row(
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            value: progress > 0 ? progress : null,
            strokeWidth: 2.5,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.updateDownloading,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: progress > 0 ? progress : null,
                backgroundColor: Colors.white24,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              ),
              const SizedBox(height: 2),
              Text(
                '$percent%',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReadyContent(AppLocalizations l10n) {
    return Row(
      children: [
        const Icon(Icons.check_circle, color: Colors.white),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.updateReady,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Text(
                l10n.updateTapToInstall,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        TextButton(
          onPressed: () => updateService.downloadAndInstall(),
          style: TextButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.green.shade700,
          ),
          child: Text(l10n.updateInstall),
        ),
      ],
    );
  }

  Widget _buildErrorContent(AppLocalizations l10n) {
    return Row(
      children: [
        const Icon(Icons.error_outline, color: Colors.white),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.updateError,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              if (updateService.errorMessage != null)
                Text(
                  updateService.errorMessage!,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
        TextButton(
          onPressed: () => updateService.checkForUpdate(),
          style: TextButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.red.shade700,
          ),
          child: Text(l10n.retry),
        ),
        const SizedBox(width: 4),
        IconButton(
          icon: const Icon(Icons.close, color: Colors.white70, size: 20),
          onPressed: () {
            updateService.reset();
            onDismiss?.call();
          },
          tooltip: l10n.updateClose,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        ),
      ],
    );
  }
}

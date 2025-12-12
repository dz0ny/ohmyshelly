import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ohmyshelly/l10n/app_localizations.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_icons.dart';
import '../../data/models/scene.dart';
import '../../providers/scene_provider.dart';
import '../../widgets/cards/scene_card.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/error_card.dart';

class ScenesTab extends StatelessWidget {
  const ScenesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.scenes),
      ),
      body: Consumer<SceneProvider>(
        builder: (context, sceneProvider, _) {
          if (sceneProvider.isLoading &&
              sceneProvider.state == SceneLoadState.loading) {
            return LoadingIndicator(message: l10n.loadingScenes);
          }

          if (sceneProvider.state == SceneLoadState.error &&
              sceneProvider.scenes.isEmpty) {
            return ErrorCard(
              message: sceneProvider.error ?? l10n.errorGeneric,
              onRetry: () => sceneProvider.fetchScenes(),
            );
          }

          if (sceneProvider.scenes.isEmpty) {
            return EmptyState(
              icon: AppIcons.scene,
              title: l10n.noScenes,
              message: l10n.noScenesDesc,
            );
          }

          // Group scenes by room
          final scenesByRoom = _groupScenesByRoom(sceneProvider.scenes);
          final roomNames = scenesByRoom.keys.toList();

          return RefreshIndicator(
            onRefresh: () => sceneProvider.refresh(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: roomNames.length,
              itemBuilder: (context, roomIndex) {
                final roomName = roomNames[roomIndex];
                final roomScenes = scenesByRoom[roomName]!;

                final colorScheme = Theme.of(context).colorScheme;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Room header
                    Padding(
                      padding: EdgeInsets.only(
                        top: roomIndex == 0 ? 0 : 16,
                        bottom: 12,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.room,
                            size: 20,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              roomName,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: colorScheme.onSurface,
                                  ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.scene.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${roomScenes.length}',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                    color: AppColors.scene,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Scenes in this room
                    ...roomScenes.map((scene) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: SceneCard(
                          scene: scene,
                          onToggle: (enabled) =>
                              sceneProvider.toggleScene(scene.id, enabled),
                          onRun: () => sceneProvider.runScene(scene.id),
                        ),
                      );
                    }),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }

  /// Groups scenes by room name.
  /// Rooms are sorted alphabetically.
  Map<String, List<Scene>> _groupScenesByRoom(List<Scene> scenes) {
    final Map<String, List<Scene>> grouped = {};

    for (final scene in scenes) {
      final roomKey = scene.roomName;
      grouped.putIfAbsent(roomKey, () => []).add(scene);
    }

    // Sort rooms alphabetically
    final sortedKeys = grouped.keys.toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

    // Rebuild map in sorted order
    final result = <String, List<Scene>>{};
    for (final key in sortedKeys) {
      result[key] = grouped[key]!;
    }
    return result;
  }
}
